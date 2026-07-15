import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.10, green: 0.10, blue: 0.10)
    static let loadingBackground = Color(red: 0.17, green: 0.17, blue: 0.17)
    static let surfaceBorder = Color(red: 0.22, green: 0.22, blue: 0.22)
    static let cardSurface = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let playerCardSurface = Color(red: 0.18, green: 0.18, blue: 0.18)

    static let nowPlayingBackground = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let accentPurple = Color(red: 0.21, green: 0.21, blue: 0.43)
    static let accentPurpleLight = Color(red: 0.55, green: 0.55, blue: 0.72)
    static let pulsePurple = Color(red: 0.45, green: 0.38, blue: 0.78)
    static let playBlue = Color(red: 0.36, green: 0.48, blue: 0.62)
    static let progressTrack = Color(red: 0.24, green: 0.24, blue: 0.24)
    static let creamButton = Color(red: 0.96, green: 0.95, blue: 0.92)

    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.63)
    static let textMuted = Color(red: 0.50, green: 0.50, blue: 0.50)

    static let profileBackground = Color(red: 0.18, green: 0.18, blue: 0.18)

    static let sleepCardBackground = Color(red: 0.94, green: 0.94, blue: 0.98)
    static let focusCardBackground = Color(red: 0.85, green: 0.93, blue: 0.89)
    static let focusText = Color(red: 0.18, green: 0.35, blue: 0.28)
    static let relaxCardBackground = Color(red: 0.96, green: 0.91, blue: 0.86)
    static let relaxText = Color(red: 0.42, green: 0.29, blue: 0.23)
    static let upliftCardBackground = Color(red: 0.96, green: 0.86, blue: 0.90)
    static let upliftText = Color(red: 0.42, green: 0.23, blue: 0.29)
    static let moveCardBackground = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let convoSummaryBackground = Color(red: 0.14, green: 0.14, blue: 0.14)
    static let inputBorder = Color(red: 0.45, green: 0.42, blue: 0.58)

    static let retryBackground = Color.white
    static let retryInputBackground = Color(red: 0.97, green: 0.96, blue: 0.94)
    static let retryTextPrimary = Color.black
    static let retryTextSecondary = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let retryAccent = Color(red: 0.36, green: 0.36, blue: 0.78)
    static let retryChipBorder = Color(red: 0.82, green: 0.82, blue: 0.82)

    static let immersiveBackgroundTop = Color(red: 0.14, green: 0.12, blue: 0.28)
    static let immersiveBackgroundBottom = Color(red: 0.08, green: 0.07, blue: 0.16)
    static let immersiveGlow = Color(red: 0.85, green: 0.55, blue: 0.25)
    static let immersiveWindowGlow = Color(red: 0.95, green: 0.78, blue: 0.45)

    static func serifTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif).italic()
    }

    static func labelCaps(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
}
