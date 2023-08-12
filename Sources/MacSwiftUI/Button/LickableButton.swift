import SwiftUI

// https://github.com/thompsonate/Lickable-Button/blob/main/LickableButton/LickableButtonStyle.swift
//
//  Created by Nate Thompson on 6/9/21.
//

public struct LickableButtonStyle: ButtonStyle {
    let isDefaultAction: Bool
    var buttonColor: LickableButtonColor
    
    @State var buttonPulse = false
    
    public init(isDefaultAction: Bool = false) {
        self.isDefaultAction = isDefaultAction
        buttonColor = isDefaultAction ? .highlighted : .default
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            ButtonBackground(color: buttonColor)
            
            if isDefaultAction {
                Capsule()
                    .fill(Color.white)
                    .animation(nil)
                    .opacity(buttonPulse ? 0.2 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever())
            }
            
            if configuration.isPressed {
                ButtonBackground(color: .pressed)
            }
            
            Capsule()
                .stroke(
                    LinearGradient(
                        gradient: configuration.isPressed
                        ? LickableButtonColor.pressed.outlineGradient : buttonColor.outlineGradient,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            configuration.label
                .foregroundColor(.black)
                .font(.custom("Lucida Grande", size: 12))
        }
        .clipShape(Capsule())
        .frame(height: 20)
        .shadow(
            color: Color(.sRGB, red: 0.71, green: 0.71, blue: 0.71),
            radius: 0.5,
            x: 0,
            y: 1
        )
//        .onAppear {
//            if isDefaultAction {
//                buttonPulse = true
//            }
//        }
    }
}

struct ButtonBackground: View {
    let color: LickableButtonColor
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(LinearGradient(
                    gradient: color.backgroundGradient,
                    startPoint: .top,
                    endPoint: .bottom))
            
            RoundedRectangle(cornerRadius: 5)
                .fill(LinearGradient(
                    gradient: color.shineGradient,
                    startPoint: .top,
                    endPoint: .bottom))
                .offset(y: -6)
                .frame(height: 7)
                .padding(.horizontal, 3)
        }
    }
}

struct LickablebuttonStyle_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 12) {
            
            Button("Cancel", action: {
                print("Cancel")
            })
            .buttonStyle(LickableButtonStyle())
//            .frame(minWidth: 40)
            
            Button("Submit", action: {
                print("OK")
            })
            .buttonStyle(LickableButtonStyle(isDefaultAction: true))
            .keyboardShortcut(.defaultAction)
//            .frame(minWidth: 40)
            
            Button("OK", action: {
                print("OK")
            })
            .buttonStyle(LickableButtonStyle(isDefaultAction: true))
            .keyboardShortcut(.defaultAction)
//            .frame(minWidth: 40)
        }
        .padding()
        .background(Color(.sRGB, red: 0.93, green: 0.93, blue: 0.94))
    }
}



enum LickableButtonColor {
    case `default`
    case highlighted
    case pressed
    
    var backgroundGradient: Gradient {
        switch self {
        case .default:
            return Gradient(stops: [
                .init(color: Color(.displayP3, red: 0.8, green: 0.8, blue: 0.8), location: 0),
                .init(color: Color(.displayP3, red: 0.98, green: 0.98, blue: 0.98), location: 0.75),
                .init(color: Color.white, location: 0.8),
            ])
        case .highlighted:
            return Gradient(stops: [
                .init(color: Color(.displayP3, red: 0.45, green: 0.60, blue: 0.78), location: 0),
                .init(color: Color(.displayP3, red: 0.55, green: 0.73, blue: 0.91), location: 0.5),
                .init(color: Color(.displayP3, red: 0.78, green: 0.91, blue: 0.98), location: 1),
            ])
        case .pressed:
            return Gradient(stops: [
                .init(color: Color(.displayP3, red: 0.33, green: 0.56, blue: 0.78), location: 0),
                .init(color: Color(.displayP3, red: 0.44, green: 0.62, blue: 0.82), location: 0.5),
                .init(color: Color(.displayP3, red: 0.75, green: 0.88, blue: 0.96), location: 1),
            ])
        }
    }
    
    var shineGradient: Gradient {
        switch self {
        case .default:
            return Gradient(colors: [
                .white,
                Color.white.opacity(0.5),
            ])
        case .highlighted:
            return Gradient(colors: [
                Color(.sRGB, red: 0.78, green: 0.86, blue: 0.98),
                Color(.sRGB, red: 0.64, green: 0.78, blue: 0.93),
            ])
        case .pressed:
            return Gradient(colors: [
                Color(.sRGB, red: 0.85, green: 0.91, blue: 0.98),
                Color(.sRGB, red: 0.60, green: 0.73, blue: 0.86),
            ])
        }
    }
    
    var outlineGradient: Gradient {
        switch self {
        case .default:
            return Gradient(colors: [Color(.sRGB, red: 0.36, green: 0.36, blue: 0.36)])
        case .highlighted, .pressed:
            return Gradient(stops: [
                .init(color: Color(.sRGB, red: 0, green: 0.11, blue: 0.35), location: 0.45),
                .init(color: Color(.sRGB, red: 0.36, green: 0.36, blue: 0.36), location: 0.55),
            ])
        }
    }
}
