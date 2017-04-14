//
//  MovingToStorage.swift
//  sim
//
//  Created by Snorri Sturluson on 26/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class MovingToStorageState : GKState {
    unowned var bot: Bot
    var storage: Storage?
    var time = 0.0
    
    required init(bot: Bot) {
        self.bot = bot
    }
    
    override func didEnter(from previousState: GKState?) {
        print(self.bot.name, "Entering MovingToStorageState")
        self.time = 0
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.time += seconds
        if self.time > 1.0 {
            let storage = self.bot.target as! Storage
            self.bot.moveCargoToStorage(storage)
            self.bot.resourceTypeWanted = storage.wantResource
            self.bot.stateMachine.enter(FindingRockState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is FindingRockState.Type:
            return true
        default:
            return false
        }
    }
}
