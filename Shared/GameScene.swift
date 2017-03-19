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
    fileprivate var botNode : SKSpriteNode?
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
        
        self.botNode = SKSpriteNode.init(color: .green, size: CGSize.init(width: 16, height: 16))
        self.botNode?.name = "bot"
        self.botNode?.physicsBody = SKPhysicsBody.init(circleOfRadius: 8)
        self.botNode?.physicsBody?.contactTestBitMask = (self.botNode?.physicsBody?.collisionBitMask)!
        self.addChild(self.botNode!)
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    func addTarget(at pos: CGPoint) {
        print("Adding target")
        let targetNode = SKSpriteNode.init(color: .red, size: CGSize.init(width: 32, height: 32))
        targetNode.name = "target"
        targetNode.position = pos
        targetNode.physicsBody = SKPhysicsBody.init(circleOfRadius: 16)
        self.addChild(targetNode)
        self.targets.insert(targetNode)
        self.selectTarget()
    }
    
    func selectTarget() {
        let myPos = self.botNode?.position
        var closestDistance = CGFloat.infinity
        var target = self.targets.first
        for candidate in self.targets {
            let distance = CGPointDistance(from: myPos!, to: candidate.position)
            if distance < closestDistance {
                target = candidate
                closestDistance = distance
            }
        }
        let pos = target?.position
        
        let v = CGVector.init(dx: (pos?.x)! - (self.botNode?.position.x)!, dy: (pos?.y)! - (self.botNode?.position.y)!)
        let vn = CGVectorNormalize(v: v)
        let speed = CGFloat.init(200.0)
        self.botNode?.physicsBody?.velocity = CGVector.init(dx: vn.dx * speed, dy: vn.dy * speed)
        
        self.currentTarget = target
    }
    
    func removeTarget(target: SKSpriteNode) {
        self.targets.remove(target)
        self.currentTarget = nil
        if self.targets.isEmpty == false {
            self.selectTarget()
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
