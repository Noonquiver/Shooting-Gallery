//
//  GameScene.swift
//  Shooting Gallery
//
//  Created by Camilo Hernández Guerrero on 20/07/22.
//

import SpriteKit

class GameScene: SKScene {
    var possibleTargets = ["target", "badTarget"]
    var spawnTimer: Timer?
    var gameTimer: Timer?
    var scoreLabel: SKLabelNode!
    var gun: SKSpriteNode!
    var bullets = [SKSpriteNode]()
    var reload: SKSpriteNode!
    var secondsLeft = 60 {
        didSet {
            if self.secondsLeft == 0 {
                gameTimer?.invalidate()
                spawnTimer?.invalidate()
                let gameOver = SKSpriteNode(imageNamed: "gameOver")
                gameOver.position = CGPoint(x: 512, y: 384)
                gameOver.scale(to: CGSize(width: gameOver.size.width + 25, height: gameOver.size.height + 25))
                addChild(gameOver)
            }
        }
    }
    
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
        
        createGun()
        reloadGun()
        
        guard let bulletPosition = bullets.first?.position else { return }
        reload = SKSpriteNode(imageNamed: "reload")
        reload.name = "reload"
        reload.position = CGPoint(x: bulletPosition.x + 50, y: bulletPosition.y + 10)
        reload.isHidden = true
        addChild(reload)
        
        spawnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameOver), userInfo: nil, repeats: true)
        
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
            sprite.physicsBody?.velocity = CGVector(dx: 600 / randomSize, dy: 0)
        case 2:
            sprite.position = CGPoint(x: 1200, y: 200 * randomRowNumber)
            sprite.physicsBody?.velocity = CGVector(dx: -600 / randomSize, dy: 0)
        case 3:
            sprite.position = CGPoint(x: -136, y: 200 * randomRowNumber)
            sprite.physicsBody?.velocity = CGVector(dx: 600 / randomSize, dy: 0)
        default:
            break
        }
        
        switch randomSize {
        case 1: sprite.name = "small"
        case 2: sprite.name = "medium"
        case 3: sprite.name = "big"
        default: break
        }
        
        switch target {
        case "target":
            break
        case "badTarget":
            if var name = sprite.name {
                name += "Bad"
                sprite.name = name
            }
        default:
            break
        }
        
        addChild(sprite)
        
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.affectedByGravity = false
    }
    
    func createGun() {
        gun = SKSpriteNode(imageNamed: "gun")
        gun.position = CGPoint(x: 900, y: 100)
        gun.zPosition = 1
        gun.physicsBody = SKPhysicsBody(texture: gun.texture!, size: gun.size)
        gun.physicsBody?.affectedByGravity = false
        gun.physicsBody?.collisionBitMask = 0
        addChild(gun)
    }
    
    func fireBullet(through tappedNodes: [SKNode]) {
        for target in tappedNodes {
            guard let isBadTarget = target.name?.contains("Bad") else { return }
            guard let isSmall = target.name?.contains("small") else { return }
            guard let isMedium = target.name?.contains("medium") else { return }
            
            if target.name != "background" {
                let hole = SKSpriteNode(imageNamed: "bulletHole")
                hole.scale(to: target.frame.size)
                hole.position.x += CGFloat.random(in: 10...50)
                hole.position.y -= CGFloat.random(in: 10...50)
                hole.zPosition = 1
                target.addChild(hole)
                
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    target.removeFromParent()
                }
                
                break
                
            }
        }
    }
    
    func reloadGun() {
        for multiplier in 1...6 {
            let bullet = SKSpriteNode(imageNamed: "bullet")
            bullet.position = CGPoint(x: 470 + (20 * CGFloat(multiplier)), y: scoreLabel.position.y + 25)
            addChild(bullet)
            bullets.append(bullet)
        }
    }
    
    @objc func gameOver() {
        secondsLeft -= 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
    
        if !bullets.isEmpty {
            let usedBullet = bullets.removeLast()
            usedBullet.removeFromParent()
            
            gun.physicsBody?.applyTorque(2)
            gun.physicsBody?.angularVelocity = -15
            
            fireBullet(through: tappedNodes)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) {
                [weak self] in
                self?.gun.removeFromParent()
                self?.createGun()
            }
        } else {
            for node in tappedNodes {
                if node.name == "reload" {
                    reload.isHidden = true
                    reloadGun()
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if bullets.isEmpty {
            reload.isHidden = false
        }
    }
}
