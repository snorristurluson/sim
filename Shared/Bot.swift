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
    var targetRock: Rock?
    var stateMachine: GKStateMachine!
    
    init(pos: CGPoint) {
        super.init()
        
        let comp = SpriteComponent(name: "bot", color: .green, size: CGSize.init(width: 16, height: 16))
        comp.spriteNode.position = pos
        addComponent(comp)

        addComponent(GKSKNodeComponent(node: comp.spriteNode))

        let movement = MovementComponent(body: comp.spriteNode)
        addComponent(movement)
        
        stateMachine = GKStateMachine( states: [
            FindingRockState(bot: self),
            ExtractingFromRockState(bot: self)
        ])
        
        stateMachine.enter(FindingRockState.self)
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
        let movement = self.component(ofType: MovementComponent.self)
        movement?.setTarget(pos: pos)
    }

    func findClosesRock() -> Rock? {
        let myPos = self.getPosition()
        var closestDistance = CGFloat.infinity
        var targetRock: Rock?
        for candidate in (world?.targets)! {
            let rock = candidate as? Rock
            if rock != nil {
                let spriteComp = candidate.component(ofType: SpriteComponent.self)
                if spriteComp != nil {
                    let candidatePosition = spriteComp?.spriteNode.position
                    let distance = CGPointDistance(from: myPos, to: candidatePosition!)
                    if distance < closestDistance {
                        closestDistance = distance
                        targetRock = rock
                    }
                }
            }
        }
        
        return targetRock
    }
    
    func setTargetRock(rock: Rock) {
        self.targetRock = rock
        let targetPosition = rock.getPosition()
        if let target = self.targetSprite {
            target.removeFromParent()
        }

        self.targetSprite = SKSpriteNode.init(color: .yellow, size: CGSize.init(width: 8, height: 8))
        self.targetSprite?.position = targetPosition
        world?.addChild(self.targetSprite!)
    }
    
    func addResource(type: String, quantity: Int) {
        print("Bot collected", quantity, type)
    }
    
    func HandleContact(other: GKEntity?) {
        if other == nil {
            return
        }
        
        if (other?.isKind(of: Rock.self))! {
            if other == self.targetRock {
                self.stateMachine.enter(ExtractingFromRockState.self)
            }
        }
    }
    
}
