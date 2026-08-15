import SwiftUI

struct SettingsView: View {
    @Environment(AppearanceManager.self) private var appearanceManager
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 28) {
                    appearanceSection
                    accountSection
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("APPEARANCE")
                .font(AppTheme.labelCaps(11))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            Text("Follows your phone by default. Pick Light or Dark to override.")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Picker("Appearance", selection: Bindable(appearanceManager).preference) {
                ForEach(AppearancePreference.allCases) { preference in
                    Text(preference.title).tag(preference)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ACCOUNT")
                .font(AppTheme.labelCaps(11))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            Button {
                authViewModel.signOut()
                dismiss()
            } label: {
                Text("Sign out")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.red.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(AppTheme.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppearanceManager())
        .environment(AuthViewModel())
}
