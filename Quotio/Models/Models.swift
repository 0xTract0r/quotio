//
//  Models.swift
//  Quotio - CLIProxyAPI GUI Wrapper
//

import Foundation
import SwiftUI

enum RuntimeProfile {
    private static let productionBundleIdentifier = "dev.quotio.desktop"
    private static let productionAppSupportDirectory = "Quotio"
    private static let productionAuthDirectory = ".cli-proxy-api"

    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? productionBundleIdentifier
    }

    static var isPrimaryApp: Bool {
        bundleIdentifier == productionBundleIdentifier
    }

    static var applicationSupportDirectoryName: String {
        if isPrimaryApp {
            return productionAppSupportDirectory
        }
        return "Quotio-" + namespaceSuffix
    }

    static func applicationSupportDirectory(fileManager: FileManager = .default) -> URL {
        if let override = stringValue(for: "QUOTIO_APP_SUPPORT_DIR") {
            return URL(fileURLWithPath: override, isDirectory: true)
        }
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Application Support directory not found")
        }
        return appSupport.appendingPathComponent(applicationSupportDirectoryName)
    }

    static var quotioAppSupportDirectory: URL {
        applicationSupportDirectory()
    }

    static var authDirectoryName: String {
        if isPrimaryApp {
            return productionAuthDirectory
        }
        return ".cli-proxy-api-" + namespaceSuffix
    }

    static var authDirectoryPath: String {
        authDirectory.path
    }

    static var authDirectory: URL {
        if let override = stringValue(for: "QUOTIO_AUTH_DIR") {
            return URL(fileURLWithPath: override, isDirectory: true)
        }
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(authDirectoryName, isDirectory: true)
    }

    static var authDirectoryTildePath: String {
        if let override = stringValue(for: "QUOTIO_AUTH_DIR") {
            return override
        }
        return "~/" + authDirectoryName
    }

    static var keychainServicePrefix: String {
        if let namespace = keychainNamespace {
            return bundleIdentifier + "." + namespace
        }
        return bundleIdentifier
    }

    static var defaultProxyPort: Int {
        if let override = intValue(for: "QUOTIO_PROXY_PORT"), override > 0, override < 65536 {
            return override
        }
        return isPrimaryApp ? 18317 : 18017
    }

    static var localManagementKeyOverride: String? {
        stringValue(for: "QUOTIO_LOCAL_MANAGEMENT_KEY")
    }

    static var keychainNamespace: String? {
        stringValue(for: "QUOTIO_KEYCHAIN_NAMESPACE")
    }

    static var operatingModeOverride: OperatingMode? {
        guard let raw = stringValue(for: "QUOTIO_OPERATING_MODE") else { return nil }
        return OperatingMode(rawValue: raw)
    }

    static var autoStartProxyOverride: Bool? {
        boolValue(for: "QUOTIO_AUTO_START_PROXY")
    }

    static var showInDockOverride: Bool? {
        boolValue(for: "QUOTIO_SHOW_IN_DOCK")
    }

    static var skipOnboarding: Bool {
        boolValue(for: "QUOTIO_SKIP_ONBOARDING") ?? false
    }

    static var disableUpdateChecks: Bool {
        boolValue(for: "QUOTIO_DISABLE_UPDATE_CHECKS") ?? false
    }

    static var proxyOnlyTestMode: Bool {
        boolValue(for: "QUOTIO_PROXY_ONLY_TEST_MODE") ?? false
    }

    static var proxyPortOverride: UInt16? {
        guard let value = intValue(for: "QUOTIO_PROXY_PORT"),
              value > 0,
              value < 65536 else {
            return nil
        }
        return UInt16(value)
    }

    static func queueLabel(_ suffix: String) -> String {
        bundleIdentifier + "." + suffix
    }

    private static var namespaceSuffix: String {
        let rawSuffix: String
        if bundleIdentifier.hasPrefix(productionBundleIdentifier + ".") {
            rawSuffix = String(bundleIdentifier.dropFirst(productionBundleIdentifier.count + 1))
        } else {
            rawSuffix = bundleIdentifier
        }

        let sanitized = rawSuffix.replacingOccurrences(
            of: #"[^A-Za-z0-9._-]+"#,
            with: "-",
            options: .regularExpression
        )
        return sanitized.isEmpty ? "test" : sanitized
    }

    private static func stringValue(for key: String) -> String? {
        guard let value = ProcessInfo.processInfo.environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }

    private static func intValue(for key: String) -> Int? {
        guard let value = stringValue(for: key) else { return nil }
        return Int(value)
    }

    private static func boolValue(for key: String) -> Bool? {
        guard let value = stringValue(for: key)?.lowercased() else { return nil }
        switch value {
        case "1", "true", "yes", "on":
            return true
        case "0", "false", "no", "off":
            return false
        default:
            return nil
        }
    }
}

