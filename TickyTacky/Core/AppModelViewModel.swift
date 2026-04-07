//
//  AppModelViewModel.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import Foundation
import Combine
import Factory
final class AppModelViewModel:ObservableObject{
  @Published var appMode: AppMode = .gameSetup
  private var cancellables = Set<AnyCancellable>()
 @Injected(\.appModeStore) var appModeStore
  
 
  
  init()  {
   setSubscribers()
  }
}

private extension AppModelViewModel{
  func setSubscribers()
  {
    appModeStore.$appMode
      .receive(on: DispatchQueue.main)
      .sink{[weak self] _ in
        guard let self else {return}
         updateAppMode()
      }.store(in: &cancellables)
  }
  func updateAppMode()
  {
    appMode = appModeStore.appMode
  }
}
