//
//  PlayerSelectionView.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import SwiftUI

struct PlayerSelectionView: View {
  
  @Binding var player1: PlayerProfile
  @Binding var player2: PlayerProfile
  
  private let humanAvatars: [ImageResource] = [.playerBoy1, .playerBoy2, .playerGirl1, .playerGirl2]
  private let botAvatar: ImageResource = .playerBot1
  
    var body: some View {
      HStack(spacing: 8){
       playerView(profile:$player1, isBotToggleEnabled: false)
        Spacer()
      versusTextView
        Spacer()
       playerView(profile:$player2, isBotToggleEnabled: true)
        
      }
      .padding(12)
      .background(Color.appTheme.cellBackground)
      .cornerRadius(.cell)
    }
}

private extension PlayerSelectionView{
  var versusTextView:some View{
    Text("vs")
      .font(.title2)
      .fontWeight(.medium)
      .foregroundStyle(Color.appTheme.alternateAccent)
  }
  func playerView(profile:Binding<PlayerProfile>, isBotToggleEnabled:Bool) -> some View{
    VStack(spacing: 8){
      characterImageArrowSwitcher(profile:profile)
      characterImageView(profile: profile.wrappedValue)
      
      HStack(spacing: 4){
        playerNameTextView(profile: profile.wrappedValue)
        if isBotToggleEnabled{
          playerTypeToggleBtn(profile: profile)
        }
      }
    }
  }
  
  func characterImageArrowSwitcher(profile:Binding<PlayerProfile>) -> some View{
    Image(systemName: "arrowtriangle.up.fill")
      .font(.title2)
      .foregroundStyle(profile.wrappedValue.type.isBot ? Color.appTheme.alternateAccent : Color.appTheme.accent)
      .opacity(profile.wrappedValue.type.isBot ? 0.3 : 1)
      .button(.press) {
        withAnimation(.easeInOut){
          switchHumanImage(profile:profile)
          }
      }
     
  }
  
  func playerNameTextView(profile: PlayerProfile) -> some View {
    Text(profile.name.description)
      .font(.headline)
      .foregroundStyle(profile.type.isBot ? Color.appTheme.alternateAccent : Color.appTheme.accent)
  }

  func playerTypeToggleBtn(profile: Binding<PlayerProfile>) -> some View {
    Image(systemName: "arrowtriangle.right.fill")
      .font(.caption)
      .foregroundStyle(profile.wrappedValue.type.isBot ? Color.appTheme.alternateAccent : Color.appTheme.accent)
      .button {
        withAnimation(.easeInOut) {
          switchPlayerType(profile: profile)
        }
      }
  }
  func characterImageView(profile: PlayerProfile) -> some View{
    Image(profile.image)
      .resizable()
      .scaledToFit()
      .padding(8)
      .background(Color(.systemGray6))
      .cornerRadius(.overall)
      .overlay(
        RoundedRectangle(cornerRadius: AppCornerRadius.overall.value)
          .stroke(profile.type.isBot ? Color.appTheme.alternateAccent : Color.appTheme.accent,
                  lineWidth: 0.2)
      )
      .frame(
        width: 90,height: 90
      )
  }
}
private extension PlayerSelectionView{
  func switchHumanImage(profile:Binding<PlayerProfile>)
  {
    guard profile.wrappedValue.type.isHuman else{return}
    if let currentImageIndex = humanAvatars.firstIndex(of: profile.wrappedValue.image){
      profile.wrappedValue.image = humanAvatars[(
        currentImageIndex + 1
      ) % humanAvatars.count]
    }else{
      profile.wrappedValue.image = .playerBoy1
    }
  }
  func switchPlayerType(profile: Binding<PlayerProfile>)
  {
    if profile.wrappedValue.type.isHuman {
      profile.wrappedValue = .init(name: .ai, image: botAvatar, type: .bot)
    }else{
      profile.wrappedValue = .init(name: .player2, image: humanAvatars.first ?? .playerBoy1, type: .human)
    }
  }
}

#Preview {
  Preview()
}

fileprivate struct Preview :View {
  @State private var player1: PlayerProfile = .defaultPlayer1
  @State private var player2: PlayerProfile = .defaultPlayer2
  
  var body: some View{
    PlayerSelectionView (
    player1: $player1,
    player2:$player2
    )
    .infinityFrame()
    .padding()
    .background(Color.appTheme.viewBackground)
    
  }
}
