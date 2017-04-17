//
// Created by Snorri Sturluson on 17/04/2017.
// Copyright (c) 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class ProximityComponent : GKComponent {
    var name: String
    var spriteNode: SKNode
    var body: SKPhysicsBody
    init(name: String, radius: Float) {
        self.name = name
        self.spriteNode = SKNode()
        self.spriteNode.name = name
        self.body = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        self.body.categoryBitMask = PROXIMITY
        // Report contact with everything
        self.body.contactTestBitMask = BOT|RESOURCE|BUILDING|PROXIMITY
        // Don't collide with anything
        self.body.collisionBitMask = 0
        self.spriteNode.physicsBody = self.body

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func addToScene(scene: SKScene) {
        scene.addChild(self.spriteNode)
    }

    func removeFromScene(scene: SKScene) {
        self.spriteNode.removeFromParent()
    }
}
