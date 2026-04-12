//
//  AccountRow.swift
//  Quotio
//
//  Unified account row component for ProvidersScreen.
//  Replaces: AuthFileRow, DirectAuthFileRow, AutoDetectedAccountRow
//

import SwiftUI

/// Represents the source/type of an account for display purposes
enum AccountSource: Equatable {
    case proxy           // From proxy API (AuthFile)
    case direct          // From disk auth files (DirectAuthFile)
    case autoDetected    // Auto-detected from IDE (Cursor, Trae)
    
    var displayName: String {
        switch self {
        case .proxy: return "providers.source.proxy".localizedStatic()
        case .direct: return "providers.source.disk".localizedStatic()
        case .autoDetected: return "providers.autoDetected".localizedStatic()
        }
    }
}

/// Unified data model for account display
struct AccountRowData: Identifiable, Hashable {
    let id: String
    let provider: AIProvider
    let displayName: String       // Email or account identifier
    let menuBarAccountKey: String
    let metadataKey: String
    let remark: String?
    let source: AccountSource
    let status: String?           // "ready", "cooling", "error", etc.
    let statusMessage: String?
    let isDisabled: Bool
    let hasConfiguredProxy: Bool
    let canToggleDisabled: Bool
    let canDelete: Bool           // Only proxy accounts can be deleted
    let canEdit: Bool             // Whether this account can be edited (GLM only)
    let canSwitch: Bool           // Whether this account can be switched (Antigravity only)
    let identityPackage: RuntimeIdentityPackage?
    let supportsIdentityBinding: Bool

    // Custom initializer to handle canEdit parameter
    init(
        id: String,
        provider: AIProvider,
        displayName: String,
        menuBarAccountKey: String? = nil,
        metadataKey: String? = nil,
        remark: String? = nil,
        source: AccountSource,
        status: String?,
        statusMessage: String?,
        isDisabled: Bool,
        hasConfiguredProxy: Bool = false,
        canToggleDisabled: Bool,
        canDelete: Bool,
        canEdit: Bool = false,
        canSwitch: Bool = false,
        identityPackage: RuntimeIdentityPackage? = nil,
        supportsIdentityBinding: Bool = false
    ) {
        self.id = id
        self.provider = provider
        self.displayName = displayName
        self.menuBarAccountKey = menuBarAccountKey ?? displayName
        self.metadataKey = metadataKey ?? id
        let trimmedRemark = remark?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.remark = (trimmedRemark?.isEmpty == false) ? trimmedRemark : nil
        self.source = source
        self.status = status
        self.statusMessage = statusMessage
        self.isDisabled = isDisabled
        self.hasConfiguredProxy = hasConfiguredProxy
        self.canToggleDisabled = canToggleDisabled
        self.canDelete = canDelete
        self.canEdit = canEdit
        self.canSwitch = canSwitch
        self.identityPackage = identityPackage
        self.supportsIdentityBinding = supportsIdentityBinding
    }

    // For menu bar selection
    var menuBarItem: MenuBarQuotaItem {
        MenuBarQuotaItem(provider: provider.rawValue, accountKey: menuBarAccountKey)
    }

    var canConfigureProxy: Bool {
        switch source {
        case .proxy, .direct:
            return provider != .glm && provider != .warp
        case .autoDetected:
            return false
        }
    }

    // MARK: - Factory Methods
    
    /// Create from AuthFile (proxy mode)
    static func from(
        authFile: AuthFile,
        metadataKey: String? = nil,
        remark: String? = nil,
        hasConfiguredProxy: Bool = false,
        identityPackage: RuntimeIdentityPackage? = nil
    ) -> AccountRowData {
        let name = authFile.email ?? authFile.name
        return AccountRowData(
            id: authFile.id,
            provider: authFile.providerType ?? .gemini,
            displayName: name,
            menuBarAccountKey: authFile.menuBarAccountKey,
            metadataKey: metadataKey,
            remark: remark,
            source: .proxy,
            status: authFile.status,
            statusMessage: authFile.statusMessage,
            isDisabled: authFile.disabled,
            hasConfiguredProxy: hasConfiguredProxy,
            canToggleDisabled: true,
            canDelete: true,
            identityPackage: identityPackage,
            supportsIdentityBinding: true
        )
    }
    
