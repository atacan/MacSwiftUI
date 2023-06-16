//
// https://github.com/atacan
// 16.06.23
	

import SwiftUI
import MacSwiftUI

struct ContentView: View {
    @State var text: NSMutableAttributedString = .init()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            MacEditorView(text: $text)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
