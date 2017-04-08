//
// Created by Snorri Sturluson on 08/04/2017.
// Copyright (c) 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class ResourceComponent : GKComponent {
    var resources = [String: Int]()
    func getCount(_ type: String) -> Int {
        if let count = self.resources[type] {
            return count
        }
        return 0
    }

    func takeResource(type: String) -> Bool {
        var currentValue = self.resources[type]
        if currentValue == nil {
            currentValue = 0
        }

        if currentValue! > 0 {
            currentValue! -= 1
            self.resources[type] = currentValue!
            return true
        }
        return false
    }
}