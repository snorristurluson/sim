//
//  Rock.swift
//  sim
//
//  Created by Snorri Sturluson on 22/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameKit

class Rock : GKEntity {
    var isTargeted = false
    
    init(pos: CGPoint) {
        super.init()
        let comp = SpriteComponent(name: "rock", color: .red, size: CGSize.init(width: 32, height: 32))
        comp.spriteNode.position = pos
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
    
}
