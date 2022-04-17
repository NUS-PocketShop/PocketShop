import SwiftUI

struct LocationSummaryView: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var location: Location

    var body: some View {
        VStack {
            URLImage(urlString: location.imageURL)
                .scaledToFit()
                .frame(width: 150, height: 150)

            Text(location.name)
                .font(.appHeadline)
                .foregroundColor(.gray9)
                .padding(.bottom)
        }
        .padding()
    }
}

struct LocationSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CustomerViewModel()
        let sampleLocation = viewModel.locations.first!
        LocationSummaryView(location: sampleLocation).environmentObject(viewModel)
    }
}
