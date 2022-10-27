// based on https://oliver-epper.de/posts/wrap-nstextview-in-swiftui/

import Combine
import SwiftUI

public class MacEditorController: NSViewController {
    var textView = NSTextView()
    var textViewBackground: NSColor
    var cancellables = Set<AnyCancellable>()
    var hasLineNumbers: Bool
    var hasHorizontalScroll: Bool
    var isRichText: Bool

    var lineNumberGutter: LineNumberGutter

    init(textViewBackground: NSColor,
         hasLineNumbers: Bool,
         hasHorizontalScroll: Bool,
         isRichText: Bool)
    {
        self.textViewBackground = textViewBackground
        self.hasLineNumbers = hasLineNumbers
        self.hasHorizontalScroll = hasHorizontalScroll
        self.isRichText = isRichText
        lineNumberGutter = LineNumberGutter(withTextView: textView, foregroundColor: .secondaryLabelColor, backgroundColor: .textBackgroundColor)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        textView.allowsUndo = true

        textView.isRichText = isRichText
        textView.backgroundColor = textViewBackground

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
            scrollView.verticalRulerView = lineNumberGutter
            lineNumberGutter = LineNumberGutter(withTextView: textView, foregroundColor: .secondaryLabelColor, backgroundColor: .textBackgroundColor)
            NotificationCenter.default.publisher(for: NSView.frameDidChangeNotification).sink { [weak self] _ in
                guard let self = self else { return }
                self.lineNumberGutter.needsDisplay = true
            }.store(in: &cancellables)
            NotificationCenter.default.publisher(for: NSText.didChangeNotification).sink { [weak self] _ in
                guard let self = self else { return }
                self.lineNumberGutter.needsDisplay = true
            }.store(in: &cancellables)
        }

        scrollView.documentView = textView
        view = scrollView
    }

    override public func viewDidAppear() {
        view.window?.makeFirstResponder(view)
    }
}

public struct MacEditorView: NSViewControllerRepresentable {
//    @Binding var text: String
    @Binding var text: NSAttributedString

    var textViewBackground: NSColor
    var hasLineNumbers: Bool
    var hasHorizontalScroll: Bool
    var isRichText: Bool

    public init(text: Binding<NSAttributedString>,
                textViewBackground: NSColor = .textBackgroundColor,
                hasLineNumbers: Bool = true,
                hasHorizontalScroll: Bool = true,
                isRichText: Bool = true)
    {
        _text = text
        self.textViewBackground = textViewBackground
        self.hasLineNumbers = hasLineNumbers
        self.hasHorizontalScroll = hasHorizontalScroll
        self.isRichText = isRichText
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    public final class Coordinator: NSObject, NSTextViewDelegate {
        private var parent: MacEditorView
        var shouldUpdateText = true

        init(_ parent: MacEditorView) {
            self.parent = parent
        }

        public func textDidChange(_ notification: Notification) {
            guard let textview = notification.object as? NSTextView else {
                return
            }

            parent.text = textview.attributedString()
        }

        public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            return true
        }
    }

    public func makeNSViewController(context: Context) -> MacEditorController {
        let vc = MacEditorController(textViewBackground: textViewBackground, hasLineNumbers: hasLineNumbers, hasHorizontalScroll: hasHorizontalScroll, isRichText: isRichText)
        vc.textView.delegate = context.coordinator
        return vc
    }

    public func updateNSViewController(_ nsViewController: MacEditorController, context: Context) {
        if text != nsViewController.textView.attributedString() {
            context.coordinator.shouldUpdateText = false
            nsViewController.textView.textStorage?.setAttributedString(text)
            nsViewController.lineNumberGutter.needsDisplay = true
            context.coordinator.shouldUpdateText = true
        }
    }
}
