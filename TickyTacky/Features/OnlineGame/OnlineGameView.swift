//
//  OnlineGameView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI

struct OnlineGameView: View {
    @StateObject private var viewModel: OnlineGameViewModel
    
    init(roomID: String) {
        _viewModel = StateObject(wrappedValue: OnlineGameViewModel(roomID: roomID))
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerView
                    
                    playersSection
                    
                    Group {
                        if viewModel.room?.status == "waiting" {
                            waitingStateView
                        } else if viewModel.room?.status == "finished" {
                            resultStateView
                        } else {
                            boardSection
                        }
                    }
                    .transition(.opacity.combined(with: .scale(0.95)))
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .bottom) {
                if viewModel.room?.status != "finished" {
                    quitButton
                        .background(
                            Color.appTheme.viewBackground
                                .mask(LinearGradient(gradient: Gradient(colors: [.clear, .black, .black]), startPoint: .top, endPoint: .bottom))
                                .ignoresSafeArea()
                        )
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.room?.id)
            .animation(.spring(), value: viewModel.room?.status)
            .animation(.spring(), value: viewModel.room?.player2ID)
            
            if viewModel.showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if !viewModel.newAchievements.isEmpty {
                achievementPopup
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .infinityFrame()
        .sheet(isPresented: $viewModel.showQRCode) {
            qrCodeSheet
        }
    }
}

private extension OnlineGameView {
    var backgroundGradient: some View {
        Color.appTheme.viewBackground.ignoresSafeArea()
    }
    
    var headerView: some View {
        VStack(spacing: 8) {
            Text("ROOM CODE")
                .font(.caption.bold())
                .foregroundStyle(Color.appTheme.secondaryText)
            
            HStack(spacing: 12) {
                Text(viewModel.roomID)
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.appTheme.accent)
                
                HStack(spacing: 8) {
                    Button(action: {
                        UIPasteboard.general.string = viewModel.roomID
                    }) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTheme.accent)
                            .padding(8)
                            .background(Color.appTheme.accent.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    ShareLink(item: "Join my TickyTacky game! Room Code: \(viewModel.roomID)") {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTheme.accent)
                            .padding(8)
                            .background(Color.appTheme.accent.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        viewModel.showQRCode = true
                        viewModel.hapticService.triggerImpact(style: .light)
                    }) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTheme.accent)
                            .padding(8)
                            .background(Color.appTheme.accent.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.top, 10)
    }
    
    var qrCodeSheet: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("SCAN TO JOIN")
                    .font(.headline.bold())
                    .foregroundStyle(Color.appTheme.secondaryText)
                
                Text("Room Code: \(viewModel.roomID)")
                    .font(.title2.bold().monospaced())
                    .foregroundStyle(Color.appTheme.accent)
            }
            
