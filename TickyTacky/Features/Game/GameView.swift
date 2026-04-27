//
//  GameView.swift
//  TickyTacky
//
//  Created by M1 Pro on 12/4/26.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel : GameViewModel = .init()
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                playersStatsView
                    .padding(.top, 20)
                    .padding(.horizontal)
                
                Spacer()
                
                gameBoardView
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.overall.value * 1.5)
                            .fill(Color.appTheme.cellBackground.opacity(0.3))
                            .blur(radius: 20)
                            .padding(-20)
                    )
                
                Spacer()
                
                actionButtonsView
                    .padding(.bottom, 30)
            }
            .infinityFrame()
            
            achievementNotificationOverlay
            
            if viewModel.showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: .init(get: { viewModel.showWinnerSheet }, set: { _ in })) {
            GameResultView(
                gameState: viewModel.gameState,
                player1: viewModel.player1,
                player2: viewModel.player2
            ) {
                viewModel.resetGame()
            }
        }
    }
}

private extension GameView {
    var backgroundGradient: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color.appTheme.accent.opacity(0.1),
                    Color.appTheme.alternateAccent.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    var playersStatsView: some View {
        HStack {
            PlayerInGameView(
                player: viewModel.player1.profile,
                orientation: .left,
                isCurrentPlayer: viewModel.currentPlayer == viewModel.player1,
                winsCount: viewModel.player1.wins
            )
            
            Spacer()
            
            PlayerInGameView(
                player: viewModel.player2.profile,
                orientation: .right,
                isCurrentPlayer: viewModel.currentPlayer == viewModel.player2,
                winsCount: viewModel.player2.wins
            )
        }
    }
    
    var gameBoardView: some View {
        GameBoardView(
            board: viewModel.board.flattened,
            winningCells: Set(viewModel.winningCells.map { $0.row * GameConstants.boardSize + $0.col }),
            suggestedCell: viewModel.suggestedMove.map { $0.row * GameConstants.boardSize + $0.col },
            onCellTap: { index in
                let row = index / GameConstants.boardSize
                let col = index % GameConstants.boardSize
                viewModel.playHumanMove(row: row, col: col)
            }
        )
        .disabled(viewModel.isPlayHumanMoveDisabled)
    }
    
    var actionButtonsView: some View {
        HStack(spacing: 32) {
            actionButtonView(sfsymbol: "lightbulb.fill")
                .button(.press) {
                    viewModel.getHint()
                }
                .disabled(viewModel.isPlayHumanMoveDisabled)
            
            actionButtonView(sfsymbol: "arrow.clockwise", buttonSize: .large)
                .button(.press) {
                    viewModel.resetGame()
                }
            
            actionButtonView(sfsymbol: "house")
                .button(.press) {
                    viewModel.goSetupMode()
                }
        }
    }

    enum ActionButtonSize {
        case regular, large
        
        var size: CGFloat {
            switch self {
            case .regular: return 48
            case .large: return 64
            }
        }
        
        var font: Font {
            switch self {
            case .regular: return .title3
            case .large: return .title2
            }
        }
    }

    @ViewBuilder
    var achievementNotificationOverlay: some View {
        if let achievement = viewModel.newAchievements.first {
            VStack {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Achievement Unlocked!")
                            .font(.caption.bold())
                            .foregroundStyle(Color.appTheme.secondaryText)
                        Text(achievement.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.appTheme.text)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.appTheme.cellBackground)
                .cornerRadius(.overall)
                .shadow(.regular)
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
                
                Spacer()
            }
            .onAppear {
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation {
                        viewModel.newAchievements.removeAll()
                    }
                }
            }
        }
    }

    func actionButtonView(sfsymbol: String, buttonSize: ActionButtonSize = .regular) -> some View {
        Image(systemName: sfsymbol)
            .font(buttonSize.font)
            .fontWeight(.bold)
            .foregroundStyle(Color.appTheme.text)
            .frame(width: buttonSize.size, height: buttonSize.size)
            .background(Color.appTheme.cellBackground)
            .clipShape(Circle())
            .shadow(.regular)
    }
}

#Preview {
    GameView()
}