// MARK: - Provider Types

enum AIProvider: String, CaseIterable, Codable, Identifiable {
    case gemini = "gemini-cli"
    case claude = "claude"
    case codex = "codex"
    case qwen = "qwen"
    case iflow = "iflow"
    case antigravity = "antigravity"
    case vertex = "vertex"
    case kiro = "kiro"
    case copilot = "github-copilot"
    case cursor = "cursor"
    case trae = "trae"
    case glm = "glm"
    case warp = "warp"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .gemini: return "Gemini CLI"
        case .claude: return "Claude Code"
        case .codex: return "Codex (OpenAI)"
        case .qwen: return "Qwen Code"
        case .iflow: return "iFlow"
        case .antigravity: return "Antigravity"
        case .vertex: return "Vertex AI"
        case .kiro: return "Kiro (CodeWhisperer)"
        case .copilot: return "GitHub Copilot"
        case .cursor: return "Cursor"
        case .trae: return "Trae"
        case .glm: return "GLM"
        case .warp: return "Warp"
        }
    }
    
    var iconName: String {
        switch self {
        case .gemini: return "sparkles"
        case .claude: return "brain.head.profile"
        case .codex: return "chevron.left.forwardslash.chevron.right"
        case .qwen: return "cloud"
        case .iflow: return "arrow.triangle.branch"
        case .antigravity: return "wand.and.stars"
        case .vertex: return "cube"
        case .kiro: return "cloud.fill"
        case .copilot: return "chevron.left.forwardslash.chevron.right"
        case .cursor: return "cursorarrow.rays"
        case .trae: return "cursorarrow.rays"
        case .glm: return "brain"
        case .warp: return "terminal.fill"
        }
    }
    
    /// Logo file name in ProviderIcons asset catalog
    var logoAssetName: String {
        switch self {
        case .gemini: return "gemini"
        case .claude: return "claude"
        case .codex: return "openai"
        case .qwen: return "qwen"
        case .iflow: return "iflow"
        case .antigravity: return "antigravity"
        case .vertex: return "vertex"
        case .kiro: return "kiro"
        case .copilot: return "copilot"
        case .cursor: return "cursor"
        case .trae: return "trae"
        case .glm: return "glm"
        case .warp: return "warp"
        }
    }
    
    var color: Color {
        switch self {
        case .gemini: return Color(hex: "4285F4") ?? .blue
        case .claude: return Color(hex: "D97706") ?? .orange
        case .codex: return Color(hex: "10A37F") ?? .green
        case .qwen: return Color(hex: "7C3AED") ?? .purple
        case .iflow: return Color(hex: "06B6D4") ?? .cyan
        case .antigravity: return Color(hex: "EC4899") ?? .pink
        case .vertex: return Color(hex: "EA4335") ?? .red
        case .kiro: return Color(hex: "9046FF") ?? .purple
        case .copilot: return Color(hex: "238636") ?? .green
        case .cursor: return Color(hex: "00D4AA") ?? .teal
        case .trae: return Color(hex: "00B4D8") ?? .cyan
        case .glm: return Color(hex: "3B82F6") ?? .blue
        case .warp: return Color(hex: "01E5FF") ?? .cyan
        }
    }
    
    var oauthEndpoint: String {
        switch self {
        case .gemini: return "/gemini-cli-auth-url"
        case .claude: return "/anthropic-auth-url"
        case .codex: return "/codex-auth-url"
        case .qwen: return "/qwen-auth-url"
        case .iflow: return "/iflow-auth-url"
        case .antigravity: return "/antigravity-auth-url"
        case .vertex: return ""
        case .kiro: return ""  // Uses CLI-based auth like Copilot
        case .copilot: return ""
        case .cursor: return ""  // Uses browser session
        case .trae: return ""  // Uses browser session
        case .glm: return ""
        case .warp: return ""
        }
    }
    
    /// Short symbol for menu bar display
    var menuBarSymbol: String {
        switch self {
        case .gemini: return "G"
        case .claude: return "C"
        case .codex: return "O"
        case .qwen: return "Q"
        case .iflow: return "F"
        case .antigravity: return "A"
        case .vertex: return "V"
        case .kiro: return "K"
        case .copilot: return "CP"
        case .cursor: return "CR"
        case .trae: return "TR"
        case .glm: return "G"
        case .warp: return "W"
        }
    }
    
    /// Menu bar icon asset name (nil if should use SF Symbol fallback)
    var menuBarIconAsset: String? {
        switch self {
        case .gemini: return "gemini-menubar"
        case .claude: return "claude-menubar"
        case .codex: return "openai-menubar"
        case .qwen: return "qwen-menubar"
        case .copilot: return "copilot-menubar"
        // These don't have custom icons, use SF Symbols
        case .antigravity: return "antigravity-menubar"
        case .kiro: return "kiro-menubar"
        case .iflow: return "iflow-menubar"
        case .vertex: return "vertex-menubar"
        case .cursor: return "cursor-menubar"
        case .trae: return "trae-menubar"
        case .glm: return "glm-menubar"
        case .warp: return "warp-menubar"
        }
    }
    
    /// Whether this provider supports quota tracking in quota-only mode
    var supportsQuotaOnlyMode: Bool {
        switch self {
        case .claude, .codex, .cursor, .gemini, .antigravity, .copilot, .trae, .glm, .warp:
            return true
        case .qwen, .iflow, .vertex, .kiro:
            return false
        }
    }
    
    /// Whether this provider uses browser cookies for auth
    var usesBrowserAuth: Bool {
        switch self {
        case .cursor, .trae:
            return true
        default:
            return false
        }
    }
    
    /// Whether this provider uses CLI commands for quota
    var usesCLIQuota: Bool {
        switch self {
        case .claude, .codex, .gemini:
            return true
        default:
            return false
        }
    }
    
    /// Map provider to CLI agent (if applicable)
    var cliAgent: CLIAgent? {
        switch self {
        case .claude: return .claudeCode
        case .codex: return .codexCLI
        case .gemini: return .geminiCLI
        default: return nil
        }
    }
    
    /// Whether this provider can be added manually (via OAuth, CLI login, or file import)
    /// Cursor, Trae, Windsurf are excluded because they only read from local app databases
    /// GLM is excluded because it should only be added via Custom Providers
    var supportsManualAuth: Bool {
        switch self {
        case .cursor, .trae, .glm:
            return false  // GLM: only via Custom Providers; Cursor/Trae: only reads from local app database
        default:
            return true
        }
    }

    /// Whether this provider uses API key authentication (stored in CustomProviderService)
    var usesAPIKeyAuth: Bool {
        switch self {
        case .glm, .warp:
            return true
        default:
            return false
        }
    }
    
    /// Whether this provider is quota-tracking only (not a real provider that can route requests)
    var isQuotaTrackingOnly: Bool {
        switch self {
        case .cursor, .trae, .warp:
            return true  // Only for tracking usage, not a provider
        default:
            return false
        }
    }
}

