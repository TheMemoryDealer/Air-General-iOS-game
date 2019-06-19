//
//  MainMenu.swift
//  Air General
//
//  Created by me on 26/03/2019.
//  Copyright © 2019 Mazvydas Gudelis. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene{
    let game2 = SKLabelNode(fontNamed: "theBoldFont")

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let game = SKLabelNode(fontNamed: "theBoldFont")
        game.text = "Air"
        game.fontSize = 200
        game.fontColor = SKColor.white
        game.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        game.zPosition = 1
        self.addChild(game)
        
        let game1 = SKLabelNode(fontNamed: "theBoldFont")
        game1.text = "Combat"
        game1.fontSize = 200
        game1.fontColor = SKColor.white
        game1.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.625)
        game1.zPosition = 1
        self.addChild(game1)
        
        game2.text = "Start"
        game2.fontSize = 150
        game2.fontColor = SKColor.white
        game2.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.4)
        game2.zPosition = 1
        self.addChild(game2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            if game2.contains(pointOfTouch){
                let sceneToMove = GameScene(size: self.size)
                sceneToMove.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMove, transition: myTransition)
            }
        }
    }
    
    
}
