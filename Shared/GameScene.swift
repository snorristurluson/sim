//
//  GameScene.swift
//  sim
//
//  Created by Snorri Sturluson on 16/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    fileprivate var targetNode : SKSpriteNode?
    fileprivate var currentTarget : SKSpriteNode?
    fileprivate var bots : Set<Bot> = []
    fileprivate var targets = Set<SKSpriteNode>()

    
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
        bot1.addToScene(scene: self)
        self.bots.insert(bot1)
        
        let bot2 = Bot.init(pos: CGPoint.init(x: 100, y: 0 ))
        bot2.addToScene(scene: self)
        self.bots.insert(bot2)
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    func addTarget(at pos: CGPoint) {
        print("Adding target at", pos)
        let targetNode = SKSpriteNode.init(color: .red, size: CGSize.init(width: 32, height: 32))
        targetNode.name = "target"
        targetNode.position = pos
        targetNode.physicsBody = SKPhysicsBody.init(circleOfRadius: 16)
        self.addChild(targetNode)
        self.targets.insert(targetNode)
        for bot in self.bots {
            bot.selectTarget(targets: self.targets)
        }
    }
    
    func removeTarget(target: SKSpriteNode) {
        self.targets.remove(target)
        self.currentTarget = nil
        if self.targets.isEmpty == false {
            for bot in self.bots {
                bot.selectTarget(targets: self.targets)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "target" {
            print("removing A")
            contact.bodyA.node?.removeFromParent()
            self.removeTarget(target: contact.bodyA.node as! SKSpriteNode)
        }
        if contact.bodyB.node?.name == "target" {
            contact.bodyB.node?.removeFromParent()
            self.removeTarget(target: contact.bodyB.node as! SKSpriteNode)
            print("removing B")
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
