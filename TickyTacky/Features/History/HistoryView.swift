//
//  HistoryView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerView
                
                if viewModel.matches.isEmpty {
                    emptyStateView
                } else {
                    historyList
                }
            }
        }
        .infinityFrame()
    }
}

private extension HistoryView {
    var backgroundGradient: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color.appTheme.accent.opacity(0.08),
                    Color.appTheme.alternateAccent.opacity(0.05),
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
            
            Text("Match History")
                .font(.title2.bold())
                .foregroundStyle(Color.appTheme.text)
            
            Spacer()
            
            Button(action: viewModel.clearHistory) {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundStyle(Color.appTheme.destructive)
                    .frame(width: 44, height: 44)
                    .background(Color.appTheme.cellBackground)
                    .clipShape(Circle())
                    .shadow(.light)
            }
            .button(.press) {}
            .opacity(viewModel.matches.isEmpty ? 0 : 1)
        }
        .padding()
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(Color.appTheme.secondaryText.opacity(0.3))
            
            Text("No matches yet")
                .font(.headline)
                .foregroundStyle(Color.appTheme.secondaryText)
            
            Text("Your battle history will appear here.")
                .font(.subheadline)
                .foregroundStyle(Color.appTheme.secondaryText.opacity(0.7))
            
            Spacer()
        }
    }
    
    var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.matches) { match in
                    HistoryRow(match: match, formattedDuration: viewModel.formatDuration(match.duration))
                }
            }
            .padding()
        }
    }
}

struct HistoryRow: View {
    let match: MatchHistory
    let formattedDuration: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(match.date, style: .date)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTheme.secondaryText)
                
                Spacer()
                
                Text(LocalizedStringKey(match.difficulty.uppercased()))
                    .font(.system(size: 10, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appTheme.accent.opacity(0.1))
                    .foregroundStyle(Color.appTheme.accent)
                    .cornerRadius(4)
            }
            
            HStack(spacing: 20) {
                playerView(name: match.player1Name, isWinner: match.winnerName == match.player1Name)
                
                VStack(spacing: 4) {
                    Text("VS")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.appTheme.secondaryText.opacity(0.5))
                    
                    Text(formattedDuration)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
                
                playerView(name: match.player2Name, isWinner: match.winnerName == match.player2Name)
            }
            
            resultTag
        }
        .padding()
        .background(Color.appTheme.cellBackground)
        .cornerRadius(.overall)
        .shadow(.light)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.overall.value)
                .stroke(resultColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    func playerView(name: String, isWinner: Bool) -> some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.subheadline.bold())
                .foregroundStyle(isWinner ? Color.appTheme.accent : Color.appTheme.text)
                .lineLimit(1)
            
            if isWinner {
                Text("WINNER")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(Color.appTheme.success)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    var resultTag: some View {
        Text(LocalizedStringKey(match.resultType.uppercased()))
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(resultColor)
            .clipShape(Capsule())
    }
    
    var resultColor: Color {
        switch match.resultType {
        case "Win": return Color.appTheme.success
        case "Loss": return Color.appTheme.destructive
        default: return Color.appTheme.secondaryText
        }
    }
}

#Preview {
    HistoryView()
}
