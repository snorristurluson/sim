//
// Created by Snorri Sturluson on 26/03/2017.
// Copyright (c) 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import GameplayKit

class ObstacleComponent : GKComponent {
    var obstacle: GKPolygonObstacle?
    
    init(sprite: SKSpriteNode) {
        super.init()
        
        let frame = sprite.frame
        let p0 = vector_float2(Float(frame.minX), Float(frame.minY))
        let p1 = vector_float2(Float(frame.maxX), Float(frame.minY))
        let p2 = vector_float2(Float(frame.maxX), Float(frame.maxY))
        let p3 = vector_float2(Float(frame.minX), Float(frame.maxY))
        self.obstacle = GKPolygonObstacle(points: [p0, p1, p2, p3])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
