import SwiftUI

struct PSSearchBarView: View {

    @Binding var searchText: String

    var body: some View {
         ZStack {
             RoundedRectangle(cornerRadius: 15)
                 .strokeBorder(Color.gray6)
                 .foregroundColor(.white)
             HStack {
                 Image(systemName: "magnifyingglass")
                 TextField("Search for products / shops / locations ...", text: $searchText)
                    .foregroundColor(.gray9)
             }
             .foregroundColor(.gray6)
             .padding(.horizontal)
         }
         .frame(height: 40)
         .padding()
     }
}

struct PSSearchBarView_Previews: PreviewProvider {
    @State static var searchText = ""

    static var previews: some View {
        PSSearchBarView(searchText: $searchText)
    }
}
