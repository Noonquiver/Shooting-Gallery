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
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.name = "background"
        background.zPosition = -1
        background.position = CGPoint(x: 512, y: 384)
        background.scale(to: CGSize(width: 1024, height: 768))
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 8, y: 8)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        addChild(scoreLabel)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
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
        let randomSize = Int.random(in: 1...3)
        
        let sprite = SKSpriteNode(imageNamed: target)
        sprite.size = CGSize(width: 30 * randomSize, height: 30 * randomSize)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        
        switch randomRowNumber {
        case 1:
            sprite.position = CGPoint(x: -136, y: 200 * randomRowNumber)
            sprite.physicsBody?.velocity = CGVector(dx: 200, dy: 0)
            
        case 2:
            sprite.position = CGPoint(x: 1200, y: 200 * randomRowNumber)
            sprite.physicsBody?.velocity = CGVector(dx: -200, dy: 0)
            
        case 3:
            sprite.position = CGPoint(x: -136, y: 200 * randomRowNumber)
            sprite.physicsBody?.velocity = CGVector(dx: 200, dy: 0)
        default: break
        }
        
        switch randomSize {
        case 1: sprite.name = "small"
        case 2: sprite.name = "medium"
        case 3: sprite.name = "big"
        default: break
        }
        
        switch target {
        case "target": break
        case "badTarget":
            if var name = sprite.name {
                name += "Bad"
                sprite.name = name
            }
        default: break
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
        let tappedNodes = nodes(at: location)
        
        
        for node in tappedNodes {
            guard let isBadTarget = node.name?.contains("Bad") else { return }
            guard let isSmall = node.name?.contains("small") else { return }
            guard let isMedium = node.name?.contains("medium") else { return }
            
            if node.name != "background" {
                if isBadTarget {
                    if isSmall {
                        score -= 100
                    } else if isMedium {
                        score -= 200
                    } else {
                        score -= 300
                    }
                } else {
                    if isSmall {
                        score += 300
                    } else if isMedium {
                        score += 200
                    } else {
                        score += 100
                    }
                }
                
                node.removeFromParent()
            }
        }
    }
}
