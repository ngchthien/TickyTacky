//
//  GameSetupView.swift
//  TickyTacky
//
//  Created by M1 Pro on 10/4/26.
//

import SwiftUI

struct GameSetupView: View {
    @AppStorage(UserDefaultKeys.isDarkMode) private var isDarkMode = true
    @StateObject private var viewModel = GameSetupViewModel()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 32) {
                Spacer()
                
                logoSection
                
                VStack(spacing: 24) {
                    gameSetupSectionView
                }
                .padding(.horizontal)
                
                Spacer()
                
                startBattleButton
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
            .infinityFrame()
            
            colorSchemeToggle
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
        }
    }
}

private extension GameSetupView {
    var backgroundGradient: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color.appTheme.accent.opacity(0.12),
                    Color.appTheme.alternateAccent.opacity(0.08),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    var startBattleButton: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .symbolEffect(.bounce, value: true)
            Text("Start Battle")
                .tracking(0.5)
        }
        .font(.title3)
        .fontWeight(.bold)
        .foregroundStyle(Color.appTheme.accentContrastText)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.appTheme.accent, Color.appTheme.accent.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(.button)
        .shadow(.heavy)
        .button(.press) {
            viewModel.startGame()
        }
    }
    
    var logoSection: some View {
        VStack(spacing: 16) {
            Image(.logo)
                .renderingMode(.template)
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
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(Color.appTheme.text)
                
                Text("THE ULTIMATE CHALLENGE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundStyle(Color.appTheme.secondaryText)
            }
        }
    }
    
    var gameSetupSectionView: some View {
        VStack(spacing: 28) {
            PlayerSelectionView(
                player1: $viewModel.player1,
                player2: $viewModel.player2
            )
            
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(title: "Settings")
                
                VStack(spacing: 20) {
                    SelectionGroupView(
                        title: "Difficulty",
                        options: Difficulty.allCases,
                        selected: $viewModel.selectedDifficulty
                    )
                    
                    SelectionGroupView(
                        title: "Who goes first?",
                        options: FirstTurn.allCases,
                        selected: $viewModel.selectedFirstTurn
                    )
                }
                .padding()
                .background(Color.appTheme.cellBackground.opacity(0.6))
                .cornerRadius(.overall)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.overall.value)
                        .stroke(Color.appTheme.divider.opacity(0.5), lineWidth: 1)
                )
            }
        }
    }
    
    func sectionHeader(title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .tracking(2)
            .foregroundStyle(Color.appTheme.secondaryText)
            .padding(.leading, 4)
    }
}

private extension GameSetupView {
    var colorSchemeToggle: some View {
        ZStack {
            Circle()
                .fill(Color.appTheme.cellBackground)
                .frame(width: 44, height: 44)
                .shadow(.light)
            
            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(isDarkMode ? .orange : .indigo)
        }
        .button(.press) {
            toggleColorScheme()
        }
    }
    
    func toggleColorScheme() {
        withAnimation(.spring(duration: 0.5)) {
            isDarkMode.toggle()
        }
    }
}

#Preview {
    GameSetupView()
}
