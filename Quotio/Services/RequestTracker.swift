//
//  RequestTracker.swift
//  Quotio - Request History Tracking Service
//
//  This service tracks API requests through ProxyBridge callbacks.
//  Request history is persisted to disk for session continuity.
//

import Foundation
import AppKit

/// Service for tracking API request history with persistence
@MainActor
@Observable
final class RequestTracker {
    
    // MARK: - Singleton
    
    static let shared = RequestTracker()
    
    // MARK: - Properties
    
    /// Current request history (newest first)
    private(set) var requestHistory: [RequestLog] = []
    
    /// Aggregate statistics
    private(set) var stats: RequestStats = .empty
    
    /// Whether the tracker is active
    private(set) var isActive = false
    
    /// Last error message
    private(set) var lastError: String?
    
    // MARK: - Private Properties
    
    /// Storage container
    private var store: RequestHistoryStore = .empty

    /// Route observer for enriching request history with selected account/proxy info
    @ObservationIgnored
    private var routeObserver: RequestRouteObserver?
    
    /// Queue for file operations
    private let fileQueue = DispatchQueue(label: RuntimeProfile.queueLabel("request-tracker-file"))
    
    /// Storage file URL
    private var storageURL: URL {
        let quotioDir = RuntimeProfile.applicationSupportDirectory()
        try? FileManager.default.createDirectory(at: quotioDir, withIntermediateDirectories: true)
        return quotioDir.appendingPathComponent("request-history.json")
    }
    
    // MARK: - Initialization
    
    private init() {
        loadFromDisk()
        setupMemoryWarningObserver()
    }
    
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.trimHistoryForBackground()
            }
        }
    }
    
    private func trimHistoryForBackground() {
        let reducedLimit = 10
        if store.entries.count > reducedLimit {
            store.entries = Array(store.entries.prefix(reducedLimit))
            requestHistory = store.entries
            stats = store.calculateStats()
            saveToDisk()
            NSLog("[RequestTracker] Trimmed to \(reducedLimit) entries for background")
        }
    }
    
    // MARK: - Public Methods
    
    /// Start tracking (called when proxy starts)
    func start() {
        isActive = true
        NSLog("[RequestTracker] Started tracking")
    }
    
    /// Stop tracking (called when proxy stops)
    func stop() {
        isActive = false
        NSLog("[RequestTracker] Stopped tracking")
    }
    
    /// Add a request from ProxyBridge callback
    func addRequest(from metadata: ProxyBridge.RequestMetadata) {
        let attempts = metadata.fallbackAttempts.isEmpty ? nil : metadata.fallbackAttempts
        let entry = RequestLog(
            timestamp: metadata.timestamp,
            method: metadata.method,
            endpoint: metadata.path,
            provider: metadata.provider,
            model: metadata.model,
            resolvedModel: metadata.resolvedModel,
            resolvedProvider: metadata.resolvedProvider,
            inputTokens: nil,
            outputTokens: nil,
            durationMs: metadata.durationMs,
            statusCode: metadata.statusCode,
            requestSize: metadata.requestSize,
            responseSize: metadata.responseSize,
            errorMessage: metadata.responseSnippet,
            fallbackAttempts: attempts,
            fallbackStartedFromCache: metadata.fallbackStartedFromCache
        )

        addEntry(entry)

        if let routeObserver {
            Task {
                let observation = await routeObserver.observeRoute(
                    requestedProvider: metadata.provider,
                    resolvedProvider: metadata.resolvedProvider
                )

                guard let observation else { return }

                await MainActor.run {
                    self.applyRouteObservation(observation, toEntryID: entry.id)
                }
            }
        }
    }
    
    /// Add a request entry directly
    func addEntry(_ entry: RequestLog) {
        store.addEntry(entry)
        requestHistory = store.entries
        stats = store.calculateStats()
        saveToDisk()
    }
    
    /// Clear all history
    func clearHistory() {
        store = .empty
        requestHistory = []
        stats = .empty
        saveToDisk()
    }

    func configureRouteObserver(baseURL: String, authKey: String) async {
        let observer = RequestRouteObserver(baseURL: baseURL, authKey: authKey)
        await observer.prime()
        routeObserver = observer
    }

    func resetRouteObserver() {
        routeObserver = nil
    }
    
    /// Get requests filtered by provider
    func requests(for provider: String) -> [RequestLog] {
        requestHistory.filter { $0.provider == provider }
    }
    
    /// Get requests from last N minutes
    func recentRequests(minutes: Int) -> [RequestLog] {
        let cutoff = Date().addingTimeInterval(-Double(minutes * 60))
        return requestHistory.filter { $0.timestamp >= cutoff }
    }
    
    // MARK: - Persistence
    
    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            NSLog("[RequestTracker] No history file found, starting fresh")
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Match the encoding strategy
            store = try decoder.decode(RequestHistoryStore.self, from: data)
            requestHistory = store.entries
            stats = store.calculateStats()
            NSLog("[RequestTracker] Loaded \(store.entries.count) entries from disk")
        } catch {
            NSLog("[RequestTracker] Failed to load history: \(error)")
            lastError = error.localizedDescription
            // If decoding fails due to format mismatch, clear the corrupt file
            try? FileManager.default.removeItem(at: storageURL)
            NSLog("[RequestTracker] Removed corrupt history file, starting fresh")
        }
    }
    
    private func saveToDisk() {
        // Capture store snapshot on MainActor to avoid data race
        let storeSnapshot = self.store
        let storageURLSnapshot = self.storageURL

        fileQueue.async {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.outputFormatting = .prettyPrinted

                let data = try encoder.encode(storeSnapshot)
                try data.write(to: storageURLSnapshot)
            } catch {
                NSLog("[RequestTracker] Failed to save history: \(error)")
            }
        }
    }

    private func applyRouteObservation(_ observation: RequestRouteObservation, toEntryID entryID: UUID) {
        guard let index = store.entries.firstIndex(where: { $0.id == entryID }) else { return }
        store.entries[index] = store.entries[index].withRouteObservation(observation)
        requestHistory = store.entries
        stats = store.calculateStats()
        saveToDisk()
    }
}

