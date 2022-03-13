import SwiftUI

struct SearchBarView: View {
    var body: some View {
         ZStack {
             RoundedRectangle(cornerRadius: 15)
                 .strokeBorder(.blue)
                 .foregroundColor(.white)
             HStack {
                 Image(systemName: "magnifyingglass")
                 Text("Search for products / shops ...")
             }
             .foregroundColor(.gray)
             .padding(.horizontal)
         }
         .frame(height: 40)
         .padding()
     }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
