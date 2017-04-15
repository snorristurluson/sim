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
    var entitiesQuadTree: GKQuadtree<GKEntity>?
    var navigationGraph: GKMeshGraph<GKGraphNode2D>?
    var activeCommandComponent: CommandComponent?
    var entitiesNearCursorRenderer: SKShapeNode?
    var buildCursor: SKShapeNode?

    
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
        let min = vector_float2(Float(self.frame.minX - 32), Float(self.frame.minY + 32))
        let max = vector_float2(Float(self.frame.maxX - 32), Float(self.frame.maxY + 32))
        self.entitiesQuadTree = GKQuadtree<GKEntity>(
                boundingQuad: GKQuad(quadMin: min, quadMax: max),
                minimumCellSize: 64
        )
        self.navigationGraph = GKMeshGraph<GKGraphNode2D>(
                bufferRadius: 16,
                minCoordinate: min,
                maxCoordinate: max
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
        let trackingArea = NSTrackingArea(rect:view.frame,options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
    }

    func addEntity(entity: GKEntity) {
        if let spriteComp = entity.component(ofType: SpriteComponent.self) {
            spriteComp.addToScene(scene: self)
            spriteComp.addToQuadTree(tree: self.entitiesQuadTree!)
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
            spriteComp.removeFromQuadTree(tree: self.entitiesQuadTree!)
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

    func findEntitiesNear(pos: CGPoint, radius: Float) -> [GKEntity] {
        var min = vector_float2(Float(pos.x), Float(pos.y))
        var max = min
        let extendedRadius = radius + 64
        min.x -= extendedRadius
        min.y -= extendedRadius
        max.x += extendedRadius
        max.y += extendedRadius

        let candidatesNear = self.entitiesQuadTree!.elements(in: GKQuad(quadMin: min, quadMax: max))
        var entitiesNear = [GKEntity]()
        if candidatesNear.count > 0 {
            for candidate in candidatesNear {
                if let spriteComp = candidate.component(ofType: SpriteComponent.self) {
                    let spritePos = spriteComp.spriteNode.position
                    let spriteWidth = spriteComp.spriteNode.frame.width
                    let distance = CGPointDistance(from: pos, to: spritePos) - spriteWidth / 2
                    if(distance <= CGFloat(radius)) {
                        entitiesNear.append(candidate)
                    }
                }
            }
        }

        return entitiesNear
    }

    func showEntitiesNear(pos: CGPoint, radius: Float) {
        if let shapeNode = self.entitiesNearCursorRenderer {
            shapeNode.removeFromParent()
        }

        let entitiesNear = self.findEntitiesNear(pos: pos, radius: radius)
        if entitiesNear.count > 0 {
            var points = [CGPoint]()
            for entity in entitiesNear {
                let spriteComp = entity.component(ofType: SpriteComponent.self)!
                let spritePos = spriteComp.spriteNode.position

                points.append(pos)
                points.append(spritePos)
                points.append(pos)
            }
            self.entitiesNearCursorRenderer = SKShapeNode(points: &points, count: points.count)
            self.addChild(self.entitiesNearCursorRenderer!)
        }
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

    override public func mouseMoved(with: NSEvent) {
        let posInScene = self.convertPoint(fromView: with.locationInWindow)

        if let cursorNode = self.buildCursor {
            cursorNode.position = posInScene
        } else {
            self.buildCursor = SKShapeNode(circleOfRadius: 64)
            self.buildCursor!.position = posInScene
            self.addChild(self.buildCursor!)
        }

        self.showEntitiesNear(pos: posInScene, radius: 64)
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
