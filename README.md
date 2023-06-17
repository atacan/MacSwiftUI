# MacSwiftUI: A SwiftUI Package for macOS App Development

Welcome to MacSwiftUI, a Swift package designed to enhance your macOS application development with SwiftUI. This package provides a set of wrapped AppKit views for SwiftUI, adding unique and essential features that are not available in the default SwiftUI editors.

## Key Features
### **NSTextView with Line Numbers** 

MacSwiftUI includes two versions of NSTextView - one that accepts attributed strings and another for plain strings. A distinguishing feature of these views is the integration of line numbers, a must-have for programmers and writers alike, which is notably absent in SwiftUI's default text editors.

- **Customizable:** Unlike the standard SwiftUI text editors that lack customization options, our NSTextView variants offer a flexible user experience. 
    - **Line Wrapping:** You can enable horizontal scrolling or line wrapping based on your application's needs.
    - **Rich Text:** Expand the functionality of your text editors with our rich text enablement feature. It allows for the creation and editing of styled text, offering a more engaging user experience.

#### Usage
Attributed String
```swift
```swift
struct ContentView: View {
    @State var text: NSMutableAttributedString = .init()
    
    var body: some View {
        VStack {
            MacEditorView(text: $text)
            Text(text.string)
        }
        .padding()
    }
}
```
Plain Text
```swift
struct PlainEditor: View {
    @State var text: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            PlainMacEditorView(text: $text)
            Text(text)  
        }
    }
}

```
<img width="677" alt="SCR-20230617-qhjh" src="https://github.com/atacan/MacSwiftUI/assets/765873/21f54800-ad5d-46fa-8e05-9b75596767dd">
</br></br>
MacSwiftUI's mission is to make SwiftUI even more powerful and versatile for macOS app developers. With our package, you can take full control of your text editor views, customizing and enhancing them to suit your specific needs.

## Why Use MacSwiftUI?

SwiftUI is a fantastic UI toolkit, but it has its limitations, especially when it comes to text editor views. This is where MacSwiftUI shines. Our NSTextView with line numbers adds a new layer of functionality and convenience, making it easier to navigate and manage your text. 

Moreover, the customizable options for text editors—like horizontal scrolling, line wrapping, and rich text enablement—allow for a more tailored and efficient user experience. 

If you're a macOS app developer looking to take your SwiftUI applications to the next level, MacSwiftUI is your go-to package.

## Get Started with MacSwiftUI

Ready to revolutionize your SwiftUI application development? Get started with MacSwiftUI today!

### Installation
#### Swift Package Manager
```swift
Package(
    //...
    dependencies: [
        //...
        .package(url: "https://github.com/atacan/MacSwiftUI", .branch("main"))
        //...
    ],
    targets: [
        //...
        .target(
            name: "YourTarget",
            dependencies: [
                .product(name: "MacSwiftUI", package: "MacSwiftUI")
            ]
        )
        //...
    ]
)
```
#### Xcode Project
1. In Xcode, select **File** > **Swift Packages** > **Add Package Dependency**.
1. Enter `https://github.com/atacan/MacSwiftUI` in the search bar.
1. Select the package and click **Next**.
1. Select the version rule as branch `main`.
1. Click **Finish**.

Add this Swift package to your project and unlock a new world of possibilities. With MacSwiftUI, you're not just coding better—you're building better.

> **Note:** This package is under active development. We're always adding new features and improvements to make your SwiftUI development experience even better. Stay tuned for updates!

So, why wait? Enhance your SwiftUI text editors with MacSwiftUI today. Happy coding!

_**MacSwiftUI - Empowering SwiftUI for macOS.**_
