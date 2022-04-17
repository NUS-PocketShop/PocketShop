import SwiftUI

struct ProductsScrollView: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var productsToShow: [Product]
    var title = "Products"
    var axis: Axis.Set = .horizontal

    var body: some View {
        VStack {
            TitleSection(title: title)
            if productsToShow.isEmpty {
                EmptySection()
            }
            if axis == .horizontal {
                HorizontalScrollSection(products: productsToShow)
            } else {
                VerticalScrollSection(products: productsToShow)
            }
        }
    }
}

private struct TitleSection: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.appTitle)
            .foregroundColor(.gray9)
    }
}

private struct EmptySection: View {
    var body: some View {
        Spacer()
        Text("There's nothing here ... yet!")
            .font(.appCaption)
            .italic()
        Spacer()
    }
}

private struct HorizontalScrollSection: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var products: [Product]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(products) { product in
                    if !product.isOutOfStock
                        && !(viewModel.shops.first(where: { $0.id == product.shopId })?.isClosed ?? true) {
                        NavigationLink(destination: ProductDetailView(product: product).environmentObject(viewModel)) {
                            ProductSummaryView(product: product).environmentObject(viewModel)
                        }
                    }
                }
            }
        }
    }
}

private struct VerticalScrollSection: View {
    var products: [Product]
    var body: some View {
        List {
            ForEach(products, id: \.self) { product in
                ProductPreview(product: product)
            }
        }
    }
}

// MARK: Preview
struct ProductsScrollView_Previews: PreviewProvider {
    static var customerVM = CustomerViewModel()
    static var previews: some View {
        ProductsScrollView(productsToShow: customerVM.productSearchResults)
            .environmentObject(customerVM)
    }
}
