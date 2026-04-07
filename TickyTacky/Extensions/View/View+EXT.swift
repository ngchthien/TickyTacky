//
//  View+EXT.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import SwiftUI

extension View {
  func primaryButton() -> some View {
    self
      .font(.headline)
      .foregroundStyle(Color.appTheme.accentContrastText)
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.appTheme.accent)
      .cornerRadius(.button)
      .shadow(.regular)
  }
  
  func destructiveButton() -> some View {
    self
      .font(.headline)
      .foregroundStyle(Color.appTheme.accentContrastText)
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.appTheme.destructive)
      .cornerRadius(.button)
      .shadow(.regular)
  }
  
  func plainButton() -> some View {
    self
      .font(.headline)
      .foregroundStyle(Color.appTheme.text)
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.appTheme.cellBackground)
      .cornerRadius(.button)
      .shadow(.regular)
  }
}

#Preview {
  ZStack {
    Color.appTheme.viewBackground.ignoresSafeArea()
    
    VStack(spacing: 20) {
      Text("Primary Button")
        .primaryButton()
      
      Text("Destructive Button")
        .destructiveButton()
      
      Text("Plain Button")
        .plainButton()
    }
    .padding()
  }
}
