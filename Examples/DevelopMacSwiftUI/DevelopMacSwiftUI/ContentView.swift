//
// https://github.com/atacan
// 16.06.23


import SwiftUI
import MacSwiftUI

struct ContentView: View {
    @State var text: NSMutableAttributedString = .init()
//    @State var text: NSAttributedString = .init()
    
    var body: some View {
        VStack {
            Button {
                print(text)
            } label: {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            } // <-Button
            Text(text.string)
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


class TextModel: ObservableObject {
    @Published var text: NSMutableAttributedString = NSMutableAttributedString(string: "")
}

struct ReferenceBindingView: View {
    @ObservedObject var model = TextModel()

    var body: some View {
        HStack(alignment: .center) {
        TextField("Enter text", text: Binding(
                    get: { self.model.text.string },
                    set: { newValue in
                        self.model.text.mutableString.setString(newValue)
                    }
                ))
            Text(model.text.string)
        } // <-HStack
    }
}