            if let image = viewModel.qrCodeImage {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            } else {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            
            Button(action: { viewModel.showQRCode = false }) {
                Text("Done")
                    .font(.headline.bold())
                    .foregroundStyle(Color.appTheme.accentContrastText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appTheme.accent)
                    .cornerRadius(.button)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    var achievementPopup: some View {
        VStack {
            ForEach(viewModel.newAchievements) { achievement in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.appTheme.accent.opacity(0.1))
                            .frame(width: 50, height: 50)
                        Image(systemName: achievement.icon)
                            .foregroundStyle(Color.appTheme.accent)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Achievement Unlocked!")
                            .font(.caption.bold())
                            .foregroundStyle(Color.appTheme.accent)
                        Text(achievement.title)
                            .font(.headline)
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundStyle(Color.appTheme.secondaryText)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.appTheme.cellBackground)
                .cornerRadius(.overall)
                .shadow(.regular)
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding(.top, 50)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    viewModel.newAchievements = []
                }
            }
        }
    }
    
    var playersSection: some View {
        HStack(spacing: 16) {
            // Player 1 Slot
            VStack(spacing: 10) {
                if let p1Name = viewModel.room?.player1Name, viewModel.room?.player1ID != nil {
                    PlayerInGameView(
                        player: PlayerProfile(name: .custom(p1Name), image: .playerBoy1, type: .human),
                        orientation: .left,
                        isCurrentPlayer: viewModel.room?.currentTurn == viewModel.room?.player1ID && viewModel.room?.status == "playing",
                        winsCount: 0
                    )
                    readyIndicator(isReady: viewModel.room?.player1Ready ?? false)
                } else {
                    emptyPlayerSlot(title: "Host")
                }
            }
            
            Text("VS")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Color.appTheme.accent.opacity(0.5))
                .padding(.horizontal, 4)
            
            // Player 2 Slot
            VStack(spacing: 10) {
                if let p2Name = viewModel.room?.player2Name, viewModel.room?.player2ID != nil {
                    PlayerInGameView(
                        player: PlayerProfile(name: .custom(p2Name), image: .playerBoy2, type: .human),
                        orientation: .right,
                        isCurrentPlayer: viewModel.room?.currentTurn == viewModel.room?.player2ID && viewModel.room?.status == "playing",
                        winsCount: 0
                    )
                    readyIndicator(isReady: viewModel.room?.player2Ready ?? false)
                } else {
                    emptyPlayerSlot(title: "Opponent")
                }
            }
        }
        .padding(20)
        .background(Color.appTheme.cellBackground.opacity(0.4))
        .cornerRadius(.overall)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.overall.value)
                .stroke(Color.appTheme.accent.opacity(0.1), lineWidth: 1)
        )
    }
    
    func emptyPlayerSlot(title: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(Color.appTheme.secondaryText.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.badge.plus")
                    .foregroundStyle(Color.appTheme.secondaryText.opacity(0.5))
            }
            
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(Color.appTheme.secondaryText.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
    
    func readyIndicator(isReady: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "hourglass.circle")
            Text(isReady ? "Ready" : "Waiting")
        }
        .font(.caption.bold())
        .foregroundStyle(isReady ? .green : Color.appTheme.secondaryText)
    }
    
    var waitingStateView: some View {
        VStack(spacing: 32) {
            if viewModel.room?.player2ID == nil {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Waiting for an opponent...")
                        .font(.headline)
                        .foregroundStyle(Color.appTheme.secondaryText)
                    Text("Share code \(viewModel.roomID) with a friend.")
                        .font(.caption)
                }
            } else {
                VStack(spacing: 24) {
                    Text("ARE YOU READY?")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Color.appTheme.accent)
                    
                    Button(action: viewModel.toggleReady) {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.isReady ? "checkmark.circle.fill" : "play.circle.fill")
                            Text(viewModel.isReady ? "I'M READY!" : "READY TO PLAY")
                        }
                        .font(.headline.bold())
                        .foregroundStyle(Color.appTheme.accentContrastText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            viewModel.isReady ? Color.green : Color.appTheme.accent
                        )
                        .cornerRadius(.button)
                        .shadow(.regular)
                    }
                    .button(.press) {}
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(maxHeight: 300)
    }
    
    var resultStateView: some View {
        VStack(spacing: 24) {
            Text(viewModel.gameResultText ?? "Match Ended")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(Color.appTheme.accent)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                Button(action: viewModel.restartGame) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                    }
                    .font(.headline.bold())
                    .foregroundStyle(Color.appTheme.accentContrastText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appTheme.accent)
                    .cornerRadius(.button)
                    .shadow(.regular)
                }
                .button(.press) {}
                
                Button(action: viewModel.quitGame) {
                    Text("Quit to Menu")
                        .font(.headline)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
            }
            .padding(.horizontal, 40)
        }
        .frame(maxHeight: 300)
    }
    
    var boardSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Text(viewModel.isMyTurn ? "Your Turn!" : "Waiting for opponent...")
                    .font(.headline.bold())
                    .foregroundStyle(viewModel.isMyTurn ? Color.appTheme.accent : Color.appTheme.secondaryText)
                
                if viewModel.isMyTurn {
                    countdownView
                }
            }
            
            GameBoardView(
                board: viewModel.board.flatMap { $0 },
                winningCells: Set(viewModel.displayWinningCells.map { $0.row * 3 + $0.col }),
                onCellTap: { index in
                    viewModel.playMove(index: index)
                }
            )
            .disabled(!viewModel.isMyTurn)
            .opacity(viewModel.isMyTurn ? 1 : 0.8)
        }
    }
    
    var countdownView: some View {
        let progress = Double(viewModel.turnCountdown) / 10.0
        let isUrgent = viewModel.turnCountdown <= 3
        let color: Color = isUrgent ? .red : (viewModel.turnCountdown <= 5 ? .orange : Color.appTheme.accent)
        return ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: viewModel.turnCountdown)
            Text("\(viewModel.turnCountdown)")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(color)
        }
        .frame(width: 30, height: 30)
        .scaleEffect(isUrgent ? 1.1 : 1.0)
        .animation(.spring(duration: 0.3), value: isUrgent)
    }

    
    var quitButton: some View {
        Button(action: viewModel.quitGame) {
            Text("Quit Match")
                .font(.headline)
                .foregroundStyle(.red)
                .padding()
        }
    }
}

#Preview {
    OnlineGameView(roomID: "1234")
}
