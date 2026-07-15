import SwiftUI

struct SoundGenerationView: View {
    let checklist: GenerationChecklist

    @State private var revealedCount = 0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                LoadingPulseIcon()
                    .padding(.bottom, 28)

                Text("COMPOSING YOUR SOUND")
                    .font(AppTheme.labelCaps(11))
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.pulsePurple)
                    .padding(.bottom, 12)

                Text("Putting the pieces together...")
                    .font(AppTheme.serifTitle(28))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 36)

                checklistCard
                    .padding(.horizontal, 24)

                Spacer()

                Text("a few seconds — worth it")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textMuted)
                    .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
        .task(id: checklist.items.map(\.text).joined()) {
            revealedCount = 0
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.1))
                let completeFromServer = checklist.items.filter { $0.state == .complete }.count
                let target = max(completeFromServer, min(revealedCount + 1, checklist.items.count))
                if target == revealedCount, completeFromServer == checklist.items.count {
                    break
                }
                withAnimation(.easeInOut(duration: 0.25)) {
                    revealedCount = target
                }
            }
        }
    }

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("FROM WHAT YOU SHARED")
                .font(AppTheme.labelCaps(10))
                .tracking(1.2)
                .foregroundStyle(AppTheme.textMuted)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(checklist.items.enumerated()), id: \.element.id) { index, item in
                    let state = displayState(for: index, item: item)
                    HStack(alignment: .top, spacing: 10) {
                        if state == .complete {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(AppTheme.pulsePurple)
                                .frame(width: 14, height: 14)
                                .padding(.top, 4)
                        } else {
                            Color.clear
                                .frame(width: 14, height: 14)
                                .padding(.top, 4)
                        }

                        Text(item.text)
                            .font(AppTheme.serifItalic(17))
                            .foregroundStyle(textColor(for: state))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(AppTheme.convoSummaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func displayState(for index: Int, item: GenerationChecklist.Item) -> GenerationItemState {
        if item.state == .complete || index < revealedCount {
            return .complete
        }
        if index == revealedCount {
            return .inProgress
        }
        return .pending
    }

    private func textColor(for state: GenerationItemState) -> Color {
        switch state {
        case .complete, .inProgress:
            AppTheme.textPrimary
        case .pending:
            AppTheme.textMuted.opacity(0.6)
        }
    }
}

#Preview {
    SoundGenerationView(checklist: .placeholder)
}
