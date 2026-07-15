import SwiftUI

struct LoadingPulseIcon: View {
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            ForEach(Array([36.0, 52.0, 68.0].enumerated()), id: \.offset) { index, radius in
                Circle()
                    .stroke(AppTheme.pulsePurple.opacity(0.35 - Double(index) * 0.08), lineWidth: 1)
                    .frame(width: radius, height: radius)
                    .scaleEffect(isPulsing ? 1.06 : 0.94)
                    .opacity(isPulsing ? 0.9 : 0.55)
            }

            Circle()
                .fill(AppTheme.pulsePurple)
                .frame(width: 10, height: 10)
        }
        .frame(width: 80, height: 80)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    LoadingPulseIcon()
        .padding()
        .background(AppTheme.loadingBackground)
}
