//
//  Container+Registration.swift
//  TickyTacky
//
//  Created by M1 Pro on 7/4/26.
//

import Factory


extension Container{
  
  var appModeStore: Factory<AppModeLiveStore>{
    self{
      MainActor.assumeIsolated {AppModeLiveStore()}
    }.singleton
    
  }
  var gameSetupStore: Factory<GameSetupLiveStore>
  {
    self{
      MainActor.assumeIsolated{ GameSetupLiveStore()}
    }.singleton
  }
}


