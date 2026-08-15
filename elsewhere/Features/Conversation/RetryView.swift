import SwiftUI

struct RetryView: View {
    var onBack: () -> Void
    var onAnotherTry: (String) -> Void

    @State private var feedbackText = ""

    private let suggestions = [
        "it was quieter than that",
        "too generic",
        "missing a person",
        "wrong era",
        "close, but not quite",
    ]

    var body: some View {
        ZStack {
            AppTheme.retryBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        LoadingPulseIcon()
                            .padding(.top, 24)
                            .padding(.bottom, 24)

                        Text("I MISSED SOMETHING")
                            .font(AppTheme.labelCaps(11))
                            .tracking(1.2)
                            .foregroundStyle(AppTheme.retryAccent)
                            .padding(.bottom, 16)

                        Text("What felt off about these three?")
                            .font(AppTheme.serifTitle(30))
                            .foregroundStyle(AppTheme.retryTextPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 14)

                        Text("Anything counts — a detail I missed, a mood that wasn't right, a smell, a person")
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.retryTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                            .padding(.bottom, 28)

                        TextField("", text: $feedbackText, prompt: Text("type or speak...").foregroundStyle(AppTheme.retryTextSecondary.opacity(0.7)).italic(), axis: .vertical)
                            .font(.system(size: 17))
                            .foregroundStyle(AppTheme.retryTextPrimary)
                            .lineLimit(3...6)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background(AppTheme.retryInputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal, 24)

                        suggestionsSection
                            .padding(.top, 28)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }
                }

                bottomBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
    }

    private var backButton: some View {
        Button(action: onBack) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 14, weight: .medium))
                Text("back to the three")
                    .font(.system(size: 16))
            }
            .foregroundStyle(AppTheme.retryTextSecondary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("OR SOMEWHERE TO START")
                .font(AppTheme.labelCaps(10))
                .tracking(1.2)
                .foregroundStyle(AppTheme.retryTextSecondary)

            FlowLayout(spacing: 10) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        feedbackText = suggestion
                    } label: {
                        Text(suggestion)
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.retryTextPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .overlay {
                                Capsule()
                                    .stroke(AppTheme.retryChipBorder, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bottomBar: some View {
        HStack {
            Spacer()

            Button {
                onAnotherTry(feedbackText)
            } label: {
                Text("another try")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.retryBackground)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(AppTheme.retryTextPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    RetryView(onBack: {}, onAnotherTry: { _ in })
}
