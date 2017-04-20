//
//  MovementComponent.swift
//  sim
//
//  Created by Snorri Sturluson on 23/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameplayKit

class MovementComponent : GKComponent {
    var sprite: SKSpriteNode
    var target = CGPoint.zero
    var speed = CGFloat.init(50.0)
    var power = CGFloat.init(10)
    var path = [GKGraphNode]()
    var currentWaypoint = 0
    var pathRenderer: SKShapeNode?
    var diameter = CGFloat(0)
    
    init(body: SKSpriteNode) {
        self.sprite = body
        self.diameter = self.sprite.size.width
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTarget(entity: GKEntity) {
        let spriteComp = entity.component(ofType: SpriteComponent.self)
        let pos = (spriteComp?.spriteNode.position)!
        
        self.target = pos

        let currentPosition = self.sprite.position
        let startNode = GKGraphNode2D(point: vector_float2(Float(currentPosition.x), Float(currentPosition.y)))
        let endNode = GKGraphNode2D(point: vector_float2(Float(pos.x), Float(pos.y)))

        let navGraph = (world?.navigationGraph)!
        
        navGraph.connectToLowestCostNode(node: startNode, bidirectional: true)
        navGraph.connectToLowestCostNode(node: endNode, bidirectional: true)
        self.path = (navGraph.findPath(from: startNode, to: endNode))
        self.currentWaypoint = 0
        
        navGraph.remove([startNode, endNode])
        
        var points = [CGPoint]()
        for node in self.path {
            let node2D = node as! GKGraphNode2D
            let p = node2D.position
            points.append(CGPoint(x: CGFloat(p.x), y: CGFloat(p.y)))
        }
        if let prevRenderer = self.pathRenderer {
            prevRenderer.removeFromParent()
        }
        self.pathRenderer = SKShapeNode(points: &points, count: points.count)
        self.pathRenderer?.zPosition = -1.0
        world?.addChild(self.pathRenderer!)
    }

    func getBotsToAvoid() -> [Bot] {
        var result = [Bot]()
        var bots = [Bot]()
        if let proximityComp = self.entity!.component(ofType: ProximityComponent.self) {
            for candidate in proximityComp.proximity {
                if let bot = candidate as? Bot {
                    bots.append(bot)
                }
            }
        }
        let myVelocity = (self.sprite.physicsBody?.velocity)!
        for each in bots {
            let otherVelocity = each.getVelocity()
            let dot = myVelocity.dx * otherVelocity.dx + myVelocity.dy * otherVelocity.dy
            if dot < 0.0 {
                result.append(each)
            }
        }
        return result
    }

    func getAvoidanceVectorForBot(bot: Bot) -> CGVector {
        let myDir = CGVectorNormalize(v: (self.sprite.physicsBody?.velocity)!)

        let myPosition = self.sprite.position
        let otherPosition = bot.getPosition()
        let v = CGVector(dx: CGFloat(otherPosition.x) - myPosition.x, dy: CGFloat(otherPosition.y) - myPosition.y)
        let vn = CGVectorNormalize(v: v)

        let a = atan2(vn.dy, vn.dx) - atan2(myDir.dy, myDir.dx)
        if a > -0.05 {
            return CGVector(dx: vn.dy, dy: -vn.dx)
        }
        else {
            return CGVector(dx: -vn.dy, dy: vn.dx)
        }
    }

    override func update(deltaTime seconds: TimeInterval) {
        let currentVelocity = (self.sprite.physicsBody?.velocity)!
        let currentHeading = atan2(currentVelocity.dy, currentVelocity.dx)

        let currentPosition = self.sprite.position
        var waypoint = self.path[self.currentWaypoint] as! GKGraphNode2D
        var targetPosition = waypoint.position
        var v = CGVector.init(dx: CGFloat(targetPosition.x) - currentPosition.x, dy: CGFloat(targetPosition.y) - currentPosition.y)
        let distance = CGVectorLength(v: v)
        if distance < self.diameter {
            if self.currentWaypoint + 1 < self.path.count {
                self.currentWaypoint += 1
                waypoint = self.path[self.currentWaypoint] as! GKGraphNode2D
                targetPosition = waypoint.position
                v = CGVector.init(dx: CGFloat(targetPosition.x) - currentPosition.x, dy: CGFloat(targetPosition.y) - currentPosition.y)
            }
        }
        var vn = CGVectorNormalize(v: v)
        let otherBots = self.getBotsToAvoid()
        for each in otherBots {
            let avoid = self.getAvoidanceVectorForBot(bot: each)
            vn.dx += avoid.dx
            vn.dy += avoid.dy
        }

        // Renormalize, effectively averaging avoidance vectors with desired heading
        vn = CGVectorNormalize(v: vn)

        let desiredVelocity = CGVector(dx: vn.dx * self.speed, dy: vn.dy * self.speed)

        self.sprite.zRotation = currentHeading

        let d = CGVector.init(dx: desiredVelocity.dx - currentVelocity.dx, dy: desiredVelocity.dy - currentVelocity.dy)
        let dt = CGFloat.init(seconds)
        let dScaled = CGVector.init(dx: d.dx * self.power * dt, dy: d.dy * self.power * dt)
        self.sprite.physicsBody?.applyImpulse(dScaled)
    }
}
