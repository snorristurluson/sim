//
//  SpriteSceneView.swift
//  sim
//
//  Created by Snorri Sturluson on 21/04/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
import SpriteKit

class SpriteSceneView : SKView {
    override public func scrollWheel(with: NSEvent) {
        if let scene = self.scene as? GameScene {
            scene.scrollWheel(with: with)
        }
    }
}
