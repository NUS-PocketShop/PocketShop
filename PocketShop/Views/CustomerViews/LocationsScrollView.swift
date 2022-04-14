import SwiftUI

struct LocationsScrollView: View {
    @EnvironmentObject var viewModel: CustomerViewModel

    var body: some View {
        VStack {
            if !viewModel.locationSearchResults.isEmpty {
                Text("Locations")
                    .font(.appTitle)
                    .foregroundColor(.gray9)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.locationSearchResults, id: \.self) { location in
                        NavigationLink(destination: CustomerLocationView(location: location)
                                        .environmentObject(viewModel)) {
                            LocationSummaryView(location: location)
                        }
                    }
                }
            }
        }
    }
}

struct LocationsScrollView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsScrollView().environmentObject(CustomerViewModel())
    }
}
