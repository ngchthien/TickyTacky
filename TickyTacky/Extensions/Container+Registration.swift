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
    var gameSetupStore: Factory<GameSetupLiveStore> {
        self { MainActor.assumeIsolated { GameSetupLiveStore() } }.singleton
    }
    
    var errorHandlerService: Factory<ErrorHandlerProtocol> {
        self { MainActor.assumeIsolated { ErrorHandlerService() } }.singleton
    }
    
    var analyticsService: Factory<AnalyticsProtocol> {
        self { MainActor.assumeIsolated { AnalyticsService() } }.singleton
    }
    
    var botEngineService: Factory<BotEngineServiceProtocol> {
        self { MainActor.assumeIsolated { BotEngineService() } }.singleton
    }
    
    var boardLogicService: Factory<BoardLogicServiceProtocol> {
        self { MainActor.assumeIsolated { BoardLogicLiveService() } }.singleton
    }
    
    var gameStore: Factory<GameStore> {
        self { MainActor.assumeIsolated { GameLiveStore() } }.singleton
    }

    var hapticService: Factory<HapticServiceProtocol> {
        self { HapticService() }.singleton
    }

    var historyService: Factory<HistoryServiceProtocol> {
        self { MainActor.assumeIsolated { HistoryService() } }.singleton
    }

    var achievementService: Factory<AchievementServiceProtocol> {
        self { AchievementService() }.singleton
    }
}


