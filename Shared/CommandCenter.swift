//
// Created by Snorri Sturluson on 15/04/2017.
// Copyright (c) 2017 Snorri Sturluson. All rights reserved.
//

import Foundation

class CommandCenter {
    var resourceTypes = ["iron", "copper", "zinc", "wood", "firewood"]

    func getAssignment(bot: Bot) {
        let ix = random.nextInt(upperBound: resourceTypes.count - 1)
        bot.resourceTypeWanted = resourceTypes[ix]
        bot.stateMachine.enter(FindingResourceState.self)
    }
}
