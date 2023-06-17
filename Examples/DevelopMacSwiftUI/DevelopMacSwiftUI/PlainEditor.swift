//
// https://github.com/atacan
// 16.06.23
	

import SwiftUI
import MacSwiftUI

struct PlainEditor: View {
    @State var text: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
        Button {
                    print(text)
                } label: {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                } // <-Button
                Text(text)
                PlainMacEditorView(text: $text)
        } // <-VStack
    }
}

struct PlainEditor_Previews: PreviewProvider {
    static var previews: some View {
        PlainEditor()
    }
}
