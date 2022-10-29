import Cocoa

var greeting = "Hello, playground"

let insertIndex = greeting.utf16.index(greeting.utf16.startIndex, offsetBy: 5)
let endIndex = greeting.utf16.index(insertIndex, offsetBy: 0)
greeting.replaceSubrange(insertIndex ..< endIndex, with: "Afsadf")

