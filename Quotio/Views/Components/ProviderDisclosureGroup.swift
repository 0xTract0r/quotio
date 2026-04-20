//
//  ProviderDisclosureGroup.swift
//  Quotio
//
//  Collapsible group for displaying accounts grouped by provider.
//  Part of ProvidersScreen UI/UX redesign.
//

import SwiftUI

// MARK: - Provider Disclosure Group

/// A collapsible disclosure group that displays all accounts for a specific provider
struct ProviderDisclosureGroup: View {
    let provider: AIProvider
    let accounts: [AccountRowData]
    var onMoveAccount: ((IndexSet, Int) -> Void)?
    var onDeleteAccount: ((AccountRowData) -> Void)?
    var onEditAccount: ((AccountRowData) -> Void)?
    var onConfigureSettings: ((AccountRowData) -> Void)?
    var onSwitchAccount: ((AccountRowData) -> Void)?
    var onToggleDisabled: ((AccountRowData) -> Void)?
    var onManageIdentityBinding: ((AccountRowData) -> Void)?
    var onUnbindIdentityBinding: ((AccountRowData) -> Void)?
    var isAccountActive: ((AccountRowData) -> Bool)?

    @State private var isExpanded: Bool = true

    /// Check if all accounts in this group are auto-detected
    private var isAllAutoDetected: Bool {
        accounts.allSatisfy { $0.source == .autoDetected }
    }

    private var alertingAccounts: [AccountRowData] {
        accounts
            .filter(\.shouldSurfaceLiveAlert)
            .sorted { severityRank(for: $0) > severityRank(for: $1) }
    }

    private var providerAlertLevel: AccountLiveAlertLevel? {
        alertingAccounts.first?.liveAlertLevel
    }

    private var providerAlertBadgeText: String? {
        guard let providerAlertLevel else { return nil }
        return providerAlertLevel.badgeCountText(count: alertingAccounts.count)
    }

    private var providerAlertHelpText: String? {
        let lines = alertingAccounts.compactMap { account -> String? in
            guard let summary = account.liveAlertSummary else { return nil }
            return account.primaryDisplayTitle + "： " + summary
        }
        guard !lines.isEmpty else { return nil }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(accounts) { account in
                AccountRow(
                    account: account,
                    onDelete: onDeleteAccount != nil ? { onDeleteAccount?(account) } : nil,
                    onEdit: onEditAccount != nil ? { onEditAccount?(account) } : nil,
                    onConfigureSettings: onConfigureSettings != nil ? { onConfigureSettings?(account) } : nil,
                    onSwitch: onSwitchAccount != nil ? { onSwitchAccount?(account) } : nil,
                    onToggleDisabled: onToggleDisabled != nil ? { onToggleDisabled?(account) } : nil,
                    onManageIdentityBinding: onManageIdentityBinding != nil ? { onManageIdentityBinding?(account) } : nil,
                    onUnbindIdentityBinding: onUnbindIdentityBinding != nil ? { onUnbindIdentityBinding?(account) } : nil,
                    isActiveInIDE: isAccountActive?(account) ?? false
                )
                .padding(.leading, 4)
            }
            .onMove(perform: onMoveAccount)
        } label: {
            providerHeader
        }
    }
    
    // MARK: - Provider Header
    
    private var providerHeader: some View {
        HStack(spacing: 10) {
            // Provider icon
            ProviderIcon(provider: provider, size: 20)
            
            // Provider name
            Text(provider.displayName)
                .fontWeight(.medium)
            
            // Account count badge
            Text("\(accounts.count)")
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(provider.color.opacity(0.15))
                .foregroundStyle(provider.color)
                .clipShape(Capsule())
            
            Spacer()

            if let providerAlertLevel {
                HStack(spacing: 6) {
                    Circle()
                        .fill(providerAlertLevel.color)
                        .frame(width: 8, height: 8)
                    Text(providerAlertBadgeText ?? "1")
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(providerAlertLevel.color)
                .help(providerAlertHelpText ?? "")
            }
            
            // Auto-detected indicator (when all accounts are auto-detected)
            if isAllAutoDetected {
                Text("providers.autoDetected".localized())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }

    private func severityRank(for account: AccountRowData) -> Int {
        switch account.liveAlertLevel {
        case .error:
            return 2
        case .warning:
            return 1
        case nil:
            return 0
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        ProviderDisclosureGroup(
            provider: .gemini,
            accounts: [
                AccountRowData(
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
                AccountRowData(
                    id: "2",
                    provider: .gemini,
                    displayName: "work@company.com",
                    source: .proxy,
                    status: "cooling",
                    statusMessage: "Rate limited",
                    isDisabled: false,
                    canToggleDisabled: true,
                    canDelete: true
                )
            ]
        )
        
        ProviderDisclosureGroup(
            provider: .cursor,
            accounts: [
                AccountRowData(
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
            ]
        )
    }
}
