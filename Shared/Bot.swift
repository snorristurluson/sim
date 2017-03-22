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
        let comp = SpriteComponent(name: "bot", color: .green, size: CGSize.init(width: 16, height: 16))
        comp.spriteNode.position = pos
        addComponent(comp)
        addComponent(GKSKNodeComponent(node: comp.spriteNode))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func selectTarget() {
        let myPos = self.getPosition()
        var closestDistance = CGFloat.infinity
        var targetPosition = CGPoint.init(x: 0, y: 0)
        for candidate in (world?.targets)! {
            let spriteComp = candidate.component(ofType: SpriteComponent.self)
            if spriteComp != nil {
                let candidatePosition = spriteComp?.spriteNode.position
                let distance = CGPointDistance(from: myPos, to: candidatePosition!)
                if distance < closestDistance {
                    targetPosition = candidatePosition!
                    closestDistance = distance
                }
            }
        }
        self.goTo(pos: targetPosition)
    }
    
    func HandleContact(other: GKEntity?) {
        if other == nil {
            return
        }
        
        if (other?.isKind(of: Rock.self))! {
            world?.removeTarget(target: other!)
            self.selectTarget()
        }
    }
    
}
