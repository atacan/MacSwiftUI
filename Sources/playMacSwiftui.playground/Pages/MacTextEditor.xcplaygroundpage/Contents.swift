//: [Previous](@previous)

import Foundation
import Cocoa
import MacSwiftUI
import SwiftUI
import PlaygroundSupport

let attrs: [NSAttributedString.Key : Any] = [
    .foregroundColor: NSColor.white,
    .font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: NSFont.Weight.regular)
]

struct MyEditor: View {
    @State var myText = NSMutableAttributedString(string: """
    extension JsonClientError: LocalizedError  {
        var errorDescription: String? {
            switch self {
            case .jsonSerial:
                return "JSONSerialization"
            case .stringEncoding:
                return "this didn't work `jsonString = String(data: data, encoding: .utf8)` "
            }
        }
    }

    extension DependencyValues {
        var jsonClient: JsonClient {
            get { self[JsonClient.self] }
            set { self[JsonClient.self] = newValue }
        }
    }
    """, attributes: attrs)
    
    @State var output = NSAttributedString(string: "")

    var body: some View {
        VSplitView {
            MacEditorView(text: $myText, textViewBackground: .black, hasLineNumbers: true, hasHorizontalScroll: false, isRichText: true)
                .frame(width: 600, height: nil, alignment: .center)
            Button("See") {
                output = myText
                print(output)
            }
            ZStack {
                Rectangle()
                Text(AttributedString(output))
                    .frame(width: 600, height: 800, alignment: .center)
            }
        }
    }
}


PlaygroundPage.current.setLiveView(MyEditor())

//: [Next](@next)
