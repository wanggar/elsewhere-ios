import SwiftUI
import UIKit

extension Color {
    /// Resolves to different colors in light vs dark appearance.
    init(light: Color, dark: Color) {
        self.init(
            uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            }
        )
    }
}
