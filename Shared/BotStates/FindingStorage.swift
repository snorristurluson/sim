//
//  MovingToStorage.swift
//  sim
//
//  Created by Snorri Sturluson on 26/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class FindingStorageState : GKState {
    unowned var bot: Bot

    required init(bot: Bot) {
        self.bot = bot
    }

    override func didEnter(from previousState: GKState?) {
        print(self.bot.name, "Entering FindingStorageState")
        let storage = bot.findClosest(type: Storage.self) as? Storage
        if storage != nil {
            print("Found storage")
            self.bot.setTarget(entity: storage!)
        }
    }

    override func update(deltaTime seconds: TimeInterval) {
        if self.bot.contact == self.bot.target {
            self.bot.stateMachine.enter(MovingToStorageState.self)
        }
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is MovingToStorageState.Type:
            return true
        default:
            return false
        }
    }
}
