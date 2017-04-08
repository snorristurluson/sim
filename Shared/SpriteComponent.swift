//
//  SpriteComponent.swift
//  sim
//
//  Created by Snorri Sturluson on 19/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit
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
    }

    override public func mouseEntered(with: NSEvent) {
        print("Mouse entered", self.name!)
        self.color = self.highlightColor
    }

    override public func mouseExited(with: NSEvent) {
        print("Mouse exited", self.name!)
        self.color = self.regularColor
    }
}

class SpriteComponent : GKComponent {
    let spriteNode : SKSpriteNode
    var trackingArea : NSTrackingArea?
    
    init(name: String, color: SKColor, size: CGSize) {
        self.spriteNode = InteractiveSpriteNode.init(color: color, size: size)
        self.spriteNode.name = name
        let radius = size.width / 2
        let physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
        self.spriteNode.physicsBody = physicsBody
        physicsBody.contactTestBitMask = physicsBody.collisionBitMask
        physicsBody.allowsRotation = false

        super.init()
    }

    init(name: String, imageNamed: String) {
        self.spriteNode = SKSpriteNode.init(imageNamed: imageNamed)
        self.spriteNode.name = name

        let radius = self.spriteNode.size.width / 2
        let physicsBody = SKPhysicsBody.init(circleOfRadius: radius)
        self.spriteNode.physicsBody = physicsBody
        physicsBody.contactTestBitMask = physicsBody.collisionBitMask

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
            let trackingArea = NSTrackingArea(rect:frame, options:options, owner:self.spriteNode, userInfo:nil)
            view.addTrackingArea(trackingArea)
        }
    }

    func removeFromScene(scene: SKScene) {
        self.spriteNode.removeFromParent()
        let view = scene.view
        let trackingArea = self.trackingArea
        if view != nil && trackingArea != nil {
            view!.addTrackingArea(trackingArea!)
        }
    }
}