    /// Create from DirectAuthFile (quota-only mode or proxy stopped)
    static func from(directAuthFile: DirectAuthFile, metadataKey: String? = nil, remark: String? = nil) -> AccountRowData {
        let name = directAuthFile.email ?? directAuthFile.filename
        return AccountRowData(
            id: directAuthFile.id,
            provider: directAuthFile.provider,
            displayName: name,
            menuBarAccountKey: directAuthFile.menuBarAccountKey,
            metadataKey: metadataKey,
            remark: remark,
            source: .direct,
            status: nil,
            statusMessage: nil,
            isDisabled: directAuthFile.isDisabled,
            hasConfiguredProxy: directAuthFile.proxyURL != nil,
            canToggleDisabled: true,
            canDelete: true
        )
    }
    
    /// Create from auto-detected account (Cursor, Trae)
    static func from(provider: AIProvider, accountKey: String, metadataKey: String? = nil, remark: String? = nil) -> AccountRowData {
        AccountRowData(
            id: "\(provider.rawValue)_\(accountKey)",
            provider: provider,
            displayName: accountKey,
            menuBarAccountKey: accountKey,
            metadataKey: metadataKey,
            remark: remark,
            source: .autoDetected,
            status: nil,
            statusMessage: nil,
            isDisabled: false,
            hasConfiguredProxy: false,
            canToggleDisabled: false,
            canDelete: false
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isDisabled)
        hasher.combine(status)
        hasher.combine(remark)
        hasher.combine(hasConfiguredProxy)
        hasher.combine(identityPackage)
        hasher.combine(supportsIdentityBinding)
    }

    static func == (lhs: AccountRowData, rhs: AccountRowData) -> Bool {
        lhs.id == rhs.id &&
        lhs.isDisabled == rhs.isDisabled &&
        lhs.status == rhs.status &&
        lhs.remark == rhs.remark &&
        lhs.hasConfiguredProxy == rhs.hasConfiguredProxy &&
        lhs.identityPackage == rhs.identityPackage &&
        lhs.supportsIdentityBinding == rhs.supportsIdentityBinding
    }
}

// MARK: - AccountRow View

struct AccountRow: View {
    let account: AccountRowData
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    var onConfigureSettings: (() -> Void)?
    var onSwitch: (() -> Void)?
    var onToggleDisabled: (() -> Void)?
    var onManageIdentityBinding: (() -> Void)?
    var onUnbindIdentityBinding: (() -> Void)?
    var isActiveInIDE: Bool = false
    
    @State private var settings = MenuBarSettingsManager.shared
    @State private var showWarning = false
    @State private var showMaxItemsAlert = false
    @State private var showDeleteConfirmation = false
    
    private var isMenuBarSelected: Bool {
        settings.isSelected(account.menuBarItem)
    }
    
    private var maskedDisplayName: String {
        account.displayName.masked(if: settings.hideSensitiveInfo)
    }

    private var displayTitle: String {
        account.remark ?? maskedDisplayName
    }

    private var hasRemark: Bool {
        guard let remark = account.remark else { return false }
        return !remark.isEmpty
    }
    
    private var statusColor: Color {
        switch account.status {
        case "ready": return account.isDisabled ? .gray : .green
        case "cooling": return .orange
        case "error": return .red
        default: return .gray
        }
    }

    private var identityBadgeText: String {
        account.identityPackage?.name ?? "Unbound identity package"
    }

