import SwiftUI

struct PSBadge: View {

    var badgeNumber: Int

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.red)
            Text("\(badgeNumber)")
                .foregroundColor(.white)
                .font(Font.system(size: 12))
        }
        .frame(width: 15, height: 15)
    }
}
