//
//  GameScene.swift
//  FallingDown
//
//  Created by Mert Serkan Aydın on 25.07.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball: SKSpriteNode!
    var ground: SKSpriteNode!
    var gameTimer: Timer?
    var scoreTimer: Timer?
    var scoreLabel: SKLabelNode!
    var gameOver = false
    var nodePosition = CGPoint()
    var startTouch = CGPoint()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .systemBlue
        createBall()
        createScoreLabel()
        
        //        yerçekimi
        physicsWorld.gravity = .zero
        
        physicsWorld.contactDelegate = self
        
        //        ground oluşturma hızı
        gameTimer = Timer.scheduledTimer(timeInterval: 5.20, target: self, selector: #selector(createGround), userInfo: nil, repeats: true)
        
        //        score artma hızı
        scoreTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(scoreUp), userInfo: nil, repeats: true)
        
        //        let edgeFrame = CGRect(origin: CGPoint(x: ((self.view?.frame.minX)! - 9) ,y: (self.view?.frame.minY)!), size: CGSize(width: (self.view?.frame.width)! + 12, height: (self.view?.frame.height)!))
        
    }
    
    @objc func scoreUp() {
        score += 1
    }
    
    //    ground oluşturma
    @objc func createGround() {
        score += 1
        ground = SKSpriteNode(imageNamed: "ground")
        ground.physicsBody = SKPhysicsBody(texture: ground.texture!, alphaThreshold: 1.5, size: ground.size)
        ground.physicsBody?.categoryBitMask = 1
        ground.position = CGPoint(x: Int.random(in: 50...400), y: 0)
        ground.physicsBody?.restitution = 0.0
        ground.physicsBody?.velocity = CGVector(dx: 0, dy: 250)   //hızını ayarladık
        //        ground.physicsBody?.angularVelocity = 5 //spin ekledik
        ground.physicsBody?.linearDamping = 0  //hızı asla yavaşlamayacak dedik
        addChild(ground)
        
        //        ground.physicsBody?.angularDamping = 0 //spini asla yavaşlamıcak dedik
    }
    
    //    topu oluşturma
    func createBall() {
        ball = SKSpriteNode(imageNamed: "ball")
        ball.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 1.3)
        ball.physicsBody = SKPhysicsBody(texture: ball.texture!, alphaThreshold: 1.5, size: ball.size)
        ball.physicsBody?.contactTestBitMask = 1
        ball.physicsBody?.restitution = 0.0
        addChild(ball)
    }
    
    //    scorelabel oluşturma
    func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            if ball.position.x > frame.minX {
                startTouch = location
                nodePosition = ball.position
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            if ball.position.x >= frame.minX && ball.position.x <= frame.maxX && ball.position.y <= frame.maxY {
                ball.run(SKAction.move(to: CGPoint(x:  nodePosition.x + location.x - startTouch.x, y: nodePosition.y + location.y - startTouch.y), duration: 0.03))
            } else {
                //                ball.position.x = frame.minX
                //                ball.position.x = frame.maxX
                //                ball.position.y = frame.maxY
            }
            
        }
        
        //        if ball.position.x <= self.frame.minX {
        //            ball.position.x <=
        //        }
    }
    
    //    frame boyutunu geçen groundları silme
    override func update(_ currentTime: TimeInterval) {
        
        if ball.position.x <= frame.minX {
            ball.position.x = frame.minX + 5
        } else if ball.position.x >= frame.maxX {
            ball.position.x = frame.maxX
        } else if ball.position.y >= frame.maxY {
            ball.position.y = frame.maxY
        }
        
        for node in children {
            if node.position.y > 950 {
                node.removeFromParent()
            }
        }
    }
    
    //    çarpşışma
    func didBegin(_ contact: SKPhysicsContact) {
        self.view?.isPaused = true
        showError()
        gameOver = true
        //        gameTimer?.invalidate()
    }
    
    //    tekrar oyna butonu
    func playAgain() {
        guard gameOver == true else {return}
        score = 0
        self.view?.isPaused = false
        removeAllChildren()
        createBall()
        createScoreLabel()
    }
    
    //    yandığında çıkan error methodu
    func showError() {
        let ac = UIAlertController(title: "Game  Over", message: "Your Score is: \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        ac.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { UIAlertAction in
            self.playAgain()
        }))
        self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
    }
}
