//
//  SpriteComponent.swift
//  sim
//
//  Created by Snorri Sturluson on 19/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

class SpriteComponent : GKComponent {
    let spriteNode : SKSpriteNode
    
    init(name: String, color: SKColor, size: CGSize) {
        self.spriteNode = SKSpriteNode.init(color: color, size: size)
        self.spriteNode.name = name
        let radius = size.width / 2
        let physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
        self.spriteNode.physicsBody = physicsBody
        physicsBody.contactTestBitMask = physicsBody.collisionBitMask
        physicsBody.allowsRotation = false

        super.init()
    }

    init(name: String, imageNamed: String) {
        self.spriteNode = SKSpriteNode.init(imageNamed: imageNamed)
        self.spriteNode.name = name

        let radius = self.spriteNode.size.width / 2
        let physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
        self.spriteNode.physicsBody = physicsBody
        physicsBody.contactTestBitMask = physicsBody.collisionBitMask

        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
