//
//  HomeView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 40) {
                topBar
                
                Spacer()
                
                logoSection
                
                Spacer()
                
                optionsSection
                
                Spacer()
            }
            .padding()
        }
        .infinityFrame()
    }
}

private extension HomeView {
    var backgroundGradient: some View {
        Color.appTheme.viewBackground.ignoresSafeArea()
    }
    
    var topBar: some View {
        HStack {
            Button(action: viewModel.goHistory) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTheme.text)
                    .frame(width: 44, height: 44)
                    .background(Color.appTheme.cellBackground)
                    .clipShape(Circle())
                    .shadow(.light)
            }
            .button(.press) {}
            
            Button(action: viewModel.goLeaderboard) {
                Image(systemName: "trophy.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.yellow)
                    .frame(width: 44, height: 44)
                    .background(Color.appTheme.cellBackground)
                    .clipShape(Circle())
                    .shadow(.light)
            }
            .button(.press) {}
            
            Spacer()
            
            Button(action: viewModel.goSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTheme.text)
                    .frame(width: 44, height: 44)
                    .background(Color.appTheme.cellBackground)
                    .clipShape(Circle())
                    .shadow(.light)
            }
            .button(.press) {}
        }
    }
    
    var logoSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "grid")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appTheme.accent, Color.appTheme.alternateAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(.regular)
            
            VStack(spacing: 4) {
                Text("Ticky Tacky")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(Color.appTheme.text)
                
                Text("BATTLE OF THE SYMBOLS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundStyle(Color.appTheme.secondaryText)
            }
        }
    }
    
    var optionsSection: some View {
        VStack(spacing: 20) {
            menuButton(
                title: "Local Match",
                subtitle: "Play with Computer or Friend",
                icon: "person.2.fill",
                color: Color.appTheme.accent,
                action: viewModel.playLocal
            )
            
            menuButton(
                title: "Online Battle",
                subtitle: "Challenge Players Worldwide",
                icon: "globe.americas.fill",
                color: Color.appTheme.alternateAccent,
                action: viewModel.playOnline
            )
        }
    }
    
    func menuButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .cornerRadius(.overall)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.appTheme.text)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color.appTheme.divider)
            }
            .padding()
            .background(Color.appTheme.cellBackground)
            .cornerRadius(.cell)
            .shadow(.light)
        }
        .button(.press) {}
    }
}

#Preview {
    HomeView()
}
