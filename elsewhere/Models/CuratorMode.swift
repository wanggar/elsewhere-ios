import Foundation
import SwiftUI

enum CuratorMode: String, Identifiable, Hashable, CaseIterable {
    case sleep
    case focus
    case relax
    case uplift
    case move

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .sleep: "to sleep"
        case .focus: "to focus"
        case .relax: "to relax"
        case .uplift: "to uplift"
        case .move: "to move"
        }
    }

    var categoryLabel: String {
        switch self {
        case .sleep: "SLEEP"
        case .focus: "FOCUS"
        case .relax: "RELAX"
        case .uplift: "UPLIFT"
        case .move: "MOVE"
        }
    }

    var modeDescription: String {
        switch self {
        case .sleep: "when your mind won't slow down"
        case .focus: "when you need to disappear into your work"
        case .relax: "when the day has been long"
        case .uplift: "when you need something gentle to start"
        case .move: "when you want to walk somewhere"
        }
    }

    var cardBackground: Color {
        switch self {
        case .sleep: AppTheme.nowPlayingBackground
        case .focus: AppTheme.focusCardBackground
        case .relax: AppTheme.relaxCardBackground
        case .uplift: AppTheme.upliftCardBackground
        case .move: AppTheme.moveCardBackground
        }
    }

    var cardPrimaryColor: Color {
        switch self {
        case .sleep: AppTheme.accentPurple
        case .focus: AppTheme.focusText
        case .relax: AppTheme.relaxText
        case .uplift: AppTheme.upliftText
        case .move: AppTheme.textPrimary
        }
    }

    var cardSecondaryColor: Color {
        switch self {
        case .sleep: AppTheme.accentPurple.opacity(0.85)
        case .focus: AppTheme.focusText.opacity(0.75)
        case .relax: AppTheme.relaxText.opacity(0.75)
        case .uplift: AppTheme.upliftText.opacity(0.75)
        case .move: AppTheme.textSecondary
        }
    }

    var progressTrackColor: Color {
        switch self {
        case .sleep: AppTheme.accentPurpleLight.opacity(0.35)
        case .move: AppTheme.textMuted.opacity(0.35)
        default: cardPrimaryColor.opacity(0.25)
        }
    }

    var timerLabel: String {
        switch self {
        case .sleep: "sleep timer"
        case .focus: "focus timer"
        case .relax: "relax timer"
        case .uplift: "uplift timer"
        case .move: "move timer"
        }
    }

    static func from(libraryModeName name: String) -> CuratorMode? {
        switch name.uppercased() {
        case "SLEEP": .sleep
        case "FOCUS": .focus
        case "RELAX": .relax
        case "UPLIFT": .uplift
        case "MOVE": .move
        default: nil
        }
    }
}
