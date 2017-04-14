//
//  Rock.swift
//  sim
//
//  Created by Snorri Sturluson on 22/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameplayKit

class Rock : GKEntity {
    init(pos: CGPoint) {
        super.init()
        let comp = SpriteComponent(name: "rock", color: .red, size: CGSize.init(width: 32, height: 32))
        comp.spriteNode.position = pos
        comp.spriteNode.physicsBody?.isDynamic = false
        addComponent(comp)
        addComponent(GKSKNodeComponent(node: comp.spriteNode))
        addComponent(ObstacleComponent(sprite: comp.spriteNode))
        let labelComp = LabelComponent(parent: comp.spriteNode)
        addComponent(labelComp)

        let resourceComp = ResourceComponent()
        addComponent(resourceComp)
        resourceComp.resources["iron"] = random.nextInt(upperBound: 5)
        resourceComp.resources["copper"] = random.nextInt(upperBound: 5)
        resourceComp.resources["zinc"] = random.nextInt(upperBound: 5)
        self.updateLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPosition()-> CGPoint {
        let comp = component(ofType: SpriteComponent.self)
        return (comp?.spriteNode.position)!
    }

    func hasResource(type: String) -> Bool {
        if let resourceComp = component(ofType: ResourceComponent.self) {
            return resourceComp.getCount(type) > 0
        }

        return false
    }
    
    func takeResource(type: String) -> Bool {
        if let resourceComp = component(ofType: ResourceComponent.self) {
            let returnValue = resourceComp.takeResource(type: type)
            self.updateLabel()
            return returnValue
        }

        return false
    }

    func updateLabel() {
        if let labelComp = component(ofType: LabelComponent.self), let resourceComp = component(ofType: ResourceComponent.self) {
            var text = "Rock:\n"
            if resourceComp.resources.isEmpty {
                text += "Empty"
            }
            else {
                for (type, quantity) in resourceComp.resources {
                    let line = "\(type): \(quantity)\n"
                    text += line
                }
            }
            labelComp.setText(text)
        }
    }

}
