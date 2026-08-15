import SwiftUI

struct ElsewhereLogoView: View {
    var size: CGFloat = 200
    var cornerRadius: CGFloat = 0

    var body: some View {
        Image("ElsewhereLogo")
            .resizable()
            .interpolation(.high)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .accessibilityLabel("Elsewhere")
    }
}

#Preview {
    VStack(spacing: 24) {
        ElsewhereLogoView(size: 220, cornerRadius: 24)
        ElsewhereLogoView(size: 80, cornerRadius: 16)
    }
    .padding()
    .background(Color.black)
}
