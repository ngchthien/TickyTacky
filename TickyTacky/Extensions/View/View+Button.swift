//
//  View+Button.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.smooth, value: configuration.isPressed)
  }
}

enum ButtonStyleOption {
  case press, plain
}

extension View {
  @ViewBuilder
  func button(_ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
    switch option {
    case .press:
      self.pressableButton(action: action)
    case .plain:
      self.plainButton(action: action)
    }
  }
  
  private func plainButton(action: @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      self
    }
    .buttonStyle(PlainButtonStyle())
  }
  
  private func pressableButton(action: @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      self
    }
    .buttonStyle(PressableButtonStyle())
  }
}

#Preview {
  Preview()
}

fileprivate struct Preview: View {
  var body: some View {
    ZStack {
      Color.appTheme.viewBackground.ignoresSafeArea()
      VStack(spacing: 16) {
        
        Text("Continue")
          .foregroundColor(.white)
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .cornerRadius(8)
          .button(.press) {
            
          }
        
        Text("Continue")
          .foregroundColor(.white)
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .cornerRadius(8)
          .button(.plain) {
            
          }
      }
      .padding()
    }
  }
}
