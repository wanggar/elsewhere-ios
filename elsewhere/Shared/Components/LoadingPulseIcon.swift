import SwiftUI

struct LoadingPulseIcon: View {
    var logoSize: CGFloat = 120
    @State private var isPulsing = false

    var body: some View {
        ElsewhereLogoView(size: logoSize, cornerRadius: logoSize * 0.12)
            .scaleEffect(isPulsing ? 1.03 : 0.97)
            .opacity(isPulsing ? 1.0 : 0.88)
            .frame(width: logoSize, height: logoSize)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
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
