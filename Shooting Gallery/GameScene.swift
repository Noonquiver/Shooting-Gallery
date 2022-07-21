//
//  GameScene.swift
//  Shooting Gallery
//
//  Created by Camilo Hernández Guerrero on 20/07/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var possibleTargets = ["target", "badTarget"]
    var timer: Timer?
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        background.position = CGPoint(x: 512, y: 384)
        background.scale(to: CGSize(width: 1024, height: 768))
        addChild(background)
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
    }

    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 || node.position.x > 1400 {
                node.removeFromParent()
            }
        }
    }
    
    @objc func createTarget() {
        guard let target = possibleTargets.randomElement() else { return }
        let randomRowNumber = Int.random(in: 1...3)
        let randomSize = Int.random(in: 1...5)
        
        let sprite = SKSpriteNode(imageNamed: target)
        sprite.size = CGSize(width: 30 * randomSize, height: 30 * randomSize)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        
        switch randomRowNumber {
        case 2:
            sprite.position = CGPoint(x: 1200, y: 200 * randomRowNumber)
            sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        default:
            sprite.position = CGPoint(x: -136, y: 200 * randomRowNumber)
            sprite.physicsBody?.velocity = CGVector(dx: 500, dy: 0)
        }
        
        addChild(sprite)
        
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.affectedByGravity = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        
    }
}
