//
//  GameScene.swift
//  kobe skeleton
//
//  Created by Nate on 1/6/25.

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.numberOfLines = 5
            label.fontSize = 38
            label.horizontalAlignmentMode = .left
            label.preferredMaxLayoutWidth = 1000
            label.text = "Disclaimer: \nby opening this app, \nyou take full responsibility \nover the fate of your device.\nIf you throw your phone and it breaks,\nthat's a skill issue.\n\n\nNevertheless,\n\nWe reccomend a hefty phone case\nunless you're looking to upgrade \nor unplug sometime soon. \n\nAlso, someone might snatch your \nphone if you throw it far in public.\n\n\nTOSS THIS PHONE TO PROCEED."
            // Adjust the height accordingly)
            label.run(SKAction.fadeIn(withDuration: 1.0))
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