    private var identityBadgeColor: Color {
        guard account.supportsIdentityBinding else { return .secondary }
        guard let package = account.identityPackage else { return .orange }

        switch package.status {
        case .bound:
            return .green
        case .verificationFailed, .blocked:
            return .red
        case .available, .draft:
            return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Provider icon
            ProviderIcon(provider: account.provider, size: 24)
            
            // Account info
            VStack(alignment: .leading, spacing: 2) {
                Text(displayTitle)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if hasRemark {
                        Text(maskedDisplayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    // Provider name
                    Text(account.provider.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Status indicator (only for proxy accounts)
                    if let status = account.status {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(statusColor)
                    } else {
                        // Source indicator for non-proxy accounts
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        
                        Text(account.source.displayName)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                if account.supportsIdentityBinding {
                    HStack(spacing: 6) {
                        Image(systemName: account.identityPackage == nil ? "shield.slash" : "shield.fill")
                            .foregroundStyle(identityBadgeColor)

                        Text(identityBadgeText)
                            .font(.caption)
                            .foregroundStyle(account.identityPackage == nil ? .secondary : .primary)

                        if let package = account.identityPackage {
                            Text(package.status.displayName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(identityBadgeColor.opacity(0.12))
                                .foregroundStyle(identityBadgeColor)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Spacer()
            
            // Disabled badge
            if account.isDisabled {
                Text("providers.disabled".localized())
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            // Active in IDE badge (Antigravity only)
            if account.provider == .antigravity && isActiveInIDE {
                Text("antigravity.active".localized())
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(red: 0.13, green: 0.55, blue: 0.13))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.85, green: 0.95, blue: 0.85))
                    .clipShape(Capsule())
            }
            
            // Switch button (Antigravity only, for proxy/direct accounts that are not active)
            if account.provider == .antigravity && !isActiveInIDE && account.source != .autoDetected {
                Button {
                    onSwitch?()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.caption2)
                        Text("antigravity.useInIDE".localized())
                            .font(.caption2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .help("antigravity.switch.title".localized())
            }
            
            // Menu bar toggle
            MenuBarBadge(
                isSelected: isMenuBarSelected,
                onTap: handleMenuBarToggle
            )

            if account.supportsIdentityBinding, let onManageIdentityBinding = onManageIdentityBinding {
                Button {
                    onManageIdentityBinding()
                } label: {
                    Image(systemName: account.identityPackage == nil ? "shield" : "arrow.triangle.2.circlepath")
                        .foregroundStyle(account.identityPackage == nil ? Color.secondary : .blue)
                }
                .buttonStyle(.rowAction)
                .help(account.identityPackage == nil ? "Bind identity package" : "Change identity package")
            }

            if account.identityPackage != nil, let onUnbindIdentityBinding = onUnbindIdentityBinding {
                Button(role: .destructive) {
                    onUnbindIdentityBinding()
                } label: {
                    Image(systemName: "shield.slash")
                        .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.rowActionDestructive)
                .help("Unbind identity package")
            }

            // Disable/Enable toggle button (only for proxy accounts)
            if account.canToggleDisabled, let onToggleDisabled = onToggleDisabled {
                Button {
                    onToggleDisabled()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(account.isDisabled ? Color.red.opacity(0.1) : Color.green.opacity(0.14))
                            .frame(width: 28, height: 28)

                        Image(systemName: account.isDisabled ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(account.isDisabled ? .red : .green)
                    }
                }
                .buttonStyle(.rowAction)
                .help(account.isDisabled ? "providers.enable".localized() : "providers.disable".localized())
                .accessibilityLabel(account.isDisabled ? "providers.enable".localized() : "providers.disable".localized())
            }

            // Edit button (GLM only)
            if account.canEdit, let onEdit = onEdit {
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.rowAction)
                .help("action.edit".localized())
            }

            if account.canConfigureProxy, let onConfigureSettings = onConfigureSettings {
                Button {
                    onConfigureSettings()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(account.hasConfiguredProxy ? Color.blue.opacity(0.1) : Color.clear)
                            .frame(width: 28, height: 28)

                        Image(systemName: "network")
                            .font(.system(size: 14))
                            .foregroundStyle(account.hasConfiguredProxy ? .blue : .secondary)
                    }
                }
                .buttonStyle(.rowAction)
                .help(account.hasConfiguredProxy ? "providers.accountSettings.proxyConfigured".localized() : "providers.accountSettings.proxyNotConfigured".localized())
                .accessibilityLabel("providers.accountSettings.edit".localized())
            } else if let onConfigureSettings = onConfigureSettings {
                Button {
                    onConfigureSettings()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(hasRemark ? Color.orange.opacity(0.12) : Color.clear)
                            .frame(width: 28, height: 28)

                        Image(systemName: "note.text")
                            .font(.system(size: 14))
                            .foregroundStyle(hasRemark ? .orange : .secondary)
                    }
                }
                .buttonStyle(.rowAction)
                .help("providers.accountSettings.edit".localized())
                .accessibilityLabel("providers.accountSettings.edit".localized())
            }

            // Delete button (only for proxy accounts)
            if account.canDelete, onDelete != nil {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.rowActionDestructive)
                .help("action.delete".localized())
            }
        }
        .contentShape(Rectangle())
        .contextMenu {
            // Switch account option (Antigravity only)
            if account.provider == .antigravity && !isActiveInIDE && account.source != .autoDetected {
                Button {
                    onSwitch?()
                } label: {
                    Label("antigravity.switch.title".localized(), systemImage: "arrow.triangle.2.circlepath")
                }
                
                Divider()
            }
            
            // Menu bar toggle
            Button {
                handleMenuBarToggle()
            } label: {
                if isMenuBarSelected {
                    Label("menubar.hideFromMenuBar".localized(), systemImage: "chart.bar")
                } else {
                    Label("menubar.showOnMenuBar".localized(), systemImage: "chart.bar.fill")
                }
            }

            if account.supportsIdentityBinding, let onManageIdentityBinding = onManageIdentityBinding {
                Button {
                    onManageIdentityBinding()
                } label: {
                    Label(
                        account.identityPackage == nil ? "Bind identity package" : "Change identity package",
                        systemImage: account.identityPackage == nil ? "shield" : "arrow.triangle.2.circlepath"
                    )
                }

                if account.identityPackage != nil, let onUnbindIdentityBinding = onUnbindIdentityBinding {
                    Button(role: .destructive) {
                        onUnbindIdentityBinding()
                    } label: {
                        Label("Unbind identity package", systemImage: "shield.slash")
                    }
                }

                Divider()
            }

            // Disable/Enable toggle (only for proxy accounts)
            if account.canToggleDisabled, let onToggleDisabled = onToggleDisabled {
                Button {
                    onToggleDisabled()
                } label: {
                    if account.isDisabled {
                        Label("providers.enable".localized(), systemImage: "checkmark.circle")
                    } else {
                        Label("providers.disable".localized(), systemImage: "minus.circle")
                    }
                }
            }

            // Delete option (only for proxy accounts)
            if account.canDelete, onDelete != nil {
                Divider()
                
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("action.delete".localized(), systemImage: "trash")
                }
            }

            if let onConfigureSettings = onConfigureSettings {
                Button {
                    onConfigureSettings()
                } label: {
                    Label(
                        "providers.accountSettings.edit".localized(),
                        systemImage: account.canConfigureProxy ? "network" : "note.text"
                    )
                }
            }
        }
        .confirmationDialog("providers.deleteConfirm".localized(), isPresented: $showDeleteConfirmation) {
            Button("action.delete".localized(), role: .destructive) {
                onDelete?()
            }
            Button("action.cancel".localized(), role: .cancel) {}
        } message: {
            Text("providers.deleteMessage".localized())
        }
        .alert("menubar.warning.title".localized(), isPresented: $showWarning) {
            Button("menubar.warning.confirm".localized()) {
                settings.toggleItem(account.menuBarItem)
            }
            Button("menubar.warning.cancel".localized(), role: .cancel) {}
        } message: {
            Text("menubar.warning.message".localized())
        }
        .alert("menubar.maxItems.title".localized(), isPresented: $showMaxItemsAlert) {
            Button("action.ok".localized(), role: .cancel) {}
        } message: {
            Text(String(
                format: "menubar.maxItems.message".localized(),
                settings.menuBarMaxItems
            ))
        }
    }
    
    private func handleMenuBarToggle() {
        if isMenuBarSelected {
            settings.toggleItem(account.menuBarItem)
        } else if settings.isAtMaxItems {
            showMaxItemsAlert = true
        } else if settings.shouldWarnOnAdd {
            showWarning = true
        } else {
            settings.toggleItem(account.menuBarItem)
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        AccountRow(
            account: AccountRowData(
                id: "1",
                provider: .gemini,
                displayName: "user@gmail.com",
                source: .proxy,
                status: "ready",
                statusMessage: nil,
                isDisabled: false,
                canToggleDisabled: true,
                canDelete: true
            ),
            onDelete: {}
        )
        
        AccountRow(
            account: AccountRowData(
                id: "2",
                provider: .claude,
                displayName: "work@company.com",
                source: .direct,
                status: nil,
                statusMessage: nil,
                isDisabled: false,
                canToggleDisabled: true,
                canDelete: true
            )
        )
        
        AccountRow(
            account: AccountRowData(
                id: "3",
                provider: .cursor,
                displayName: "dev@example.com",
                source: .autoDetected,
                status: nil,
                statusMessage: nil,
                isDisabled: false,
                canToggleDisabled: false,
                canDelete: false
            )
        )
    }
}
