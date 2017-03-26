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
        print("Entering FindingRockState")
        let rock = bot.findClosesRock()
        if rock != nil {
            self.bot.setTargetRock(rock: rock!)
            self.bot.goTo(pos: (rock?.getPosition())!)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is ExtractingFromRockState.Type:
            return true
        default:
            return false
        }
    }
}