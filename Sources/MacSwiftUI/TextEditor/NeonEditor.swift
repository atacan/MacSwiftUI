#if os(macOS)
import Combine
import SwiftUI
import Cocoa
import Neon
import SwiftTreeSitter
import TreeSitterSwift

public class NeonEditorController: NSViewController {
    var textView: NSTextView
    let scrollView = NSScrollView()
    let highlighter: TextViewHighlighter
    var initialFont: NSFont
    var textViewBackground: NSColor
    var cancellables = Set<AnyCancellable>()
    var hasLineNumbers: Bool
    var hasHorizontalScroll: Bool
    var isRichText: Bool
    var isEditable: Bool

    var lineNumberGutter: LineNumberGutter

    public init(initialFont: NSFont,
         textViewBackground: NSColor,
         hasLineNumbers: Bool,
         hasHorizontalScroll: Bool,
         isRichText: Bool,
         isEditable: Bool)
    {
        self.textView = NSTextView()
        scrollView.documentView = textView
        
        self.initialFont = initialFont
        self.textViewBackground = textViewBackground
        self.hasLineNumbers = hasLineNumbers
        self.hasHorizontalScroll = hasHorizontalScroll
        self.isRichText = isRichText
        self.isEditable = isEditable
        lineNumberGutter = LineNumberGutter(withTextView: textView, foregroundColor: .secondaryLabelColor, backgroundColor: .textBackgroundColor)

        let provider: TextViewSystemInterface.AttributeProvider = { token in
//            print(token.name)
            return colorFor(token: token)
		}

		let language = Language(language: tree_sitter_swift())

		let url = Bundle.main
					  .resourceURL?
					  .appendingPathComponent("TreeSitterSwift_TreeSitterSwift.bundle")
					  .appendingPathComponent("Contents/Resources/queries/highlights.scm")
		let query = try! language.query(contentsOf: url!)

		self.highlighter = try! TextViewHighlighter(textView: textView,
													language: language,
													highlightQuery: query,
													attributeProvider: provider)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
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

        view = scrollView
    }

    override public func viewDidAppear() {
//        view.window?.makeFirstResponder(view)
    }
}

public struct NeonEditorView: NSViewControllerRepresentable {
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

    public func makeNSViewController(context: Context) -> NeonEditorController {
        let vc = NeonEditorController(initialFont: initialFont, textViewBackground: textViewBackground, hasLineNumbers: hasLineNumbers, hasHorizontalScroll: hasHorizontalScroll, isRichText: isRichText, isEditable: isEditable)
        vc.textView.delegate = context.coordinator
//        vc.textView.textStorage?.delegate = context.coordinator
        return vc
    }

    public func updateNSViewController(_ nsViewController: NeonEditorController, context: Context) {
        if text != nsViewController.textView.attributedString() {
            nsViewController.textView.textStorage?.setAttributedString(text)
            nsViewController.lineNumberGutter.needsDisplay = true
        }
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
            var parent: NeonEditorView
            var selectedRanges: [NSValue] = []
            
            init(_ parent: NeonEditorView) {
                self.parent = parent
            }
            
            public func textDidBeginEditing(_ notification: Notification) {
                guard let textView = notification.object as? NSTextView else {
                    return
                }
                
                self.parent.text = .init(attributedString: textView.attributedString())
//                self.parent.onEditingChanged()
            }
            
        public func textDidChange(_ notification: Notification) {
                guard let textView = notification.object as? NSTextView else {
                    return
                }
                
                self.parent.text = .init(attributedString: textView.attributedString())
                self.selectedRanges = textView.selectedRanges
            }
            
        public func textDidEndEditing(_ notification: Notification) {
                guard let textView = notification.object as? NSTextView else {
                    return
                }
                
                self.parent.text = .init(attributedString: textView.attributedString())
//                self.parent.onCommit()
            }
        }
}

func colorFor(token: Token) -> [NSAttributedString.Key:Any] {
     switch token.name {
        case "boolean":
            return [:]
        case "comment":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.423529, green: 0.47451, blue: 0.529412, alpha: 1)]
        case "conditional": // switch
         return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.94752, green: 0.139928, blue: 0.547125, alpha: 1)]
        case "constructor":
            return [:]
        case "function.call":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.337255, green: 0.815686, blue: 0.701961 , alpha: 1)]
        case "function.macro":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.992157, green: 0.560784, blue: 0.247059, alpha: 1)]
        case "include":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.94752, green: 0.139928, blue: 0.547125, alpha: 1)]
        case "keyword":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.94752, green: 0.139928, blue: 0.547125, alpha: 1)]
        case "keyword.function":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.94752, green: 0.139928, blue: 0.547125, alpha: 1)]
        case "keyword.operator":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.94752, green: 0.139928, blue: 0.547125, alpha: 1)]
        case "keyword.return":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.94752, green: 0.139928, blue: 0.547125, alpha: 1)]
        case "method":
            return [:]
        case "operator":
            return [:]
        case "parameter":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.207138, green: 0.690717, blue: 0.847769, alpha: 1)]
        case "property":
            return [:]
        case "punctuation.bracket":
            return [:]
        case "punctuation.delimiter":
            return [:]
        case "spell":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.423529, green: 0.47451, blue: 0.529412, alpha: 1)]
        case "string":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.988235, green: 0.27451, blue: 0.317647 , alpha: 1)]
        case "type":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.663989, green: 1, blue: 0.919033 , alpha: 1)]
        case "variable":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.335767, green: 0.815927, blue: 0.701889 , alpha: 1)]
        case "variable.builtin":
            return [NSAttributedString.Key.foregroundColor: NSColor(red: 0.669967, green: 0.392548, blue: 1 , alpha: 1)]
     default:
         return [:]
     }
}

#endif
