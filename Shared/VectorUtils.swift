//
// Created by Snorri Sturluson on 22/04/2017.
// Copyright (c) 2017 Snorri Sturluson. All rights reserved.
//

import Foundation

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
