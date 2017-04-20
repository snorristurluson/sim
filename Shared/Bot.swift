//
//  Bot.swift
//  sim
//
//  Created by Snorri Sturluson on 19/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class Bot : GKEntity {
    fileprivate var targetSprite: SKSpriteNode?
    var name: String
    var resourceTypeWanted = "iron"
    weak var target: GKEntity?
    var contact = Set<GKEntity>()

    var stateMachine: GKStateMachine!
    
    var cargo = [Resource]()
    var camera: SKCameraNode?
    
    init(name: String, pos: CGPoint) {
        self.name = name
        
        super.init()

        let comp = SpriteComponent(name: "bot", imageNamed: "bot.png", category: BOT)
        comp.spriteNode.position = pos
        comp.spriteNode.physicsBody?.mass = 10
        addComponent(comp)

        addComponent(GKSKNodeComponent(node: comp.spriteNode))

        let proximityComp = ProximityComponent(name: "bot_proximity", radius: 64)
        addComponent(proximityComp)
        addComponent(GKSKNodeComponent(node: proximityComp.spriteNode))

        let movement = MovementComponent(body: comp.spriteNode)
        addComponent(movement)
        
        stateMachine = GKStateMachine( states: [
                FindingResourceState(bot: self),
                ExtractingFromEntityState(bot: self),
                FindingStorageState(bot: self),
                MovingToStorageState(bot: self)
        ])
        
        stateMachine.enter(FindingResourceState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPosition()-> CGPoint {
        let comp = component(ofType: SpriteComponent.self)
        return (comp?.spriteNode.position)!
    }

    func getVelocity() -> CGVector {
        let comp = component(ofType: SpriteComponent.self)
        let currentVelocity = (comp?.spriteNode.physicsBody?.velocity)!
        return currentVelocity
    }
    
    func findClosest(resource: String) -> GKEntity? {
        let myPos = self.getPosition()
        var closestDistance = CGFloat.infinity
        var target: GKEntity?
        for candidate in (world?.entities)! {
            if let resourceComp = candidate.component(ofType: ResourceComponent.self) {
                if resourceComp.getCount(resource) > 0 {
                    if let spriteComp = candidate.component(ofType: SpriteComponent.self) {
                        let candidatePosition = spriteComp.spriteNode.position
                        let distance = CGPointDistance(from: myPos, to: candidatePosition)
                        if distance < closestDistance {
                            closestDistance = distance
                            target = candidate
                        }
                    }
                }
            }
        }
        
        return target
    }

    func findClosest(type: AnyClass) -> GKEntity? {
        let myPos = self.getPosition()
        var closestDistance = CGFloat.infinity
        var target: GKEntity?
        for candidate in (world?.entities)! {
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

        let movement = self.component(ofType: MovementComponent.self)
        movement?.setTarget(entity: entity)
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

    override func update(deltaTime seconds: TimeInterval) {
        if let movementComp = component(ofType: MovementComponent.self) {
            movementComp.update(deltaTime: seconds)
        }
        if let proximityComp = component(ofType: ProximityComponent.self) {
            proximityComp.update(deltaTime: seconds)
        }
        self.stateMachine.update(deltaTime: seconds)
    }

    func addContact(other: GKEntity) {
        self.contact.insert(other)
    }

    func removeContact(other: GKEntity) {
        self.contact.remove(other)
    }

    func addProximity(other: GKEntity) {
        if let proximityComp = component(ofType: ProximityComponent.self) {
            proximityComp.proximity.insert(other)
        }
    }

    func removeProximity(other: GKEntity) {
        if let proximityComp = component(ofType: ProximityComponent.self) {
            proximityComp.proximity.remove(other)
        }
    }

    func getCamera() -> SKCameraNode {
        if let cam = self.camera {
            return cam
        }
        self.camera = SKCameraNode()
        if let spriteComp = component(ofType: SpriteComponent.self) {
            spriteComp.spriteNode.addChild(self.camera!)
        }
        return self.camera!
    }
}
