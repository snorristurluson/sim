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
    var piecesLeft = 0
    
    init(pos: CGPoint) {
        super.init()
        let comp = SpriteComponent(name: "rock", color: .red, size: CGSize.init(width: 32, height: 32))
        comp.spriteNode.position = pos
        comp.spriteNode.physicsBody?.isDynamic = false
        addComponent(comp)
        addComponent(GKSKNodeComponent(node: comp.spriteNode))
        addComponent(ObstacleComponent(sprite: comp.spriteNode))
        
        self.piecesLeft = random.nextInt(upperBound: 5) + 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPosition()-> CGPoint {
        let comp = component(ofType: SpriteComponent.self)
        return (comp?.spriteNode.position)!
    }
    
    func takePiece() -> Bool {
        if self.piecesLeft > 0 {
            self.piecesLeft -= 1
            return true
        }
        return false
    }
}
