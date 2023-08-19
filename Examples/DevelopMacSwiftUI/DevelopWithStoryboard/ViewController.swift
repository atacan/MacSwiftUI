//
// https://github.com/atacan
// 19.08.23
	

import Cocoa
import MacSwiftUI

class ViewController: NSViewController {
    let editorController = NeonEditorController(initialFont: initialFont, textViewBackground: textViewBackground, hasLineNumbers: hasLineNumbers, hasHorizontalScroll: hasHorizontalScroll, isRichText: isRichText, isEditable: isEditable)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view = editorController.view
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

let initialFont: NSFont = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
let textViewBackground: NSColor = .textBackgroundColor
let hasLineNumbers: Bool = true
let hasHorizontalScroll: Bool = true
let isRichText: Bool = true
let isEditable: Bool = true
