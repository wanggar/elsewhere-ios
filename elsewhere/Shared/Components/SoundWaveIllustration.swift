import SwiftUI

struct SoundWaveIllustration: View {
    var color: Color = AppTheme.accentPurple

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radii: [CGFloat] = [22, 34, 46, 58]

            for radius in radii {
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                context.stroke(
                    Path(ellipseIn: rect),
                    with: .color(color.opacity(0.55)),
                    lineWidth: 1.2
                )
            }

            var wave = Path()
            let y = center.y
            let startX: CGFloat = 12
            let endX = size.width - 12
            let amplitude: CGFloat = 10
            let wavelength: CGFloat = 52

            wave.move(to: CGPoint(x: startX, y: y))
            var x = startX
            while x <= endX {
                let progress = (x - startX) / (endX - startX)
                let waveY = y + sin(progress * .pi * 4) * amplitude
                wave.addLine(to: CGPoint(x: x, y: waveY))
                x += 2
            }

            context.stroke(wave, with: .color(color), lineWidth: 1.5)
        }
        .frame(height: 120)
    }
}

#Preview {
    SoundWaveIllustration()
        .padding()
        .background(AppTheme.nowPlayingBackground)
}
