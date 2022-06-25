// based on https://oliver-epper.de/posts/wrap-nstextview-in-swiftui/

import Combine
import SwiftUI

class MacEditorController: NSViewController {
    var textView = NSTextView()
    var cancellables = Set<AnyCancellable>()
    var hasLineNumbers = true
    var hasHorizontalScroll = false
    var isRichText = false
    var font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: NSFont.Weight.regular)
    
    override func loadView() {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        textView.allowsUndo = true
        
        textView.font = font
        textView.isRichText = isRichText
        
        // enable horizontal scroll, disable line wrap
        if hasHorizontalScroll {
            scrollView.hasHorizontalScroller = true
            textView.maxSize = NSMakeSize(.greatestFiniteMagnitude, .greatestFiniteMagnitude)
            textView.isHorizontallyResizable = true
            textView.textContainer?.widthTracksTextView = false
            textView.textContainer?.containerSize = NSMakeSize(.greatestFiniteMagnitude, .greatestFiniteMagnitude)
        }
        
        textView.autoresizingMask = [.width]
        
        // Line Numbers
        if hasLineNumbers {
            scrollView.hasHorizontalRuler = false
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
            let lineNumberGutter = LineNumberGutter(withTextView: textView, foregroundColor: .secondaryLabelColor, backgroundColor: .textBackgroundColor)
            scrollView.verticalRulerView = lineNumberGutter
            
            NotificationCenter.default.publisher(for: NSView.frameDidChangeNotification).sink { _ in
                lineNumberGutter.needsDisplay = true
            }.store(in: &cancellables)
            NotificationCenter.default.publisher(for: NSText.didChangeNotification).sink { _ in
                lineNumberGutter.needsDisplay = true
            }.store(in: &cancellables)
        }
        
        scrollView.documentView = textView
        view = scrollView
    }
    
    override func viewDidAppear() {
        view.window?.makeFirstResponder(view)
    }
}

struct MacEditorControllerView: NSViewControllerRepresentable {
    @Binding var text: String
    
    init(text: Binding<String>) {
        self._text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextStorageDelegate {
        private var parent: MacEditorControllerView
        var shouldUpdateText = true
        
        init(_ parent: MacEditorControllerView) {
            self.parent = parent
        }
        
        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            guard shouldUpdateText else {
                return
            }
            let edited = textStorage.attributedSubstring(from: editedRange).string
            let insertIndex = parent.text.utf16.index(parent.text.utf16.startIndex, offsetBy: editedRange.lowerBound)
            
            func numberOfCharactersToDelete() -> Int {
                editedRange.length - delta
            }
            
            let endIndex = parent.text.utf16.index(insertIndex, offsetBy: numberOfCharactersToDelete())
            parent.text.replaceSubrange(insertIndex ..< endIndex, with: edited)
        }
    }
    
    func makeNSViewController(context: Context) -> MacEditorController {
        let vc = MacEditorController()
        vc.textView.textStorage?.delegate = context.coordinator
        return vc
    }
    
    func updateNSViewController(_ nsViewController: MacEditorController, context: Context) {
        if text != nsViewController.textView.string {
            context.coordinator.shouldUpdateText = false
            nsViewController.textView.string = text
            context.coordinator.shouldUpdateText = true
        }
    }
}
