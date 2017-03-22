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
    fileprivate var targetSprite: SKSpriteNode?
    
    init(pos: CGPoint) {
        super.init()
        let comp = SpriteComponent(name: "bot", color: .green, size: CGSize.init(width: 16, height: 16))
        comp.spriteNode.position = pos
        addComponent(comp)
        
        let nodeComp = GKSKNodeComponent(node: comp.spriteNode)
        addComponent(nodeComp)
        
        let agent = GKAgent2D()
        agent.maxSpeed = 300
        agent.maxAcceleration = 100
        agent.mass = 1
        agent.radius = 1
        agent.delegate = nodeComp
        addComponent(agent)
        
        self.wander()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func wander() {
        let agent = component(ofType: GKAgent2D.self)
        agent?.behavior = GKBehavior.init(goals: [GKGoal.init(toWander: 100)], andWeights: [100])
    }

    func getPosition()-> CGPoint {
        let comp = component(ofType: SpriteComponent.self)
        return (comp?.spriteNode.position)!
    }
    
    func goTo(pos: CGPoint) {
        let agent = self.component(ofType: GKAgent2D.self)
        let myPos = self.getPosition()
        
        let start = float2.init(x: Float(myPos.x), y: Float(myPos.y))
        let end = float2.init(x: Float(pos.x), y: Float(pos.y))
        let path = GKPath.init(points: [start, end], radius: 0.1, cyclical: false)
        agent?.behavior = GKBehavior.init(goals: [GKGoal.init(toStayOn: path, maxPredictionTime: 10)])
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
        if let target = self.targetSprite {
            target.removeFromParent()
        }
        self.targetSprite = SKSpriteNode.init(color: .yellow, size: CGSize.init(width: 8, height: 8))
        self.targetSprite?.position = targetPosition
        world?.addChild(self.targetSprite!)
        
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
