//
//  MovementComponent.swift
//  sim
//
//  Created by Snorri Sturluson on 23/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class MovementComponent : GKComponent {
    var sprite: SKSpriteNode
    var target = CGPoint.zero
    var speed = CGFloat.init(50.0)
    var power = CGFloat.init(0.01)
    
    init(body: SKSpriteNode) {
        self.sprite = body
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTarget(pos: CGPoint) {
        self.target = pos
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let currentPosition = self.sprite.position
        let v = CGVector.init(dx: self.target.x - currentPosition.x, dy: self.target.y - currentPosition.y)
        let vn = CGVectorNormalize(v: v)
        let desiredVelocity = CGVector.init(dx: vn.dx * self.speed, dy: vn.dy * self.speed)
        let currentVelocity = (self.sprite.physicsBody?.velocity)!
        let d = CGVector.init(dx: desiredVelocity.dx - currentVelocity.dx, dy: desiredVelocity.dy - currentVelocity.dy)
        let dt = CGFloat.init(seconds)
        let dScaled = CGVector.init(dx: d.dx * self.power * dt, dy: d.dy * self.power * dt)
        self.sprite.physicsBody?.applyImpulse(dScaled)
    }
}
