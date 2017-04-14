//
//  GameScene.swift
//  sim
//
//  Created by Snorri Sturluson on 16/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import SpriteKit
import GameplayKit

var world: GameScene? = nil
var random = GKARC4RandomSource.init()

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    fileprivate var bots : Set<Bot> = []
    var entities = Set<GKEntity>()
    var navigationGraph: GKMeshGraph<GKGraphNode2D>?
    var activeCommandComponent: CommandComponent?

    
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
        self.navigationGraph = GKMeshGraph<GKGraphNode2D>(
                bufferRadius: 16,
                minCoordinate: vector_float2(Float(self.frame.minX - 32), Float(self.frame.minY + 32)),
                maxCoordinate: vector_float2(Float(self.frame.maxX - 32), Float(self.frame.maxY + 32))
        )
        self.navigationGraph?.triangulationMode = [.vertices, .centers, .edgeMidpoints]
        for _ in 1...20 {
            let x = Double(random.nextUniform() * Float(self.frame.width - 64) + Float(self.frame.minX + 32))
            let y = Double(random.nextUniform() * Float(self.frame.height - 64) + Float(self.frame.minY + 32))
            let rock = Rock(pos: CGPoint.init(x: x, y: y))
            self.addEntity(entity: rock)
        }
        
        let storage = Storage.init(pos: CGPoint(x: 0, y: -100))
        self.addEntity(entity: storage)
        
        self.navigationGraph?.triangulate()

        let bot1 = Bot.init(name: "bot1", pos: CGPoint.init(x: -100, y: 0 ))
        self.addEntity(entity: bot1)
        self.bots.insert(bot1)
        
        let bot2 = Bot.init(name: "bot2", pos: CGPoint.init(x: 100, y: 0 ))
        self.addEntity(entity: bot2)
        self.bots.insert(bot2)
        
    }
    
    override func didMove(to view: SKView) {
        world = self
        self.setUpScene()

        let options = [NSTrackingAreaOptions.mouseMoved, NSTrackingAreaOptions.activeInKeyWindow] as NSTrackingAreaOptions
        print(view.frame)
        let trackingArea = NSTrackingArea(rect:view.frame,options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
    }

    func addEntity(entity: GKEntity) {
        if let spriteComp = entity.component(ofType: SpriteComponent.self) {
            spriteComp.addToScene(scene: self)
        }
        if let obstacleComp = entity.component(ofType: ObstacleComponent.self) {
            let obstacle = obstacleComp.obstacle
            if obstacle != nil {
                self.navigationGraph?.addObstacles([obstacle!])
            }
        }
        self.entities.insert(entity)
    }
    
    func removeEntity(entity: GKEntity) {
        if let spriteComp = entity.component(ofType: SpriteComponent.self) {
            spriteComp.removeFromScene(scene: self)
        }
        if let obstacleComp = entity.component(ofType: ObstacleComponent.self) {
            let obstacle = obstacleComp.obstacle
            if obstacle != nil {
                self.navigationGraph?.removeObstacles([obstacle!])
                self.navigationGraph?.triangulate()
            }
        }
        self.entities.remove(entity)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dt = 0.01666
        // Called before each frame is rendered
        for bot in self.bots {
            let comp = bot.component(ofType: MovementComponent.self)
            if (comp != nil) {
                comp?.update(deltaTime: dt)
            }
            bot.stateMachine.update(deltaTime: dt)
        }
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
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override public func mouseDown(with: NSEvent) {
        print("MouseDown in scene")
        if let cmdComp = self.activeCommandComponent {
            cmdComp.hide()
            self.activeCommandComponent = nil
        }
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
