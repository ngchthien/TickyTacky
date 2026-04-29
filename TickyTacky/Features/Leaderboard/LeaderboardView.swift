//
//  LeaderboardView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/29/26.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    var body: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if viewModel.isLoading && viewModel.entries.isEmpty {
                    Spacer()
                    ProgressView()
                        .tint(Color.appTheme.accent)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    errorStateView(error)
                } else {
                    entriesList
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private extension LeaderboardView {
    var headerView: some View {
        HStack {
            Button(action: { viewModel.goHome() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTheme.accent)
                    .padding(12)
                    .background(Color.appTheme.accent.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("LEADERBOARD")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Color.appTheme.accent)
                
                Text("Top Global Players")
                    .font(.caption.bold())
                    .foregroundStyle(Color.appTheme.secondaryText)
            }
            
            Spacer()
            
            Button(action: { 
                viewModel.fetchScores()
                viewModel.hapticService.triggerImpact(style: .light)
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTheme.accent)
                    .padding(12)
                    .background(Color.appTheme.accent.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.appTheme.viewBackground)
    }
    
    var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.entries.enumerated()), id: \.offset) { index, entry in
                    leaderboardRow(entry: entry, rank: index + 1)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.fetchScores()
        }
    }
    
    func leaderboardRow(entry: LeaderboardEntry, rank: Int) -> some View {
        HStack(spacing: 16) {
            // Rank Number
            ZStack {
                if rank <= 3 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(rankColor(rank).opacity(0.2))
                }
                
                Text("\(rank)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(rankColor(rank))
            }
            .frame(width: 40)
            
            // Name and Avatar
            HStack(spacing: 12) {
                Circle()
                    .fill(rankColor(rank).opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(entry.name.prefix(1).uppercased())
                            .font(.headline.bold())
                            .foregroundStyle(rankColor(rank))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name)
                        .font(.headline)
                        .foregroundStyle(Color.appTheme.text)
                    
                    Text("Player")
                        .font(.caption2)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
            }
            
            Spacer()
            
            // Points
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.points)")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTheme.accent)
                
                Text("POINTS")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(Color.appTheme.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appTheme.accent.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.appTheme.cellBackground)
        .cornerRadius(.overall)
        .shadow(.light)
    }
    
    func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return Color.appTheme.accent
        }
    }
    
    func errorStateView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            Text("Unable to load leaderboard")
                .font(.headline)
            Text(error)
                .font(.caption)
                .foregroundStyle(Color.appTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                viewModel.fetchScores()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}
