//
//  GameScene.swift
//  sim
//
//  Created by Snorri Sturluson on 16/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import SpriteKit
import GameKit

var world: GameScene? = nil

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    fileprivate var bots : Set<Bot> = []
    var targets = Set<GKEntity>()

    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        scene.physicsWorld.gravity = CGVector.zero
        scene.physicsWorld.contactDelegate = scene
        
        return scene
    }
    
    func setUpScene() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)

        let bot1 = Bot.init(pos: CGPoint.init(x: -100, y: 0 ))
        self.addEntity(entity: bot1)
        self.bots.insert(bot1)
        
        let bot2 = Bot.init(pos: CGPoint.init(x: 100, y: 0 ))
        self.addEntity(entity: bot2)
        self.bots.insert(bot2)
    }
    
    override func didMove(to view: SKView) {
        world = self
        self.setUpScene()
    }

    func addEntity(entity: GKEntity) {
        if let spriteComp = entity.component(ofType: SpriteComponent.self) {
            self.addChild(spriteComp.spriteNode)
        }
    }
    
    func addTarget(at: CGPoint) {
        print("Adding target at", at)
        let rock = Rock(pos: at)
        self.addEntity(entity: rock)
        self.targets.insert(rock)
        for bot in self.bots {
            bot.selectTarget()
        }
    }
    
    func removeTarget(target: GKEntity) {
        if let spriteComp = target.component(ofType: SpriteComponent.self) {
            spriteComp.spriteNode.removeFromParent()
        }
        self.targets.remove(target)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var bot: Bot? = nil
        var other: GKEntity? = nil
        if contact.bodyA.node?.name == "bot" {
            bot = contact.bodyA.node?.entity as? Bot
            other = contact.bodyB.node?.entity
        }
        else if contact.bodyB.node?.name == "bot" {
            bot = contact.bodyB.node?.entity as? Bot
            other = contact.bodyA.node?.entity
        }
        if bot != nil {
            bot?.HandleContact(other: other)
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.addTarget(at: t.location(in: self))
        }
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        self.addTarget(at: event.location(in: self))
    }
}
#endif

func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt(CGPointDistanceSquared(from: from, to: to))
}

func CGVectorLength(v: CGVector) -> CGFloat {
    return sqrt(v.dx*v.dx + v.dy*v.dy)
}

func CGVectorNormalize(v: CGVector) -> CGVector {
    let len = CGVectorLength(v: v)
    return CGVector.init(dx: v.dx / len, dy: v.dy / len)
}
