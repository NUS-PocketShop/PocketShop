//
//  RingView.swift
//  PocketShop
//
//  Created by Dasco Gabriel on 17/3/22.
//

import SwiftUI

struct RingView: View {
    @State var color: Color
    @State var text: String
    @State var size: CGFloat = 90

    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 8)
            Text(text)
                .font(.appSmallCaption)
                .bold()
                .multilineTextAlignment(.center)
        }
        .frame(width: size, height: size)
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        RingView(color: .success, text: "PREPARING", size: 90)
    }
}
