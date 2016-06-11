//
//  GameScene.swift
//  FlappyHaru
//
//  Created by devil wang on 6/4/16.
//  Copyright (c) 2016 devil wang. All rights reserved.
//

import SpriteKit

enum ImageLayer: CGFloat {
    case backGround
    case roadBlcok
    case frontGround
    case gameRole
    case UI
}

struct physicsLayer {
    static let zero: UInt32 = 0             //0
    static let gameRole: UInt32 = 0b1       //1
    static let gameBlock: UInt32 = 0b10     //2
    static let gameGround: UInt32 = 0b100   //4
}

enum gameStatus {
    case mainMenu
    case teach
    case play
    case falldown
    case showScore
    case end
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let learningUrl = "http://hollylee.red"
    let appStoreUrl = "http://google.com"
    
    let groundCount = 2
    let groundMoveSpeed = -150.0
    
    //重力速度 和 上飞速度
    let gravity: CGFloat = -800//-700//-1500
    let flySpeed: CGFloat = 250//200//400.0
    
    let kBottomMin: CGFloat = 0.1
    let kBottomMax: CGFloat = 0.6
    
    let kConstance: CGFloat = 3.5
    
    let kFirstAddBlocktime: NSTimeInterval = 1.75
    let kEachAddBlocktime: NSTimeInterval = 1.5
    
    let ktopBlank: CGFloat = 20.0
    let knumFont = "AmericanTypewriter-Bold"
    var scoreLabel: SKLabelNode!
    var currentScore = 0
    
    let kAnimedelay = 0.3
    
    var roleSpeed = CGPoint.zero
    
    let worldNode = SKNode()
    
    var gameStartPoint: CGFloat = 0
    var gameHeight: CGFloat = 0
    
    let gameRole = SKSpriteNode(imageNamed: "harusmall")
    let gameCap = SKSpriteNode(imageNamed: "cap")
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    let dingSound = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let flySound = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let crashSound = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let fallSound = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let hitgroundSound = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let popSound = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    var hitBlock = false
    var hitGround = false
    
    var currentStatus: gameStatus = .play
    
    override func didMoveToView(view: SKView) {
        //关闭重力
        physicsWorld.gravity = CGVectorMake(0, 0)
        //设置代理
        physicsWorld.contactDelegate = self
        addChild(worldNode)
        
//        switchtoTeach()
        switchtoMainmenu()
        
    }
    
    // MARK: setting bg fg
    
    func setMainMenu() {
        
        //logo
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = CGPoint(x: size.width/2, y: size.height*0.8)
        logo.name = "mainmenu"
        logo.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(logo)
        
        // start game btn
        let startBtn = SKSpriteNode(imageNamed: "Button")
        startBtn.position = CGPoint(x: size.width*0.25, y: size.height*0.25)
        startBtn.name = "mainmenu"
        startBtn.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(startBtn)
        
        let play = SKSpriteNode(imageNamed: "Play")
        play.position = CGPoint.zero
        startBtn.addChild(play)
        
        // rate Btn
        let rateBtn = SKSpriteNode(imageNamed: "Button")
        rateBtn.position = CGPoint(x: size.width*0.75, y: size.height*0.25)
        rateBtn.name = "mainmenu"
        rateBtn.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(rateBtn)
        
        let rate = SKSpriteNode(imageNamed: "Rate")
        rate.position = CGPoint.zero
        rateBtn.addChild(rate)
        
        // learnBtn
        let learnBtn = SKSpriteNode(imageNamed: "button_learn")
        learnBtn.position = CGPoint(x: size.width*0.5, y: learnBtn.size.height/2 + ktopBlank)
        learnBtn.name = "mainmenu"
        learnBtn.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(learnBtn)
        
        //learnBtn anime
        let biggeranime = SKAction.scaleTo(1.02, duration: 0.75)
        biggeranime.timingMode = .EaseInEaseOut
        let smalleranime = SKAction.scaleTo(0.98, duration: 0.75)
        biggeranime.timingMode = .EaseInEaseOut
        
        learnBtn.runAction(SKAction.repeatActionForever(SKAction.sequence([
            biggeranime,
            smalleranime
            ])))
        
    }
    
