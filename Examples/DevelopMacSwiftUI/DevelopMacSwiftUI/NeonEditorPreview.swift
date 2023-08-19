//
// https://github.com/atacan
// 19.08.23


import SwiftUI
import MacSwiftUI

struct NeonEditorPreview: View {
//    @State var text: NSMutableAttributedString = .init(string: "var a = 5;")
    @State var text: NSMutableAttributedString = .init()
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                print(text)
                text = .init(string: "Html {\nDiv(title)\n}", attributes: [NSAttributedString.Key.font : NSFont.systemFont(ofSize: 14, weight: .bold)])
            } label: {
                Text("Neon")
                    .font(.title3)
            } // <-Button
            //                Text(text)
            NeonEditorView(text: $text, hasHorizontalScroll: false)
        } // <-VStack
    }
}

#Preview {
    NeonEditorPreview()
}
