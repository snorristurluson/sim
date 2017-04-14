//
// Created by Snorri Sturluson on 14/04/2017.
// Copyright (c) 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit
import AppKit

class CommandComponent : GKComponent {
    var parent: SKNode
    var commands = [(String, String)]()
    var rootNode: SKSpriteNode
    var trackingAreas = [NSTrackingArea]()

    let LINEHEIGHT = CGFloat(40)
    let trackingAreaOptions = [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeInKeyWindow]
        as NSTrackingAreaOptions

    init(parent: SKNode) {
        self.parent = parent
        self.rootNode = SKSpriteNode(color: .gray, size: CGSize(width:0, height: 0))
        self.rootNode.zPosition = 1.0
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(label: String, command: String) {
        commands.append((label, command))
    }

    func show() {
        let scene = self.parent.scene!
        let view = scene.view!

        let top = LINEHEIGHT * CGFloat(self.commands.count)
        self.rootNode.size = CGSize(width: 300, height: top)
        self.rootNode.position = CGPoint(x: 0, y: top / 2)
        self.parent.addChild(self.rootNode)

        var frame = self.rootNode.calculateAccumulatedFrame()
        var origin = view.convert(frame.origin, from: scene)
        frame.size.height = LINEHEIGHT - 4

        let handler = self.entity as! CommandHandler

        var y = top / 2 - 4
        for (label, cmd) in self.commands {
            let cmdNode = CommandNode.init(text: label, command: cmd, handler: handler, owner: self)
            cmdNode.position = CGPoint(x: 0, y: y)
            self.rootNode.addChild(cmdNode)

            frame.origin = origin
            let trackingArea = NSTrackingArea(rect:frame, options: trackingAreaOptions, owner:cmdNode, userInfo:nil)
            self.trackingAreas.append(trackingArea)
            view.addTrackingArea(trackingArea)

            y -= LINEHEIGHT
            origin.y -= LINEHEIGHT
        }

        world!.activeCommandComponent = self
    }

    func hide() {
        self.rootNode.removeFromParent()
        self.rootNode.removeAllChildren()
        let scene = self.parent.scene!
        let view = scene.view!
        for area in self.trackingAreas {
            view.removeTrackingArea(area)
        }
    }

    public func mouseDown(with: NSEvent) {
        print("MouseDown in CommandComponent")
    }
}

class CommandNode : SKLabelNode {
    var highlightColor: NSColor
    var regularColor: NSColor
    var handler: CommandHandler
    var command: String
    unowned var owner: CommandComponent

    init(text: String, command: String, handler: CommandHandler, owner: CommandComponent) {
        self.owner = owner
        self.command = command
        self.handler = handler
        self.regularColor = .green
        self.highlightColor = .red

        super.init()
        self.verticalAlignmentMode = .top
        self.fontName = "American Typewriter"
        self.text = text
        self.fontColor = self.regularColor
        self.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func mouseDown(with: NSEvent) {
        self.handler.handle(command: self.command)
        self.owner.hide()
    }

    override public func mouseEntered(with: NSEvent) {
        self.fontColor = self.highlightColor
    }

    override public func mouseExited(with: NSEvent) {
        self.fontColor = self.regularColor
    }
}

