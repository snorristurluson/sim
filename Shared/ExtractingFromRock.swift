//
//  ExtractFromRock.swift
//  sim
//
//  Created by Snorri Sturluson on 25/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class ExtractingFromRockState : GKState {
    unowned var bot: Bot
    var time: TimeInterval = 0
    
    required init(bot: Bot) {
        self.bot = bot
    }
    
    override func didEnter(from previousState: GKState?) {
        print(self.bot.name, "Entering ExtractingFromRockState")
        self.time = 0
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.time += seconds
        if self.time > 1.0 {
            print("Taking \(self.bot.resourceTypeWanted) from rock")

            if let rock = self.bot.target as? Rock {
                if rock.takeResource(type: self.bot.resourceTypeWanted) {
                    bot.addResource(Resource.init(type: self.bot.resourceTypeWanted, quantity: 1))
                    if bot.isCargoFull() {
                        self.stateMachine?.enter(FindingStorageState.self)
                    }
                    else if rock.hasResource(type: self.bot.resourceTypeWanted) {
                        self.stateMachine?.enter(ExtractingFromRockState.self)
                    }
                }
                else {
                    print("Couldn't take \(self.bot.resourceTypeWanted) from the rock")
                    self.stateMachine?.enter(FindingRockState.self)
                }
            }
            else {
                print("Target rock lost")
                self.stateMachine?.enter(FindingRockState.self)
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is FindingRockState.Type, is ExtractingFromRockState.Type, is FindingStorageState.Type:
            return true
        default:
            return false
        }
    }
}
