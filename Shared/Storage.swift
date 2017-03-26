//
//  Storage.swift
//  sim
//
//  Created by Snorri Sturluson on 26/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class Storage : GKEntity {
    var contents = [Resource]()
    
    init(pos: CGPoint) {
        super.init()
        let comp = SpriteComponent(name: "storage", color: .yellow, size: CGSize.init(width: 64, height: 64))
        comp.spriteNode.position = pos
        comp.spriteNode.physicsBody?.isDynamic = false
        addComponent(comp)
        addComponent(GKSKNodeComponent(node: comp.spriteNode))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getPosition()-> CGPoint {
        let comp = component(ofType: SpriteComponent.self)
        return (comp?.spriteNode.position)!
    }
    
    func addResource(_ resource: Resource) -> Int {
        // Return quantity left, ie whatever could not be taken in
        // Return value of 0 means everything was taken in
        // todo: handle quantities
        print("Added", resource.quantity, resource.type, "to storage")
        self.contents.append(resource)
        return 0
    }
}
