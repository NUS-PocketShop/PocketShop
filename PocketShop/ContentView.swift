//
//  ContentView.swift
//  PocketShop
//
//  Created by Lee Zen Been on 9/3/22.
//

import SwiftUI

struct ContentView: View {

    @StateObject var viewRouter: MainViewRouter
    @StateObject var customerRouter = CustomerViewRouter()

    var body: some View {
        switch viewRouter.currentPage {
        case .login:
            LoginScreen(router: viewRouter)
                .environmentObject(viewRouter)
        case .customer:
            CustomerRootView()
                .environmentObject(viewRouter)
        case .vendor:
            ShopRootView()
                .environmentObject(viewRouter)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: MainViewRouter())
    }
}
