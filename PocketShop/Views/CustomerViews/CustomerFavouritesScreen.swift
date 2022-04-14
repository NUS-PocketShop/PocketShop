import SwiftUI

struct CustomerFavouritesScreen: View {
    @EnvironmentObject var viewModel: CustomerViewModel

    var body: some View {
        ProductsScrollView(productsToShow: viewModel.favourites,
                           title: "Favourites",
                           axis: .vertical)
    }
}
