//
// Created by Snorri Sturluson on 08/04/2017.
// Copyright (c) 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class LabelComponent : GKComponent {
    var label: SKLabelNode
    var parent: SKNode

    init(parent: SKNode) {
        self.parent = parent
        self.label = SKLabelNode.init(text: "This is a label")
        self.label.position = CGPoint(x: 0, y: 32)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        parent.addChild(self.label)
    }

    func hide() {
        self.label.removeFromParent()
    }

    func setText(_ text: String) {
        self.label.text = text
    }
}