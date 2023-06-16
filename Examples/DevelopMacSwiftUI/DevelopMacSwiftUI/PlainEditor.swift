//
// https://github.com/atacan
// 16.06.23
	

import SwiftUI
import MacSwiftUI

struct PlainEditor: View {
    @State var text: String = ""
    
    var body: some View {
        PlainMacEditorView(text: $text)
    }
}

struct PlainEditor_Previews: PreviewProvider {
    static var previews: some View {
        PlainEditor()
    }
}
