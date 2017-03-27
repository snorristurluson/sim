//
//  FindingRock.swift
//  sim
//
//  Created by Snorri Sturluson on 25/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class FindingRockState : GKState {
    unowned var bot: Bot
    
    required init(bot: Bot) {
        self.bot = bot
    }
    
    override func didEnter(from previousState: GKState?) {
        print(self.bot.name, "Entering FindingRockState")
        let rock = bot.findClosest(type: Rock.self) as? Rock
        if rock != nil {
            self.bot.setTarget(entity: rock!)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if self.bot.target == nil {
            print("Target lost")
            self.bot.stateMachine.enter(FindingRockState.self)
        }
        else if self.bot.contact == self.bot.target {
            self.bot.stateMachine.enter(ExtractingFromRockState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is ExtractingFromRockState.Type, is FindingRockState.Type:
            return true
        default:
            return false
        }
    }
}
