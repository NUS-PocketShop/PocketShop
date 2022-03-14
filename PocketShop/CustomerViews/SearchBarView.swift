import SwiftUI

struct SearchBarView: View {

    @Binding var searchText: String

    var body: some View {
         ZStack {
             RoundedRectangle(cornerRadius: 15)
                 .strokeBorder(Color.blue)
                 .foregroundColor(.white)
             HStack {
                 Image(systemName: "magnifyingglass")
                 TextField("Search for products / shops ...", text: $searchText)
             }
             .foregroundColor(.gray)
             .padding(.horizontal)
         }
         .frame(height: 40)
         .padding()
     }
}

struct SearchBarView_Previews: PreviewProvider {
    @State static var searchText = ""

    static var previews: some View {
        SearchBarView(searchText: $searchText)
    }
}