    func setBackGround() {
        let bg = SKSpriteNode(imageNamed: "Background")
        bg.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        bg.position = CGPoint(x: size.width/2, y: size.height)
        bg.zPosition = ImageLayer.backGround.rawValue
        
        worldNode.addChild(bg)
        
        gameStartPoint = size.height - bg.size.height
        gameHeight = bg.size.height
        
        let leftdown = CGPoint(x: 0, y: gameStartPoint)
        let rightdown = CGPoint(x: size.width, y: gameStartPoint)
        
        self.physicsBody = SKPhysicsBody(edgeFromPoint: leftdown, toPoint: rightdown)
        self.physicsBody?.categoryBitMask = physicsLayer.gameGround
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = physicsLayer.gameRole
    }
    
    func setFrontground() {
        for i in 0..<groundCount {
            let fg = SKSpriteNode(imageNamed: "Ground")
            fg.anchorPoint = CGPoint(x: 0, y: 1.0)
            fg.position = CGPoint(x: 0 + CGFloat(i) * fg.size.width, y: gameStartPoint)
            fg.zPosition = ImageLayer.frontGround.rawValue
            fg.name = "前景"
            worldNode.addChild(fg)
        }
    }
    
    func setScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: knumFont)
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height-ktopBlank)
        scoreLabel.verticalAlignmentMode = .Top
        scoreLabel.text = "0"
        scoreLabel.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(scoreLabel)
        
    }
    
    func setScorePlate() {
        if currentScore > getHeightesScore() {
            setHeightestScore(currentScore)
        }
        
        let scorePlate = SKSpriteNode(imageNamed: "ScoreCard")
        scorePlate.position = CGPoint(x: size.width/2, y: size.height/2)
        scorePlate.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(scorePlate)
        
        let currentSLabel = SKLabelNode(fontNamed: knumFont)
        currentSLabel.fontColor = SKColor.redColor()
        currentSLabel.position = CGPoint(x: -scorePlate.size.width/4, y: -scorePlate.size.height/3)
        currentSLabel.text = "\(currentScore)"
        currentSLabel.zPosition = ImageLayer.UI.rawValue
        scorePlate.addChild(currentSLabel)
        
        let heightestSLabel = SKLabelNode(fontNamed: knumFont)
        heightestSLabel.fontColor = SKColor.redColor()
        heightestSLabel.position = CGPoint(x: scorePlate.size.width/4, y: -scorePlate.size.height/3)
        heightestSLabel.text = "\(getHeightesScore())"
        heightestSLabel.zPosition = ImageLayer.UI.rawValue
        scorePlate.addChild(heightestSLabel)
        
        let gameOver = SKSpriteNode(imageNamed: "GameOver")
        gameOver.position = CGPoint(x: size.width/2, y: size.height/2+scorePlate.size.height/2+ktopBlank+gameOver.size.height/2)
        gameOver.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(gameOver)
        
        let okBtn = SKSpriteNode(imageNamed: "Button")
        okBtn.position = CGPoint(x: size.width/4, y: size.height/2-scorePlate.size.height/2-ktopBlank-okBtn.size.height/2)
        okBtn.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(okBtn)
        
        let ok = SKSpriteNode(imageNamed: "OK")
        ok.position = CGPoint.zero
        ok.zPosition = ImageLayer.UI.rawValue
        okBtn.addChild(ok)
        
        let shareBtn = SKSpriteNode(imageNamed: "ButtonRight")
        shareBtn.position = CGPoint(x: size.width/4*3, y: size.height/2-scorePlate.size.height/2-ktopBlank-okBtn.size.height/2)
        shareBtn.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(shareBtn)
        
        let share = SKSpriteNode(imageNamed: "Share")
        share.position = CGPoint.zero
        share.zPosition = ImageLayer.UI.rawValue
        shareBtn.addChild(share)
        
        gameOver.setScale(0)
        gameOver.alpha = 0
        
        let animationS = SKAction.group([
            SKAction.fadeInWithDuration(kAnimedelay),
            SKAction.scaleTo(1, duration: kAnimedelay)
            ])
        animationS.timingMode = .EaseInEaseOut
        gameOver.runAction(SKAction.sequence([
            SKAction.waitForDuration(kAnimedelay),
            animationS,
            popSound
            ]))
        
        scorePlate.position = CGPoint(x: size.width/2, y: -scorePlate.size.height/2)
        let moveup = SKAction.moveTo(CGPoint(x: size.width/2, y: size.height/2), duration: kAnimedelay)
        moveup.timingMode = .EaseInEaseOut
        scorePlate.runAction(SKAction.sequence([
            SKAction.waitForDuration(kAnimedelay*2),
            moveup,
            popSound
            ]))
        
        okBtn.alpha = 0
        shareBtn.alpha = 0
        
        let fadeanime = SKAction.sequence([
            SKAction.waitForDuration(kAnimedelay*3),
            SKAction.fadeInWithDuration(kAnimedelay),
            popSound,
            SKAction.runBlock(switchtoEnding)
            ])
        okBtn.runAction(fadeanime)
        shareBtn.runAction(fadeanime)
        
        
    }
    
    //    func playSound() {
    //        let path = NSBundle.mainBundle().URLForResource("flapping", withExtension: "wav")
    //
    //        sound = try? AVAudioPlayer(contentsOfURL: path!)
    //        sound.play()
    //    }
    
    func setRole()
    {
        gameRole.position = CGPoint(x: size.width * 0.2, y: gameHeight * 0.4 + gameStartPoint)
        gameRole.zPosition = ImageLayer.gameRole.rawValue
        
        let offsetX = gameRole.size.width * gameRole.anchorPoint.x
        let offsetY = gameRole.size.height * gameRole.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0 - offsetX, 0 - offsetY)
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 6 - offsetY)
        CGPathAddLineToPoint(path, nil, 6 - offsetX, 16 - offsetY)
        CGPathAddLineToPoint(path, nil, 5 - offsetX, 23 - offsetY)
        CGPathAddLineToPoint(path, nil, 15 - offsetX, 22 - offsetY)
        CGPathAddLineToPoint(path, nil, 19 - offsetX, 18 - offsetY)
        CGPathAddLineToPoint(path, nil, 18 - offsetX, 8 - offsetY)
        CGPathAddLineToPoint(path, nil, 20 - offsetX, 5 - offsetY)
        CGPathAddLineToPoint(path, nil, 19 - offsetX, 1 - offsetY)
        
        CGPathCloseSubpath(path)
        
        gameRole.physicsBody = SKPhysicsBody(polygonFromPath: path)
        gameRole.physicsBody?.categoryBitMask = physicsLayer.gameRole
        gameRole.physicsBody?.collisionBitMask = 0
        gameRole.physicsBody?.contactTestBitMask = physicsLayer.gameBlock | physicsLayer.gameGround
        
        worldNode.addChild(gameRole)
    }
    
    func setRoleCap()
    {
        gameCap.position = CGPoint(x: 10 - gameCap.size.width/2, y: 20 - gameCap.size.height/2)
        gameRole.addChild(gameCap)
    }
    
    func setteach() {
        let teach = SKSpriteNode(imageNamed: "Tutorial1")
        teach.position = CGPoint(x: size.width/2, y: gameHeight*0.4+gameStartPoint)
        teach.name = "teach"
        teach.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(teach)
        
        let ready = SKSpriteNode(imageNamed: "Ready")
        ready.position = CGPoint(x: size.width/2, y: gameHeight*0.7+gameStartPoint)
        ready.name = "teach"
        ready.zPosition = ImageLayer.UI.rawValue
        worldNode.addChild(ready)
    }
    
    // MARK: 游戏流程
    
    func createRoadBlock(imgname: String) -> SKSpriteNode {
        let roadblock = SKSpriteNode(imageNamed: imgname)
        roadblock.zPosition = ImageLayer.roadBlcok.rawValue
        
        roadblock.userData = NSMutableDictionary()
        
        let offsetX = roadblock.size.width * roadblock.anchorPoint.x
        let offsetY = roadblock.size.height * roadblock.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 4 - offsetX, 1 - offsetY)
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 311 - offsetY)
        CGPathAddLineToPoint(path, nil, 48 - offsetX, 310 - offsetY)
        CGPathAddLineToPoint(path, nil, 48 - offsetX, 1 - offsetY)
        
        
        CGPathCloseSubpath(path)
        
        roadblock.physicsBody = SKPhysicsBody(polygonFromPath: path)
        roadblock.physicsBody?.categoryBitMask = physicsLayer.gameBlock
        roadblock.physicsBody?.collisionBitMask = 0
        roadblock.physicsBody?.contactTestBitMask = physicsLayer.gameRole
        
        return roadblock
    }
    
    func addRoadBlock() {
        let bottomBlock = createRoadBlock("CactusBottom")
        bottomBlock.name = "bottomBlock"
        let starX = size.width + bottomBlock.size.width/2
        
        let minY = (gameStartPoint - bottomBlock.size.height/2) + gameHeight * kBottomMin
        let maxY = (gameStartPoint - bottomBlock.size.height/2) + gameHeight * kBottomMax
        bottomBlock.position = CGPointMake(starX, CGFloat.random(min: minY, max:maxY))
        
        worldNode.addChild(bottomBlock)
        
        let topBlock = createRoadBlock("CactusTop")
        topBlock.name = "topBlock"
        topBlock.zRotation = CGFloat(180).degreesToRadians()
        topBlock.position = CGPointMake(starX, bottomBlock.position.y + bottomBlock.size.height/2 + topBlock.size.height/2 + gameRole.size.height * kConstance)
        worldNode.addChild(topBlock)
        
        let xMoveDistance = -(size.width + bottomBlock.size.width)
        let movingDuration = xMoveDistance / CGFloat(groundMoveSpeed)
        
        let movingActions = SKAction.sequence([
            SKAction.moveByX(xMoveDistance, y: 0, duration: NSTimeInterval(movingDuration))
            ])
        bottomBlock.runAction(movingActions)
        topBlock.runAction(movingActions)
    }
    
    func AddBlockLoop() {
        let firstDelay = SKAction.waitForDuration(kFirstAddBlocktime)
        let rebornBlock = SKAction.runBlock(addRoadBlock)
        let eachRebornDelay = SKAction.waitForDuration(kEachAddBlocktime)
        let RebornActions = SKAction.sequence([rebornBlock,eachRebornDelay])
        let RebornLoop = SKAction.repeatActionForever(RebornActions)
        let AllAction = SKAction.sequence([firstDelay, RebornLoop])
        runAction(AllAction, withKey: "reborn")
    }
    
    func stopAddBlock() {
        removeActionForKey("reborn")
        worldNode.enumerateChildNodesWithName("bottomBlock") { (node, _) in
            node.removeAllActions()
        }
        worldNode.enumerateChildNodesWithName("topBlock") { (node, _) in
            node.removeAllActions()
        }
    }
    
    func gameRoleFly() {
        roleSpeed = CGPoint(x: 0, y: flySpeed)
        gameCapAction()
        //播放音效
        runAction(flySound)
        
    }
    func gameCapAction() {
        let moveup = SKAction.moveByX(0, y: 12, duration: 0.15)
        moveup.timingMode = .EaseInEaseOut
        let movedown = moveup.reversedAction()
        gameCap.runAction(SKAction.sequence([moveup,movedown]))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let click = touches.first else {
            return
        }
        let clickpoint = click.locationInNode(self)
        
        switch currentStatus {
        case .mainMenu:
            if clickpoint.y < size.height * 0.15 {
                toLearning()
            }
            else if clickpoint.x < size.width/2 {
                switchtoTeach()
            }
            else {
                toRating()
            }
            break
        case .teach:
            switchtoPlay()
            break
        case .play:
            //主角飞
            gameRoleFly()
            
            break
        case .falldown:
            break
        case .showScore:
            break
        case .end:
            switchToNewGame()
            break
        }
    }
    
    //MARK: Update
    override func update(currentTime: NSTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        switch currentStatus {
        case .mainMenu:
            break
        case .teach:
            break
        case .play:
            updateFrontGround()
            updateGameRole()
            detectHitBlock()
            detecHitGround()
            updateScore()
            break
        case .falldown:
            updateGameRole()
            detecHitGround()
            break
        case .showScore:
            break
        case .end:
            break
            
        }
        
        //        updateGameRole()
        //        updateFrontGround()
        //        detectHitObject()
    }
    
    func updateGameRole()
    {
        let acceleration = CGPoint(x: 0, y: gravity)
        roleSpeed = roleSpeed + acceleration * CGFloat(dt)
        gameRole.position = gameRole.position + roleSpeed * CGFloat(dt)
        
        //碰到地面 停止
        if gameRole.position.y - gameRole.size.height/2 < gameStartPoint {
            gameRole.position = CGPoint(x: gameRole.position.x, y: gameStartPoint + gameRole.size.height/2)
        }
    }
    
    func updateFrontGround() {
        worldNode.enumerateChildNodesWithName("前景") { (sknode, _) in
            if let fg = sknode as?  SKSpriteNode {
                let groundSpeed = CGPoint(x: self.groundMoveSpeed, y: 0)
                fg.position = fg.position + groundSpeed * CGFloat(self.dt)
                
                if fg.position.x < -fg.size.width {
                    fg.position = fg.position + CGPoint(x: fg.size.width * CGFloat(self.groundCount), y: 0)
                }
            }
        }
    }
    
    //撞击block
    func detectHitBlock() {
        if hitBlock {
            hitBlock = false
            switchToFalldown()
        }
    }
    
    //撞击地面
    func detecHitGround() {
        if hitGround {
            hitGround = false
            roleSpeed = CGPoint.zero
            gameRole.zRotation = CGFloat(-90).degreesToRadians()
            //            gameRole.position = CGPoint(x: gameRole.position.x, y: gameStartPoint + gameRole.size.width/2)
            runAction(hitgroundSound)
            switchToShowScore()
        }
    }
    
    func updateScore() {
        worldNode.enumerateChildNodesWithName("topBlock") { (node, _) in
            if let block = node as? SKSpriteNode {
                if let hadpass = block.userData?["hadpass"] as? NSNumber {
                    if hadpass.boolValue {
                        return //已经计算一次得分
                    }
                }
                if self.gameRole.position.x > block.position.x + block.size.width/2 {
                    self.currentScore = self.currentScore + 1
                    self.scoreLabel.text = "\(self.currentScore)"
                    self.runAction(self.coinSound)
                    block.userData?["hadpass"] = NSNumber(bool: true)
                }
                
                
            }
        }
    }
    
    
    //MARK: 游戏状态
    func switchToFalldown() {
        currentStatus = .falldown
        
        runAction(SKAction.sequence([
            crashSound,
            SKAction.waitForDuration(0.1),
            fallSound
            ]))
        gameRole.removeAllActions()
        stopAddBlock()
    }
    
    func switchToShowScore() {
        currentStatus = .showScore
        gameRole.removeAllActions()
        stopAddBlock()
        //        NSNotificationCenter.defaultCenter().postNotificationName(MyNotification.showGameSceneNoti, object: nil)
        setScorePlate()
    }
    
    func switchToNewGame() {
        runAction(popSound)
        let newgame = GameScene.init(size: size)
        let switchTransition = SKTransition.fadeWithColor(SKColor.greenColor(), duration: 0.1)
        view?.presentScene(newgame, transition: switchTransition)
    }
    
    func switchtoEnding() {
        currentStatus = .end
    }
    
    func switchtoTeach() {
        currentStatus = .teach
        //        setBackGround()
        //        setFrontground()
        //        setRole()
        //        setRoleCap()
        //        addRoadBlock()
        worldNode.enumerateChildNodesWithName("mainmenu") { (node, _) in
            node.runAction(SKAction.sequence([
                SKAction.fadeOutWithDuration(0.05),
                SKAction.removeFromParent()
                ]))
        }
        
        setScoreLabel()
        setteach()
    }
    
    func switchtoPlay() {
        currentStatus = .play
        
        worldNode.enumerateChildNodesWithName("teach") { (node, _) in
            node.runAction(SKAction.sequence([
                SKAction.fadeOutWithDuration(0.05),
                SKAction.removeFromParent()
                ]))
        }
        AddBlockLoop()
        gameRoleFly()
    }
    
    func switchtoMainmenu() {
        currentStatus = .mainMenu
        
        setBackGround()
        setFrontground()
        setRole()
        setRoleCap()
        setMainMenu()
    }
    
    // MARK: 分数
    // 最高分
    func getHeightesScore() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("heightestScore")
    }
    
    func setHeightestScore(score: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "heightestScore")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    //MARK: physics
    func didBeginContact(contact: SKPhysicsContact) {
        let beenContact = contact.bodyA.categoryBitMask == physicsLayer.gameRole ? contact.bodyB : contact.bodyA
        
        if beenContact.categoryBitMask == physicsLayer.gameGround {
            hitGround = true
        }
        
        if beenContact.categoryBitMask == physicsLayer.gameBlock {
            hitBlock = true
            NSLog("aaa")
        }
    }
    
    //MARK: ELSE
    func toLearning() {
        openUrl(learningUrl)
        
    }
    
    func toRating() {
        openUrl(appStoreUrl)
    }
    
    func openUrl(url:String) {
        let nsurl = NSURL(string: url)
        UIApplication.sharedApplication().openURL(nsurl!)
    }
    
}

