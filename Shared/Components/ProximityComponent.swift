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
    var proximity = Set<GKEntity>()
    var proximityRenderer: SKShapeNode?

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

    override func update(deltaTime seconds: TimeInterval) {
        if let spriteComp = self.entity?.component(ofType: SpriteComponent.self) {
            self.spriteNode.position = spriteComp.spriteNode.position
        }
        self.updateProximityRenderer()
    }

    func updateProximityRenderer() {
        if let current = self.proximityRenderer {
            current.removeFromParent()
        }
        let myPos = self.spriteNode.position
        var points = [CGPoint]()
        for entity in self.proximity {
            if let spriteComp = entity.component(ofType: SpriteComponent.self) {
                let otherPos = spriteComp.spriteNode.position
                points.append(myPos)
                points.append(otherPos)
            }
        }
        self.proximityRenderer = SKShapeNode(points: &points, count: points.count)
        world!.addChild(self.proximityRenderer!)
    }
}
