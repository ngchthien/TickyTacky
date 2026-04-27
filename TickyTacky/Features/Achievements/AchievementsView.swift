//
//  AchievementsView.swift
//  TickyTacky
//
//  Created by Antigravity on 4/27/26.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        progressSection
                        
                        ForEach(viewModel.achievements) { achievement in
                            achievementRow(achievement)
                        }
                    }
                    .padding()
                }
            }
        }
        .infinityFrame()
        .navigationBarBackButtonHidden(true)
    }
}

private extension AchievementsView {
    var backgroundGradient: some View {
        ZStack {
            Color.appTheme.viewBackground.ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color.appTheme.accent.opacity(0.1),
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
            Button(action: { dismiss() }) {
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
            
            Text("Achievements")
                .font(.title2.bold())
                .foregroundStyle(Color.appTheme.text)
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding()
    }
    
    var progressSection: some View {
        let unlockedCount = viewModel.achievements.filter { $0.isUnlocked }.count
        let totalCount = viewModel.achievements.count
        let progress = totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0
        
        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.headline)
                        .foregroundStyle(Color.appTheme.text)
                    Text("\(unlockedCount) of \(totalCount) unlocked")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTheme.secondaryText)
                }
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.title.bold())
                    .foregroundStyle(Color.appTheme.accent)
            }
            
            ProgressView(value: progress)
                .tint(Color.appTheme.accent)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(20)
        .background(Color.appTheme.cellBackground)
        .cornerRadius(.overall)
        .shadow(.light)
        .padding(.bottom, 8)
    }
    
    func achievementRow(_ achievement: Achievement) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.appTheme.accent.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundStyle(achievement.isUnlocked ? Color.appTheme.accent : Color.gray.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(achievement.isUnlocked ? Color.appTheme.text : Color.appTheme.secondaryText)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(Color.appTheme.secondaryText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Color.appTheme.success)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(Color.gray.opacity(0.3))
            }
        }
        .padding()
        .background(Color.appTheme.cellBackground)
        .cornerRadius(.overall)
        .shadow(.light)
        .grayscale(achievement.isUnlocked ? 0 : 1)
        .opacity(achievement.isUnlocked ? 1 : 0.8)
    }
}

#Preview {
    AchievementsView()
}
