//
//  Color+Theme.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import SwiftUI

extension Color {
    static var appTheme: AppColorTheme = .midnightAurora
}

extension AppColorTheme {
    static var midnightAurora: AppColorTheme {
        .init(
            accent: .dynamic(light: Color(hex: "0284C7"), dark: Color(hex: "00F2FE")),
            alternateAccent: .dynamic(light: Color(hex: "4F46E5"), dark: Color(hex: "4FACFE")),
            viewBackground: .dynamic(light: Color(hex: "F8FAFC"), dark: Color(hex: "0B0E14")),
            cellBackground: .dynamic(light: Color(hex: "FFFFFF"), dark: Color(hex: "1A1F26")),
            text: .dynamic(light: Color(hex: "0F172A"), dark: Color(hex: "F8F9FA")),
            secondaryText: .dynamic(light: Color(hex: "64748B"), dark: Color(hex: "94A3B8")),
            alternateText: .dynamic(light: Color(hex: "475569"), dark: Color(hex: "CBD5E1")),
            accentContrastText: .dynamic(light: Color(hex: "FFFFFF"), dark: Color(hex: "0F172A")),
            primaryAction: .dynamic(light: Color(hex: "0284C7"), dark: Color(hex: "00F2FE")),
            neutralAction: .dynamic(light: Color(hex: "94A3B8"), dark: Color(hex: "334155")),
            destructive: .dynamic(light: Color(hex: "DC2626"), dark: Color(hex: "FF4D4D")),
            success: .dynamic(light: Color(hex: "16A34A"), dark: Color(hex: "22C55E")),
            warning: .dynamic(light: Color(hex: "D97706"), dark: Color(hex: "F59E0B")),
            info: .dynamic(light: Color(hex: "2563EB"), dark: Color(hex: "3B82F6")),
            error: .dynamic(light: Color(hex: "DC2626"), dark: Color(hex: "EF4444")),
            inProgress: .dynamic(light: Color(hex: "4F46E5"), dark: Color(hex: "6366F1")),
            divider: .dynamic(light: Color(hex: "E2E8F0"), dark: Color(hex: "334155").opacity(0.3)),
            miscellaneous: .dynamic(light: Color(hex: "64748B"), dark: Color(hex: "94A3B8"))
        )
    }
}

extension Color {
    static func dynamic(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
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
