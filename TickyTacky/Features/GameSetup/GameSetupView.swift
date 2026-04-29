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
            
            VStack(spacing: 0) {
                headerActionButtons
                
                VStack(spacing: 24) {
                    playerArenaSection
                    
                    settingsCardSection
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    readyButtonSection
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
        }
    }
}

private extension GameSetupView {
    var backgroundGradient: some View {
        Color.appTheme.viewBackground
            .ignoresSafeArea()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.appTheme.accent.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }

    var playerArenaSection: some View {
        VStack(spacing: 0) {
            PlayerSelectionView(
                player1: $viewModel.player1,
                player2: $viewModel.player2
            )
            .padding(.horizontal)
        }
    }
    
    var settingsCardSection: some View {
        VStack(spacing: 16) {
            SelectionGroupView(
                title: "Difficulty Level",
                options: Difficulty.allCases,
                selected: $viewModel.selectedDifficulty
            )
            
            Divider().background(Color.appTheme.divider.opacity(0.3))
            
            SelectionGroupView(
                title: "First Turn",
                options: FirstTurn.allCases,
                selected: $viewModel.selectedFirstTurn
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                Color.appTheme.cellBackground.opacity(0.4)
                RoundedRectangle(cornerRadius: AppCornerRadius.overall.value)
                    .stroke(Color.appTheme.accent.opacity(0.2), lineWidth: 1)
            }
        )
        .cornerRadius(.overall)
    }
    
    var readyButtonSection: some View {
        Button(action: viewModel.startGame) {
            HStack(spacing: 16) {
                Text("START BATTLE")
                Image(systemName: "chevron.right.2")
            }
            .font(.headline.bold())
            .foregroundStyle(Color.appTheme.accentContrastText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [Color.appTheme.accent, Color.appTheme.alternateAccent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(.button)
            .shadow(color: Color.appTheme.accent.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .button(.press) {}
    }
    
    var headerActionButtons: some View {
        HStack {
            Button(action: viewModel.goHome) {
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
            
            Text("LOCAL BATTLE")
                .font(.system(size: 16, weight: .black))
                .kerning(1)
                .foregroundStyle(Color.appTheme.text)
            
            Spacer()
            
            Circle().fill(Color.clear).frame(width: 44)
        }
        .padding()
    }
}

#Preview {
    GameSetupView()
}
