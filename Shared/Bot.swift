//
//  Bot.swift
//  sim
//
//  Created by Snorri Sturluson on 19/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

class Bot : GKEntity {
    init(pos: CGPoint) {
        super.init()
        let comp = SpriteComponent(color: .green, size: CGSize.init(width: 16, height: 16))
        comp.spriteNode.position = pos
        addComponent(comp)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addToScene(scene: SKScene) {
        let comp = component(ofType: SpriteComponent.self)
        scene.addChild((comp?.spriteNode)!)
    }
    
    func getPosition()-> CGPoint {
        let comp = component(ofType: SpriteComponent.self)
        return (comp?.spriteNode.position)!
    }
    
    func goTo(pos: CGPoint) {
        let comp = component(ofType: SpriteComponent.self)
        let myPos = (comp?.spriteNode.position)!

        let v = CGVector.init(dx: pos.x - myPos.x, dy: pos.y - myPos.y)
        let vn = CGVectorNormalize(v: v)
        let speed = CGFloat.init(200.0)
        comp?.spriteNode.physicsBody?.velocity = CGVector.init(dx: vn.dx * speed, dy: vn.dy * speed)
    }

    func selectTarget(targets: Set<SKSpriteNode>) {
        let myPos = self.getPosition()
        var closestDistance = CGFloat.infinity
        var target = targets.first
        for candidate in targets {
            let distance = CGPointDistance(from: myPos, to: candidate.position)
            if distance < closestDistance {
                target = candidate
                closestDistance = distance
            }
        }
        let pos = (target?.position)!
        self.goTo(pos: pos)
    }
    
}