// MARK: - Proxy Status

struct ProxyStatus: Codable {
    var running: Bool = false
    var port: UInt16 = UInt16(RuntimeProfile.defaultProxyPort)
    
    var endpoint: String {
        "http://localhost:\(port)/v1"
    }
}

// MARK: - Auth File (from Management API)

struct AuthFile: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let provider: String
    let label: String?
    let status: String
    let statusMessage: String?
    let disabled: Bool
    let unavailable: Bool
    let runtimeOnly: Bool?
    let source: String?
    let path: String?
    let email: String?
    let accountType: String?
    let account: String?
    let authIndex: String?
    let createdAt: String?
    let updatedAt: String?
    let lastRefresh: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, provider, label, status, disabled, unavailable, source, path, email, account
        case authIndex = "auth_index"
        case statusMessage = "status_message"
        case runtimeOnly = "runtime_only"
        case accountType = "account_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastRefresh = "last_refresh"
    }
    
    var providerType: AIProvider? {
        // Handle "copilot" alias for "github-copilot"
        if provider == "copilot" {
            return .copilot
        }
        return AIProvider(rawValue: provider)
    }
    
    var quotaLookupKey: String {
        if let email = email, !email.isEmpty {
            return email
        }
        if let account = account, !account.isEmpty {
            return account
        }
        var key = name
        if key.hasPrefix("github-copilot-") {
            key = String(key.dropFirst("github-copilot-".count))
        }
        if key.hasSuffix(".json") {
            key = String(key.dropLast(".json".count))
        }
        return key
    }

    var menuBarAccountKey: String {
        let key = quotaLookupKey
        return key.isEmpty ? name : key
    }
    
    var isReady: Bool {
        status == "ready" && !disabled && !unavailable
    }
    
    var statusColor: Color {
        switch status {
        case "ready": return disabled ? .gray : .green
        case "cooling": return .orange
        case "error": return .red
        default: return .gray
        }
    }

    /// Extracts a human-readable message from the status_message field.
    /// The field may contain raw JSON error blobs from providers (e.g., Antigravity/Google).
    var humanReadableStatus: String? {
        guard let msg = statusMessage, !msg.isEmpty else { return nil }

        // If it looks like JSON, try to parse it
        let trimmed = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("{"),
           let data = trimmed.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            return message
        }

        // Already a plain string
        return msg
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(disabled)
        hasher.combine(status)
    }

    static func == (lhs: AuthFile, rhs: AuthFile) -> Bool {
        lhs.id == rhs.id &&
        lhs.disabled == rhs.disabled &&
        lhs.status == rhs.status
    }
}

