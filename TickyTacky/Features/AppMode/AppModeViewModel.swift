//
//  AppModelViewModel.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import Foundation
import Combine
import Factory
final class AppModeViewModel:ObservableObject{
  @Published var appMode: AppMode = .gameSetup
  private var cancellables = Set<AnyCancellable>()
 @Injected(\.appModeStore) var appModeStore
  
 
  
  init()  {
   setSubscribers()
  }
}

private extension AppModeViewModel{
  func setSubscribers()
  {
    appModeStore.$appMode
      .receive(on: DispatchQueue.main)
      .assign(to: &$appMode)
  }
  func updateAppMode()
  {
    appMode = appModeStore.appMode
  }
}
