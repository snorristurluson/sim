//
//  FindingResource.swift
//  sim
//
//  Created by Snorri Sturluson on 25/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class FindingResourceState: GKState {
    unowned var bot: Bot
    
    required init(bot: Bot) {
        self.bot = bot
    }
    
    override func didEnter(from previousState: GKState?) {
        print(self.bot.name, "Entering FindingResourceState")
        if let entity = bot.findClosest(resource: self.bot.resourceTypeWanted) {
            self.bot.setTarget(entity: entity)
        }
        else {
            print(self.bot.name, "Couldn't find any", self.bot.resourceTypeWanted)
            commandCenter.getAssignment(bot: self.bot)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if self.bot.target == nil {
            print("Target lost")
            commandCenter.getAssignment(bot: self.bot)
        }
        else if self.bot.contact.contains(self.bot.target!) {
            self.bot.stateMachine.enter(ExtractingFromEntityState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is ExtractingFromEntityState.Type, is FindingResourceState.Type:
            return true
        default:
            return false
        }
    }
}