struct AuthFilesResponse: Codable, Sendable {
    let files: [AuthFile]
}

// MARK: - API Keys (Proxy Service Auth)

struct APIKeysResponse: Codable, Sendable {
    let apiKeys: [String]
    
    enum CodingKeys: String, CodingKey {
        case apiKeys = "api-keys"
    }
}

// MARK: - Usage Statistics

struct UsageStats: Codable, Sendable {
    let usage: UsageData?
    let failedRequests: Int?
    
    enum CodingKeys: String, CodingKey {
        case usage
        case failedRequests = "failed_requests"
    }
}

struct UsageData: Codable, Sendable {
    let totalRequests: Int?
    let successCount: Int?
    let failureCount: Int?
    let totalTokens: Int?
    let inputTokens: Int?
    let outputTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalRequests = "total_requests"
        case successCount = "success_count"
        case failureCount = "failure_count"
        case totalTokens = "total_tokens"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
    
    var successRate: Double {
        guard let total = totalRequests, total > 0, let success = successCount else { return 0 }
        return Double(success) / Double(total) * 100
    }
}

// MARK: - OAuth Flow

struct OAuthURLResponse: Codable, Sendable {
    let status: String
    let url: String?
    let state: String?
    let error: String?
}

struct OAuthStatusResponse: Codable, Sendable {
    let status: String
    let error: String?
}

// MARK: - App Config

struct AppConfig: Codable {
    var host: String = ""
    var port: UInt16 = UInt16(RuntimeProfile.defaultProxyPort)
    var authDir: String = RuntimeProfile.authDirectoryTildePath
    var proxyURL: String = ""
    var apiKeys: [String] = []
    var debug: Bool = false
    var loggingToFile: Bool = false
    var usageStatisticsEnabled: Bool = true
    var requestRetry: Int = 3
    var maxRetryInterval: Int = 30
    var wsAuth: Bool = false
    var routing: RoutingConfig = RoutingConfig()
    var quotaExceeded: QuotaExceededConfig = QuotaExceededConfig()
    var remoteManagement: RemoteManagementConfig = RemoteManagementConfig()
    
