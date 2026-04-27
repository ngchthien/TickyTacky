//
//  SettingsView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        generalSection
                        appearanceSection
                        languageSection
                        aboutSection
                    }
                    .padding()
                }
            }
        }
        .infinityFrame()
    }
}

private extension SettingsView {
    var backgroundGradient: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color.appTheme.accent.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    var headerView: some View {
        HStack {
            Button(action: viewModel.goBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTheme.text)
                    .frame(width: 44, height: 44)
                    .background(Color.appTheme.cellBackground)
                    .clipShape(Circle())
                    .shadow(.light)
            }
            .button(.press) {}
            
            Spacer()
            
            Text("Settings")
                .font(.title2.bold())
                .foregroundStyle(Color.appTheme.text)
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding()
    }
    
    var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "General")
            
            VStack(spacing: 0) {
                NavigationLink(destination: AchievementsView()) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.orange)
                            .frame(width: 32)
                        Text("Achievements")
                            .foregroundStyle(Color.appTheme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(Color.appTheme.secondaryText)
                    }
                    .padding()
                }
                
                Divider().padding(.leading, 56)
                
                settingToggle(title: "Haptic Feedback", icon: "iphone.radiowaves.left.and.right", isOn: $viewModel.isHapticEnabled)
            }
            .background(Color.appTheme.cellBackground)
            .cornerRadius(.overall)
            .shadow(.light)
        }
    }
    
    var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Appearance")
            
            VStack(spacing: 0) {
                settingToggle(title: "Dark Mode", icon: "moon.fill", isOn: $viewModel.isDarkMode)
            }
            .background(Color.appTheme.cellBackground)
            .cornerRadius(.overall)
            .shadow(.light)
        }
    }
    
    var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Language")
            
            Button(action: viewModel.openSystemSettings) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundStyle(Color.appTheme.accent)
                        .frame(width: 32)
                    
                    Text("Change Language")
                        .foregroundStyle(Color.appTheme.text)
                    
                    Spacer()
                    
                    Text(Bundle.main.preferredLocalizations.first?.uppercased() ?? "EN")
                        .font(.caption.bold())
                        .foregroundStyle(Color.appTheme.secondaryText)
                    
                    Image(systemName: "arrow.up.forward.square")
                        .font(.caption)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
                .padding()
                .background(Color.appTheme.cellBackground)
                .cornerRadius(.overall)
                .shadow(.light)
            }
            .button(.press) {}
        }
    }
    
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "About")
            
            VStack(spacing: 16) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
                
                Divider()
                
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("Antigravity")
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
            }
            .padding()
            .background(Color.appTheme.cellBackground)
            .cornerRadius(.overall)
            .shadow(.light)
        }
    }
    
    func sectionHeader(title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.bold())
            .tracking(1)
            .foregroundStyle(Color.appTheme.secondaryText)
            .padding(.leading, 4)
    }
    
    func settingToggle(title: String, icon: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.appTheme.accent)
                    .frame(width: 32)
                Text(title)
                    .foregroundStyle(Color.appTheme.text)
            }
        }
        .padding()
        .tint(Color.appTheme.accent)
    }
}

#Preview {
    SettingsView()
}