actor RequestRouteObserver {
    private let client: ManagementAPIClient
    private var lastUpdatedAtByName: [String: Date] = [:]
    private var cachedGlobalProxyURL: String?

    init(baseURL: String, authKey: String) {
        self.client = ManagementAPIClient(baseURL: baseURL, authKey: authKey)
    }

    func prime() async {
        do {
            let files = try await client.fetchAuthFiles()
            updateSnapshot(with: files)
            cachedGlobalProxyURL = try await fetchGlobalProxyURL()
        } catch {
        }
    }

    func observeRoute(requestedProvider: String?, resolvedProvider: String?) async -> RequestRouteObservation? {
        let targetProvider = normalizedProviderName(resolvedProvider ?? requestedProvider)
        guard let targetProvider else { return nil }

        do {
            let files = try await client.fetchAuthFiles()
            let providerFiles = files.filter {
                normalizedProviderName($0.provider) == targetProvider && !$0.disabled && !$0.unavailable
            }
            guard !providerFiles.isEmpty else {
                updateSnapshot(with: files)
                return nil
            }

            let selectedFile = selectObservedFile(from: providerFiles)
            updateSnapshot(with: files)

            guard let selectedFile else { return nil }

            let authFileData = try await client.downloadAuthFile(name: selectedFile.name)
            let accountProxyURL = parseProxyURL(from: authFileData)
            let globalProxyURL: String?
            if let cachedGlobalProxyURL {
                globalProxyURL = cachedGlobalProxyURL
            } else {
                globalProxyURL = try await fetchGlobalProxyURL()
            }
            cachedGlobalProxyURL = globalProxyURL
            let effectiveProxyURL = accountProxyURL ?? globalProxyURL

            return RequestRouteObservation(
                accountName: accountName(for: selectedFile),
                authFileName: selectedFile.name,
                authIndex: selectedFile.authIndex,
                upstreamProxyURL: effectiveProxyURL
            )
        } catch {
            return nil
        }
    }

    private func selectObservedFile(from files: [AuthFile]) -> AuthFile? {
        let changedFiles = files.compactMap { file -> (AuthFile, Date)? in
            guard let updatedAt = parseDate(file.updatedAt) else { return nil }
            let previous = lastUpdatedAtByName[file.name]
            if let previous, updatedAt <= previous {
                return nil
            }
            return (file, updatedAt)
        }

        if let selected = changedFiles.max(by: { $0.1 < $1.1 })?.0 {
            return selected
        }

        return files.max {
            (parseDate($0.updatedAt) ?? .distantPast) < (parseDate($1.updatedAt) ?? .distantPast)
        }
    }

    private func updateSnapshot(with files: [AuthFile]) {
        for file in files {
            if let updatedAt = parseDate(file.updatedAt) {
                lastUpdatedAtByName[file.name] = updatedAt
            }
        }
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }

        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFractional.date(from: value) {
            return date
        }

        let formatterStandard = ISO8601DateFormatter()
        formatterStandard.formatOptions = [.withInternetDateTime]
        return formatterStandard.date(from: value)
    }

    private func parseProxyURL(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rawProxyURL = json["proxy_url"] as? String else {
            return nil
        }

        let trimmed = rawProxyURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func accountName(for file: AuthFile) -> String {
        if let email = file.email, !email.isEmpty {
            return email
        }
        if let account = file.account, !account.isEmpty {
            return account
        }
        return file.name
    }

    private func normalizedProviderName(_ provider: String?) -> String? {
        guard let provider, !provider.isEmpty else { return nil }
        if provider == "copilot" {
            return "github-copilot"
        }
        return provider
    }

    private func fetchGlobalProxyURL() async throws -> String? {
        let proxyURL = try await client.getProxyURL()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return proxyURL.isEmpty ? nil : proxyURL
    }
}
