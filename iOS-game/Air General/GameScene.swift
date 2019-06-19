//
//  GameScene.swift
//  Raven One
//
//  Created by me on 24/03/2019.
//  Copyright © 2019 Mazvydas Gudelis. All rights reserved.
//

import SpriteKit
import GameplayKit
var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let soundFx = SKAction.playSoundFileNamed("MLaunch.wav", waitForCompletion: false)
    let sound = SKAction.playSoundFileNamed("boom.WAV", waitForCompletion: false)
    let player = SKSpriteNode(imageNamed: "fighter4")
    let scoreLabel = SKLabelNode(fontNamed: "theBoldFont")
    var levelNumber = 0
    var livesNumber = 3
    let livesLablel = SKLabelNode(fontNamed: "theBoldFont")
    let tapToStartLabel = SKLabelNode(fontNamed: "theBoldFont")
    
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories{
        static let None: UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //3
    }
    
    func random( min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random(in: min...max)
    }
    
    var gameArea: CGRect
    
    override init( size: CGSize){
        
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect (x:margin, y:0, width:playableWidth, height:size.height)
        
        super.init( size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func didMove(to view:SKView){
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
            let background = SKSpriteNode(imageNamed:"background" )
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x:self.size.width/2, y:self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
        
        
        player.setScale(2)
        player.position = CGPoint (x:self.size.width/2, y:0 - player.size.height)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody (rectangleOf: player.size)
        player.physicsBody!.isDynamic = true
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score - 0"
        scoreLabel.fontSize = 100
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLablel.text = "Lives 3"
        livesLablel.fontSize = 100
        livesLablel.fontColor = SKColor.white
        livesLablel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLablel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLablel.frame.height)
        livesLablel.zPosition = 100
        self.addChild(livesLablel)
        
        let moveToScreen = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveToScreen)
        livesLablel.run(moveToScreen)
        
        tapToStartLabel.text = "Tap To Start"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeIn)
        
    }
    
    var lastUdateTime: TimeInterval = 0
    var delta: TimeInterval = 0
    var amountToMove: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUdateTime == 0{
            lastUdateTime = currentTime
        }
        else {
            delta = currentTime - lastUdateTime
            lastUdateTime = currentTime
        }
        let amountToMoveBackground = amountToMove * CGFloat(delta)
        self.enumerateChildNodes(withName: "Background"){
            (background, stop) in
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
    }
    
    
    func startGame(){
        currentGameState = gameState.inGame
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let delete = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOut, delete])
        tapToStartLabel.run(deleteSequence)
        
        let moveShip = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevel = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShip, startLevel])
        player.run(startGameSequence)
    }
    
    func loseLife(){
        livesNumber -= 1
        livesLablel.text = "Lives \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLablel.run(scaleSequence)
        
        if livesNumber == 0{
            runGameOver()
        }
    }
    
    
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score - \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
        
    }
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet"){
            (bullet,stop) in
            
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy"){
            (enemy, stop) in
            
            enemy.removeAllActions()
        }
        
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    func changeScene(){
        let sceneToMoveTo = GameOver(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: transition)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
            
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            // if player hits enemy
            
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            runGameOver()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height{
            // if rocket hits enemy
            addScore()
            
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            
        }
        
        
    }
    
    
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode (imageNamed:"boom")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 6, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([sound, scaleIn,fadeOut,delete])
        
        explosion.run(explosionSequence)
    }
    
    
    
    
    
    
    func startNewLevel(){
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = NSTimeIntervalSince1970
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("No lvl info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration:levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnAlways = SKAction.repeatForever(spawnSequence)
        self.run(spawnAlways, withKey: "spawningEnemies")
        
        
    }
    
    func fireBullet(){
        
        let bullet = SKSpriteNode(imageNamed:"shoot")
        bullet.name = "Bullet"
        bullet.setScale(0.2)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody (rectangleOf: bullet.size)
        bullet.physicsBody!.isDynamic = true
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height,duration:1)
        let deleteBullet = SKAction.removeFromParent()
        let BulletSequence = SKAction.sequence([soundFx, moveBullet,deleteBullet])
        bullet.run(BulletSequence)
        
    }
    
    
    func spawnEnemy(){
        
        let randomBegin = random (min: gameArea.minX, max: gameArea.maxX)
        let randomEnd = random (min: gameArea.minX, max: gameArea.maxX)
        
        let spawnPoint = CGPoint(x: randomBegin, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "fighter1.right")
        enemy.name = "Enemy"
        enemy.setScale(2)
        enemy.position = spawnPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody (rectangleOf: enemy.size)
        enemy.physicsBody!.isDynamic = true
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let enemyMove = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseLife)
        let enemyOrder = SKAction.sequence([enemyMove, deleteEnemy, loseALifeAction])
        if currentGameState == gameState.inGame{
            enemy.run(enemyOrder)
        }
        
        let dx = endPoint.x - spawnPoint.x
        let dy = endPoint.y - spawnPoint.y
        let atrLine = atan2(dy ,dx)
        enemy.zRotation = atrLine
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        else if currentGameState == gameState.inGame{
            fireBullet()
        }
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
            }
            
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
        
    }
    
}
