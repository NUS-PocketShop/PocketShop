import SwiftUI

/// Custom typography for PocketShop

extension Font {

    static func appFont(size: CGFloat) -> Font {
        Font.custom("Poppins", size: size)
    }

    static let appTitle = appFont(size: 32).weight(.bold)
    static let appHeadline = appFont(size: 16).weight(.bold)
    static let appSubheadline = appFont(size: 14).weight(.medium)
    static let appBody = appFont(size: 14).weight(.regular)
    static let appCaption = appFont(size: 14).weight(.regular)
    static let appSmallCaption = appFont(size: 12).weight(.bold).uppercaseSmallCaps()
    static let appButton = appFont(size: 14).weight(.medium)

}
