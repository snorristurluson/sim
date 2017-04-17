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
var commandCenter = CommandCenter()

let BOT = UInt32(0x1)
let RESOURCE = UInt32(0x2)
let BUILDING = UInt32(0x4)
let PROXIMITY = UInt32(0x8)

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

    func findRandomClearSpot(radius: Float) -> CGPoint {
        while true {
            let x = Double(random.nextUniform() * Float(self.frame.width - 64) + Float(self.frame.minX + 32))
            let y = Double(random.nextUniform() * Float(self.frame.height - 64) + Float(self.frame.minY + 32))
            let pos = CGPoint(x: x, y: y)
            let entitiesInTheWay = self.findEntitiesNear(pos: pos, radius: radius)
            if entitiesInTheWay.count == 0 {
                return pos
            }
        }
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

        for _ in 1...1 {
            let pos = self.findRandomClearSpot(radius: 32)
            let storage = Storage.init(pos: pos)
            self.addEntity(entity: storage)
        }

        for _ in 1...20 {
            let pos = self.findRandomClearSpot(radius: 24)
            let rock = Rock(pos: pos)
            self.addEntity(entity: rock)
        }

        for _ in 1...50 {
            let pos = self.findRandomClearSpot(radius: 24)
            let tree = Tree(pos: pos)
            self.addEntity(entity: tree)
        }

        self.navigationGraph?.triangulate()

        for ix in 1...3 {
            let pos = self.findRandomClearSpot(radius: 24)
            let name = "bot" + String(ix)
            let bot = Bot.init(name: name, pos: pos)
            self.addEntity(entity: bot)
            self.bots.insert(bot)
        }
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
        if let proximityComp = entity.component(ofType: ProximityComponent.self) {
            proximityComp.addToScene(scene: self)
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
        if let proximityComp = entity.component(ofType: ProximityComponent.self) {
            proximityComp.removeFromScene(scene: self)
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
            let renderer = SKShapeNode(points: &points, count: points.count)
            renderer.zPosition = -1.0
            self.addChild(renderer)
            self.entitiesNearCursorRenderer = renderer
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dt = 0.01666
        // Called before each frame is rendered
        for bot in self.bots {
            bot.update(deltaTime: dt)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var bot: Bot?
        var bot_proximity: Bot?
        var other: GKEntity?
        if contact.bodyA.node?.name == "bot" {
            bot = contact.bodyA.node?.entity as? Bot
            other = contact.bodyB.node?.entity
        }
        else if contact.bodyB.node?.name == "bot" {
            bot = contact.bodyB.node?.entity as? Bot
            other = contact.bodyA.node?.entity
        }
        if bot != nil && other != nil {
            bot?.addContact(other: other!)
        }
        if contact.bodyA.node?.name == "bot_proximity" {
            bot_proximity = contact.bodyA.node?.entity as? Bot
            other = contact.bodyB.node?.entity
        }
        else if contact.bodyB.node?.name == "bot_proximity" {
            bot_proximity = contact.bodyB.node?.entity as? Bot
            other = contact.bodyA.node?.entity
        }
        if bot_proximity != nil && other != nil {
            bot_proximity?.addProximity(other: other!)
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        var bot: Bot?
        var bot_proximity: Bot?
        var other: GKEntity?
        if contact.bodyA.node?.name == "bot" {
            bot = contact.bodyA.node?.entity as? Bot
            other = contact.bodyB.node?.entity
        }
        else if contact.bodyB.node?.name == "bot" {
            bot = contact.bodyB.node?.entity as? Bot
            other = contact.bodyA.node?.entity
        }
        if bot != nil && other != nil {
            bot?.removeContact(other: other!)
        }
        if contact.bodyA.node?.name == "bot_proximity" {
            bot_proximity = contact.bodyA.node?.entity as? Bot
            other = contact.bodyB.node?.entity
        }
        else if contact.bodyB.node?.name == "bot_proximity" {
            bot_proximity = contact.bodyB.node?.entity as? Bot
            other = contact.bodyA.node?.entity
        }
        if bot_proximity != nil && other != nil {
            bot_proximity?.removeProximity(other: other!)
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
            let cursor = SKShapeNode(circleOfRadius: 64)
            cursor.zPosition = -1.0
            cursor.position = posInScene
            self.addChild(cursor)
            self.buildCursor = cursor
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
