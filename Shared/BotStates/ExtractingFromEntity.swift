//
//  ExtractFromRock.swift
//  sim
//
//  Created by Snorri Sturluson on 25/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class ExtractingFromEntityState: GKState {
    unowned var bot: Bot
    var time: TimeInterval = 0
    
    required init(bot: Bot) {
        self.bot = bot
    }
    
    override func didEnter(from previousState: GKState?) {
        print(self.bot.name, "Entering ExtractingFromEntityState")
        self.time = 0
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.time += seconds
        if self.time > 1.0 {
            print("Taking \(self.bot.resourceTypeWanted) from entity")
            if let target = self.bot.target {
                if let resourceComp = target.component(ofType: ResourceComponent.self) {
                    if resourceComp.takeResource(type: self.bot.resourceTypeWanted) {
                        bot.addResource(Resource.init(type: self.bot.resourceTypeWanted, quantity: 1))
                        if bot.isCargoFull() {
                            self.stateMachine?.enter(FindingStorageState.self)
                        }
                        else if resourceComp.getCount(self.bot.resourceTypeWanted) > 0 {
                            self.stateMachine?.enter(ExtractingFromEntityState.self)
                        }
                    }
                    else {
                        print("Couldn't take \(self.bot.resourceTypeWanted) from the entity")
                        self.stateMachine?.enter(FindingResourceState.self)
                    }
                }
            }
            else {
                print("Target entity lost")
                self.stateMachine?.enter(FindingResourceState.self)
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is FindingResourceState.Type, is ExtractingFromEntityState.Type, is FindingStorageState.Type:
            return true
        default:
            return false
        }
    }
}