    enum CodingKeys: String, CodingKey {
        case host, port, debug, routing
        case authDir = "auth-dir"
        case proxyURL = "proxy-url"
        case apiKeys = "api-keys"
        case loggingToFile = "logging-to-file"
        case usageStatisticsEnabled = "usage-statistics-enabled"
        case requestRetry = "request-retry"
        case maxRetryInterval = "max-retry-interval"
        case wsAuth = "ws-auth"
        case quotaExceeded = "quota-exceeded"
        case remoteManagement = "remote-management"
    }
}

struct RoutingConfig: Codable {
    var strategy: String = "round-robin"
}

struct QuotaExceededConfig: Codable {
    var switchProject: Bool = true
    var switchPreviewModel: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case switchProject = "switch-project"
        case switchPreviewModel = "switch-preview-model"
    }
}

struct RemoteManagementConfig: Codable {
    var allowRemote: Bool = false
    var secretKey: String = ""
    var disableControlPanel: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case allowRemote = "allow-remote"
        case secretKey = "secret-key"
        case disableControlPanel = "disable-control-panel"
    }
}

// MARK: - Log Entry

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let message: String
    
    enum LogLevel: String {
        case info, warn, error, debug
        
        var color: Color {
            switch self {
            case .info: return .primary
            case .warn: return .orange
            case .error: return .red
            case .debug: return .gray
            }
        }
    }
}

// MARK: - Navigation

enum NavigationPage: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case quota = "Quota"
    case providers = "Providers"
    case fallback = "Fallback"
    case agents = "Agents"
    case apiKeys = "API Keys"
    case logs = "Logs"
    case settings = "Settings"
    case about = "About"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.33percent"
        case .quota: return "chart.bar.fill"
        case .providers: return "person.2.badge.key"
        case .fallback: return "arrow.triangle.branch"
        case .agents: return "terminal"
        case .apiKeys: return "key.horizontal"
        case .logs: return "doc.text"
        case .settings: return "gearshape"
        case .about: return "info.circle"
        }
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Formatting Helpers

extension Int {
    var formattedCompact: String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", Double(self) / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", Double(self) / 1_000)
        }
        return "\(self)"
    }
}

// MARK: - Proxy URL Validation

enum ProxyURLValidationResult: Equatable {
    case valid
    case empty
    case invalidScheme
    case invalidURL
    case missingHost
    case missingPort
    case invalidPort
    
    var isValid: Bool {
        self == .valid || self == .empty
    }
    
    var localizationKey: String? {
        switch self {
        case .valid, .empty:
            return nil
        case .invalidScheme:
            return "settings.proxy.error.invalidScheme"
        case .invalidURL:
            return "settings.proxy.error.invalidURL"
        case .missingHost:
            return "settings.proxy.error.missingHost"
        case .missingPort:
            return "settings.proxy.error.missingPort"
        case .invalidPort:
            return "settings.proxy.error.invalidPort"
        }
    }
}

enum ProxyURLValidator {
    static let supportedSchemes = ["socks5", "http", "https"]
    
    static func validate(_ urlString: String) -> ProxyURLValidationResult {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .empty
        }
        
        let hasValidScheme = supportedSchemes.contains { scheme in
            trimmed.lowercased().hasPrefix("\(scheme)://")
        }
        
        guard hasValidScheme else {
            return .invalidScheme
        }
        
        guard let url = URL(string: trimmed) else {
            return .invalidURL
        }
        
        guard let host = url.host, !host.isEmpty else {
            return .missingHost
        }
        
        // socks5 requires explicit port
        if url.scheme?.lowercased() == "socks5" {
            guard let port = url.port else {
                return .missingPort
            }
            guard port >= 1 && port <= 65535 else {
                return .invalidPort
            }
        } else if let port = url.port {
            guard port >= 1 && port <= 65535 else {
                return .invalidPort
            }
        }
        
        return .valid
    }
    
    static func sanitize(_ urlString: String) -> String {
        var trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        while trimmed.hasSuffix("/") {
            trimmed.removeLast()
        }
        
        return trimmed
    }
}
