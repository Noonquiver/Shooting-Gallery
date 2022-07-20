//
//  GameScene.swift
//  Shooting Gallery
//
//  Created by Camilo Hernández Guerrero on 20/07/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var background: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        background.position = CGPoint(x: 512, y: 384)
        background.scale(to: CGSize(width: 1024, height: 768))
        addChild(background)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
