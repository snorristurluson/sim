//
// Created by Snorri Sturluson on 08/04/2017.
// Copyright (c) 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameplayKit

class LabelComponent : GKComponent {
    var label: SKLabelNode
    var extraLines = [SKLabelNode]()
    var parent: SKNode

    let LINEHEIGHT = 24

    init(parent: SKNode) {
        self.parent = parent
        self.label = SKLabelNode.init(text: "This is a label")
        self.label.position = CGPoint(x: 0, y: 32)
        self.label.fontName = "American Typewriter"
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        if self.label.parent == nil {
            parent.addChild(self.label)
        }
    }

    func hide() {
        self.label.removeFromParent()
    }

    func setText(_ text: String) {
        let lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        for item in self.extraLines {
            item.removeFromParent()
        }
        self.extraLines.removeAll()
        if lines.count > 1 {
            self.label.text = ""
            var y = lines.count * LINEHEIGHT
            for line in lines {
                let lineLabel = SKLabelNode(text: line)
                lineLabel.fontName = self.label.fontName
                self.extraLines.append(lineLabel)
                lineLabel.position = CGPoint(x: 0, y: y)
                self.label.addChild(lineLabel)
                y -= LINEHEIGHT
            }
        }
        else {
            self.label.text = text
        }
    }
}