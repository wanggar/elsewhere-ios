import SwiftUI

enum AppTheme {
    // MARK: - Surfaces

    static let background = Color(
        light: Color(red: 0.97, green: 0.97, blue: 0.96),
        dark: Color(red: 0.10, green: 0.10, blue: 0.10)
    )

    static let loadingBackground = Color(
        light: Color(red: 0.95, green: 0.95, blue: 0.94),
        dark: Color(red: 0.17, green: 0.17, blue: 0.17)
    )

    static let surfaceBorder = Color(
        light: Color(red: 0.86, green: 0.86, blue: 0.85),
        dark: Color(red: 0.22, green: 0.22, blue: 0.22)
    )

    static let cardSurface = Color(
        light: Color(red: 1.0, green: 1.0, blue: 1.0),
        dark: Color(red: 0.15, green: 0.15, blue: 0.15)
    )

    static let playerCardSurface = Color(
        light: Color(red: 0.92, green: 0.92, blue: 0.91),
        dark: Color(red: 0.18, green: 0.18, blue: 0.18)
    )

    static let profileBackground = Color(
        light: Color(red: 0.90, green: 0.90, blue: 0.89),
        dark: Color(red: 0.18, green: 0.18, blue: 0.18)
    )

    static let convoSummaryBackground = Color(
        light: Color(red: 0.93, green: 0.93, blue: 0.92),
        dark: Color(red: 0.14, green: 0.14, blue: 0.14)
    )

    // MARK: - Text

    static let textPrimary = Color(
        light: Color(red: 0.08, green: 0.08, blue: 0.08),
        dark: Color.white
    )

    static let textSecondary = Color(
        light: Color(red: 0.40, green: 0.40, blue: 0.40),
        dark: Color(red: 0.63, green: 0.63, blue: 0.63)
    )

    static let textMuted = Color(
        light: Color(red: 0.55, green: 0.55, blue: 0.55),
        dark: Color(red: 0.50, green: 0.50, blue: 0.50)
    )

    // MARK: - Accents & controls

    static let nowPlayingBackground = Color(red: 0.94, green: 0.94, blue: 0.98)
    static let accentPurple = Color(red: 0.21, green: 0.21, blue: 0.43)
    static let accentPurpleLight = Color(red: 0.55, green: 0.55, blue: 0.72)
    static let pulsePurple = Color(red: 0.45, green: 0.38, blue: 0.78)
    static let playBlue = Color(red: 0.36, green: 0.48, blue: 0.62)

    static let progressTrack = Color(
        light: Color(red: 0.82, green: 0.82, blue: 0.81),
        dark: Color(red: 0.24, green: 0.24, blue: 0.24)
    )

    /// Cream CTA background — same in both modes for brand consistency.
    static let creamButton = Color(red: 0.96, green: 0.95, blue: 0.92)

    /// Dark label on cream / light filled buttons.
    static let ctaForeground = Color(red: 0.08, green: 0.08, blue: 0.08).opacity(0.85)

    /// Icon/text on saturated accent fills (play button, etc.).
    static let onAccent = Color.white

    static let inputBorder = Color(
        light: Color(red: 0.72, green: 0.70, blue: 0.78),
        dark: Color(red: 0.45, green: 0.42, blue: 0.58)
    )

    // MARK: - Mode cards (pastel surfaces stay readable in both appearances)

    static let sleepCardBackground = Color(red: 0.94, green: 0.94, blue: 0.98)
    static let focusCardBackground = Color(red: 0.85, green: 0.93, blue: 0.89)
    static let focusText = Color(red: 0.18, green: 0.35, blue: 0.28)
    static let relaxCardBackground = Color(red: 0.96, green: 0.91, blue: 0.86)
    static let relaxText = Color(red: 0.42, green: 0.29, blue: 0.23)
    static let upliftCardBackground = Color(red: 0.96, green: 0.86, blue: 0.90)
    static let upliftText = Color(red: 0.42, green: 0.23, blue: 0.29)

    static let moveCardBackground = Color(
        light: Color(red: 0.18, green: 0.18, blue: 0.18),
        dark: Color(red: 0.15, green: 0.15, blue: 0.15)
    )

    static let moveCardText = Color.white
    static let moveCardSecondaryText = Color.white.opacity(0.7)

    // MARK: - Retry / feedback (adaptive, formerly always-light)

    static let retryBackground = Color(
        light: Color.white,
        dark: Color(red: 0.10, green: 0.10, blue: 0.10)
    )

    static let retryInputBackground = Color(
        light: Color(red: 0.97, green: 0.96, blue: 0.94),
        dark: Color(red: 0.16, green: 0.16, blue: 0.16)
    )

    static let retryTextPrimary = Color(
        light: Color.black,
        dark: Color.white
    )

    static let retryTextSecondary = Color(
        light: Color(red: 0.45, green: 0.45, blue: 0.45),
        dark: Color(red: 0.63, green: 0.63, blue: 0.63)
    )

    static let retryAccent = Color(red: 0.36, green: 0.36, blue: 0.78)

    static let retryChipBorder = Color(
        light: Color(red: 0.82, green: 0.82, blue: 0.82),
        dark: Color(red: 0.32, green: 0.32, blue: 0.32)
    )

    // MARK: - Immersive playback

    static let immersiveBackgroundTop = Color(
        light: Color(red: 0.88, green: 0.86, blue: 0.94),
        dark: Color(red: 0.14, green: 0.12, blue: 0.28)
    )

    static let immersiveBackgroundBottom = Color(
        light: Color(red: 0.78, green: 0.76, blue: 0.88),
        dark: Color(red: 0.08, green: 0.07, blue: 0.16)
    )

    static let immersiveGlow = Color(red: 0.85, green: 0.55, blue: 0.25)
    static let immersiveWindowGlow = Color(red: 0.95, green: 0.78, blue: 0.45)

    static let immersiveStroke = Color(
        light: Color.black.opacity(0.12),
        dark: Color.white.opacity(0.15)
    )

    static let immersiveDivider = Color(
        light: Color.black.opacity(0.08),
        dark: Color.white.opacity(0.08)
    )

    // MARK: - Typography

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
