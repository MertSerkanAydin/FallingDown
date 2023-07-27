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
    var highScore = 0
    var highScoreLabel: SKLabelNode!
    var tapToStartLabel: SKLabelNode!
    var gameStarted = false
    
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .systemBlue
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        //        highscore Check
        let storedHighScore = UserDefaults.standard.object(forKey: "highscore")
        
        if storedHighScore == nil {
            highScore = 0
        }
        
        if let newScore = storedHighScore as? Int {
            highScore = newScore
        }
        
        if gameStarted == false {
            createTapToStartLabel()
            createHighScoreLabel()
            createBall()
            createScoreLabel()
            
            ball.isHidden = true
            scoreLabel.isHidden = true
            
            gameStarted = true
            
        }
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
    
    //    creating tapToStartLabel
    func createTapToStartLabel() {
        tapToStartLabel = SKLabelNode(fontNamed: "")
        tapToStartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        tapToStartLabel.text = "Tap to Start"
        addChild(tapToStartLabel)
    }
    
    //    creating highscoreLabel
    func createHighScoreLabel() {
        highScoreLabel = SKLabelNode(fontNamed: "")
        highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.text = "Highscore: \(highScore)"
        addChild(highScoreLabel)
    }
    
    //    game start
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == true {
            highScoreLabel.removeFromParent()
            tapToStartLabel.removeFromParent()
            
            
            ball.isHidden = false
            scoreLabel.isHidden = false
            
            //        ground oluşturma hızı
            gameTimer = Timer.scheduledTimer(timeInterval: 0.20, target: self, selector: #selector(createGround), userInfo: nil, repeats: true)
            
            //        score artma hızı
            scoreTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(scoreUp), userInfo: nil, repeats: true)
            
            gameStarted = false
            
        }
    }
    
    //    ball movement for first touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            if ball.position.x > frame.minX {
                startTouch = location
                nodePosition = ball.position
            }
        }
    }
    
    //    ball movement whitout teleporting
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            if ball.position.x >= frame.minX && ball.position.x <= frame.maxX && ball.position.y <= frame.maxY {
                ball.run(SKAction.move(to: CGPoint(x:  nodePosition.x + location.x - startTouch.x, y: nodePosition.y + location.y - startTouch.y), duration: 0.03))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //        topun frame kenarlarından çıkmasını engelleme
        if ball.position.x <= frame.minX {
            ball.position.x = frame.minX + 5
        } else if ball.position.x >= frame.maxX {
            ball.position.x = frame.maxX - 5
        } else if ball.position.y >= frame.maxY {
            ball.position.y = frame.maxY - 5
        }
        
        //    frame boyutunu geçen groundları silme
        for node in children {
            if node.position.y > 950 {
                node.removeFromParent()
            }
        }
    }
    
    //    çarpşışma
    func didBegin(_ contact: SKPhysicsContact) {
        self.view?.isPaused = true
        gameOver = true
        if self.score > self.highScore {
            highScore = score
            UserDefaults.standard.set(self.highScore, forKey: "highscore")
        }
        showError()
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
        let ac = UIAlertController(title: "Game  Over", message: "Your Score is: \(score) \n Your Highscore is: \(highScore)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        ac.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { UIAlertAction in
            self.playAgain()
        }))
        self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
    }
}
