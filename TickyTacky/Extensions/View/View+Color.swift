//
//  View+Color.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import SwiftUI

extension Color {
    static var appTheme: AppColorTheme = main
}

extension Color {
    static var main: AppColorTheme {
        .init(
            accent: .init(.accent),
            alternateAccent: .init(.alternateAccent),
            viewBackground: .init(.viewBackground),
            cellBackground: .init(.cellBackground),
            text: .init(.text),
            secondaryText: .init(.secondaryText),
            alternateText: .init(.alternateText),
            accentContrastText: .init(.accentContrastText),
            primaryAction: .init(.primaryAction),
            neutralAction: .init(.neutralAction),
            destructive: .init(.destructive),
            success: .init(.success),
            warning: .init(.warning),
            info: .init(.info),
            error: .init(.error),
            inProgress: .init(.inProgress),
            divider: .init(.divider),
            miscellaneous: .init(.miscellaneous)
        )
    }
}

struct AppColorTheme {
    let accent: Color
    let alternateAccent: Color
    let viewBackground: Color
    let cellBackground: Color
    let text: Color
    let secondaryText: Color
    let alternateText: Color
    let accentContrastText: Color
    let primaryAction: Color
    let neutralAction: Color
    let destructive: Color
    let success: Color
    let warning: Color
    let info: Color
    let error: Color
    let inProgress: Color
    let divider: Color
    let miscellaneous: Color
}

#Preview("Light Mode") {
    Preview()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    Preview()
        .preferredColorScheme(.dark)
}

fileprivate struct Preview: View {
    var body: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Title")
                        .foregroundColor(.appTheme.text)
                    Text("Subtitle")
                        .foregroundColor(.appTheme.secondaryText)
                }
                
                Divider()
                    .background(Color.appTheme.divider)
                
                Button(action: {}) {
                    Text("Get Started")
                        .font(.body.bold())
                        .foregroundColor(.appTheme.accentContrastText)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.appTheme.accent)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}
