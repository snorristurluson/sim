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
    var name: String
    weak var target: GKEntity?
    weak var contact: GKEntity?
    
    var stateMachine: GKStateMachine!
    
    var cargo = [Resource]()
    
    init(name: String, pos: CGPoint) {
        self.name = name
        
        super.init()

        let comp = SpriteComponent(name: "bot", color: .green, size: CGSize.init(width: 16, height: 16))
        comp.spriteNode.position = pos
        addComponent(comp)

        addComponent(GKSKNodeComponent(node: comp.spriteNode))

        let movement = MovementComponent(body: comp.spriteNode)
        addComponent(movement)
        
        stateMachine = GKStateMachine( states: [
            FindingRockState(bot: self),
            ExtractingFromRockState(bot: self),
            MovingToStorageState(bot: self)
        ])
        
        stateMachine.enter(FindingRockState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPosition()-> CGPoint {
        let comp = component(ofType: SpriteComponent.self)
        return (comp?.spriteNode.position)!
    }
    
    func goTo(pos: CGPoint) {
        let movement = self.component(ofType: MovementComponent.self)
        movement?.setTarget(pos: pos)
    }

    func findClosest(type: AnyClass) -> GKEntity? {
        let myPos = self.getPosition()
        var closestDistance = CGFloat.infinity
        var target: GKEntity?
        for candidate in (world?.targets)! {
            if candidate.isKind(of: type) {
                let spriteComp = candidate.component(ofType: SpriteComponent.self)
                if spriteComp != nil {
                    let candidatePosition = spriteComp?.spriteNode.position
                    let distance = CGPointDistance(from: myPos, to: candidatePosition!)
                    if distance < closestDistance {
                        closestDistance = distance
                        target = candidate
                    }
                }
            }
        }
        
        return target
    }
    
    func setTarget(entity: GKEntity) {
        self.target = entity
        let spriteComp = entity.component(ofType: SpriteComponent.self)
        let targetPosition = spriteComp?.spriteNode.position
        if let currentTargetSprite = self.targetSprite {
            currentTargetSprite.removeFromParent()
        }

        self.targetSprite = SKSpriteNode.init(color: .yellow, size: CGSize.init(width: 8, height: 8))
        self.targetSprite?.position = targetPosition!
        world?.addChild(self.targetSprite!)
    }
    
    func addResource(_ resource: Resource) {
        print("Bot collected", resource.quantity, resource.type)
        self.cargo.append(resource)
    }
    
    func moveCargoToStorage(_ storage: Storage) {
        var remainingCargo = [Resource]()
        for resource in self.cargo {
            let leftover = storage.addResource(resource)
            if leftover > 0 {
                remainingCargo.append(Resource.init(type: resource.type, quantity: leftover))
            }
        }
        self.cargo = remainingCargo
    }
    
    func isCargoFull() -> Bool {
        print("Cargo contains", self.cargo.count, "items")
        if self.cargo.count >= 3 {
            return true
        }
        return false
    }
    
    func HandleContact(other: GKEntity?) {
        self.contact = other
    }
    
}
