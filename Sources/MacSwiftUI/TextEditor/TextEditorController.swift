#if os(macOS)
// based on https://oliver-epper.de/posts/wrap-nstextview-in-swiftui/
import Combine
import SwiftUI

public class MacEditorController: NSViewController {
    var textView = NSTextView()
    var initialFont: NSFont
    var textViewBackground: NSColor
    var cancellables = Set<AnyCancellable>()
    var hasLineNumbers: Bool
    var hasHorizontalScroll: Bool
    var isRichText: Bool
    var isEditable: Bool

    var lineNumberGutter: LineNumberGutter

    init(initialFont: NSFont,
         textViewBackground: NSColor,
         hasLineNumbers: Bool,
         hasHorizontalScroll: Bool,
         isRichText: Bool,
         isEditable: Bool)
    {
        self.initialFont = initialFont
        self.textViewBackground = textViewBackground
        self.hasLineNumbers = hasLineNumbers
        self.hasHorizontalScroll = hasHorizontalScroll
        self.isRichText = isRichText
        self.isEditable = isEditable
        lineNumberGutter = LineNumberGutter(withTextView: textView, foregroundColor: .secondaryLabelColor, backgroundColor: .textBackgroundColor)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let scrollView = NSScrollView()

        // user given configurations
        textView.isRichText = isRichText
        textView.backgroundColor = textViewBackground
        textView.isEditable = isEditable
        textView.font = initialFont
        // defaulted configurations
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false

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
//        view.window?.makeFirstResponder(view)
    }
}

public struct MacEditorView: NSViewControllerRepresentable {
//    @Binding var text: String
    @Binding var text: NSMutableAttributedString

    var initialFont: NSFont
    var textViewBackground: NSColor
    var hasLineNumbers: Bool
    var hasHorizontalScroll: Bool
    var isRichText: Bool
    var isEditable: Bool

    public init(text: Binding<NSMutableAttributedString>,
                initialFont: NSFont = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular),
                textViewBackground: NSColor = .textBackgroundColor,
                hasLineNumbers: Bool = true,
                hasHorizontalScroll: Bool = true,
                isRichText: Bool = true,
                isEditable: Bool = true)
    {
        _text = text
        self.initialFont = initialFont
        self.textViewBackground = textViewBackground
        self.hasLineNumbers = hasLineNumbers
        self.hasHorizontalScroll = hasHorizontalScroll
        self.isRichText = isRichText
        self.isEditable = isEditable
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    public final class Coordinator: NSObject {
        private var parent: MacEditorView
        var shouldUpdateText = true

        init(_ parent: MacEditorView) {
            self.parent = parent
        }
    }

    public func makeNSViewController(context: Context) -> MacEditorController {
        let vc = MacEditorController(initialFont: initialFont, textViewBackground: textViewBackground, hasLineNumbers: hasLineNumbers, hasHorizontalScroll: hasHorizontalScroll, isRichText: isRichText, isEditable: isEditable)
//        vc.textView.delegate = context.coordinator
        vc.textView.textStorage?.delegate = context.coordinator
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

extension MacEditorView.Coordinator: NSTextStorageDelegate {
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        guard shouldUpdateText else {
            return
        }
        let edited = textStorage.attributedSubstring(from: editedRange)
        let adjustedRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
        parent.text.replaceCharacters(in: adjustedRange, with: edited)
        // changing the text only doesn't triggere a refresh in SwiftUI views because NSMutableAttributedString is a reference type
        if let copy = parent.text.mutableCopy() as? NSMutableAttributedString  {
            parent.text = copy
        }
    }
}

#endif
