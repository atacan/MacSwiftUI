//
// https://github.com/atacan
// 16.06.23
	

import SwiftUI

@main
struct DevelopMacSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView()
                ReferenceBindingView(model: .init())
                PlainEditor()
            }
        }
    }
}
