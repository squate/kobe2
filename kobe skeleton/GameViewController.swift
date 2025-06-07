//
//  GameViewController.swift
//  kobe skeleton
//
//  Created by Nate on 1/6/25.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion



class GameViewController: UIViewController {
    @IBOutlet weak var myLabel: UILabel! // This is your outlet
    let motionManager = CMMotionManager()
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        myLabel.numberOfLines=4
        
        timer = Timer.scheduledTimer(timeInterval: 1.0/50.0, target: self, selector: #selector(GameViewController.update), userInfo: nil, repeats: true)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    @objc func update() {
        if let accelerometerData = motionManager.accelerometerData {
            //print(accelerometerData, motionManager.gyroData ?? 0)
            myLabel.text=(
                "x:" + String(format: "%f",(accelerometerData.acceleration.x)) +
                "\ny:" + String(format: "%f",(accelerometerData.acceleration.y)) +
                "\nz:" + String(format: "%f",(accelerometerData.acceleration.z)) +
                "\nMANGITUDE:" + String( format: "%f",
                    accelerometerData.acceleration.x * accelerometerData.acceleration.x +
                    accelerometerData.acceleration.y * accelerometerData.acceleration.y +
                    accelerometerData.acceleration.z * accelerometerData.acceleration.z
                )
            )
        }
        if let gyroData = motionManager.gyroData {
            //print(motionManager.accelerometerData ?? 0, gyroData)
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
