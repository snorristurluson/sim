//
//  SpriteComponent.swift
//  sim
//
//  Created by Snorri Sturluson on 19/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class InteractiveSpriteNode : SKSpriteNode {
    var highlightColor: NSColor
    var regularColor: NSColor

    init(color: NSColor, size: CGSize) {
        self.regularColor = color
        self.highlightColor = .white

        super.init(texture: nil, color: color, size: size)
        self.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func mouseDown(with: NSEvent) {
        print("MouseDown", self.name!, with.locationInWindow, self.calculateAccumulatedFrame())
        if let cmdComp = self.entity!.component(ofType: CommandComponent.self) {
            cmdComp.show()
        }
    }

    override public func mouseEntered(with: NSEvent) {
        print("Mouse entered", self.name!)
        self.color = self.highlightColor
        if let labelComp = self.entity!.component(ofType: LabelComponent.self) {
            labelComp.show()
        }
    }

    override public func mouseExited(with: NSEvent) {
        print("Mouse exited", self.name!)
        self.color = self.regularColor
        if let labelComp = self.entity!.component(ofType: LabelComponent.self) {
            labelComp.hide()
        }
    }
}

class SpriteComponent : GKComponent {
    let spriteNode : SKSpriteNode
    var trackingArea : NSTrackingArea?
    
    init(name: String, color: SKColor, size: CGSize, category: UInt32) {
        self.spriteNode = InteractiveSpriteNode.init(color: color, size: size)
        self.spriteNode.name = name
        let radius = size.width / 2
        let physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
        self.spriteNode.physicsBody = physicsBody
        physicsBody.categoryBitMask = category
        physicsBody.contactTestBitMask = 0xffffffff
        physicsBody.collisionBitMask = BOT|RESOURCE|BUILDING
        physicsBody.allowsRotation = false

        super.init()
    }

    init(name: String, imageNamed: String, category: UInt32) {
        self.spriteNode = SKSpriteNode.init(imageNamed: imageNamed)
        self.spriteNode.name = name

        let radius = self.spriteNode.size.width / 2
        let physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
        physicsBody.categoryBitMask = category
        physicsBody.contactTestBitMask = 0xffffffff
        physicsBody.collisionBitMask = BOT|RESOURCE|BUILDING
        self.spriteNode.physicsBody = physicsBody

        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addToScene(scene: SKScene) {
        scene.addChild(self.spriteNode)
        if let view = scene.view {
            let options = [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeInKeyWindow] as NSTrackingAreaOptions
            var frame = self.spriteNode.calculateAccumulatedFrame()
            frame.origin = view.convert(frame.origin, from: scene)
            self.trackingArea = NSTrackingArea(rect:frame, options:options, owner:self.spriteNode, userInfo:nil)
            view.addTrackingArea(self.trackingArea!)
        }
    }

    func removeFromScene(scene: SKScene) {
        self.spriteNode.removeFromParent()

        if let view = scene.view, let trackingArea = self.trackingArea {
            print("Removing tracking area")
            view.removeTrackingArea(trackingArea)
        }
    }

    func addToQuadTree(tree: GKQuadtree<GKEntity>) {
        let frame = self.spriteNode.calculateAccumulatedFrame()
        let min = vector_float2(Float(frame.origin.x), Float(frame.origin.y))
        var max = min
        max.x += Float(frame.width)
        max.y += Float(frame.height)
        tree.add(self.entity!, in: GKQuad(quadMin: min, quadMax: max))
    }

    func removeFromQuadTree(tree: GKQuadtree<GKEntity>) {
        tree.remove(self.entity!)
    }
}
