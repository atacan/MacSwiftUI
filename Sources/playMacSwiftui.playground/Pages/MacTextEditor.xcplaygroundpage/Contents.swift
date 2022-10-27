//: [Previous](@previous)

import Foundation
import MacSwiftUI
import PlaygroundSupport

let myText = """

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
"""

// let editorView = MacEditorControllerView(text: .constant("something\nand other things"))
let editorView = MacEditorView(text: .constant(myText), textViewBackground: .black, hasLineNumbers: true, hasHorizontalScroll: true, isRichText: true)

PlaygroundPage.current.setLiveView(editorView)

//: [Next](@next)
