import SwiftUI

struct CompactSoundIcon: View {
    var color: Color = AppTheme.accentPurple

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 1)
                .frame(width: 48, height: 48)

            Canvas { context, size in
                var wave = Path()
                let y = size.height / 2
                wave.move(to: CGPoint(x: 10, y: y))
                var x: CGFloat = 10
                while x <= size.width - 10 {
                    let progress = (x - 10) / (size.width - 20)
                    let waveY = y + sin(progress * .pi * 3) * 6
                    wave.addLine(to: CGPoint(x: x, y: waveY))
                    x += 2
                }
                context.stroke(wave, with: .color(color), lineWidth: 1.5)
            }
            .frame(width: 48, height: 48)
        }
    }
}
