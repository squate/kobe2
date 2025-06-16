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
    @IBOutlet weak var myButton: UIButton! // This is your outlet
    @IBOutlet weak var spinDecal: UIImageView!
    let motionManager = CMMotionManager()
    var timer: Timer!
    var up = false
    var freeSpin = false
    var (t0, t1, air, best) = (0, 0, 0, 0) //times to ascertain throw air/ record
    var (aX, aY, aZ) = (0.0, 0.0, 0.0) //accelerometer axes
    var (gX, gY, gZ) = (0.0, 0.0, 0.0) //gyroscope axes
    var (aN, aMaxN, aLastMaxN) = (0.0, 0.0, 0.0) //magnitude of accelerometer and related vars
    var (gMag, gPrevMag, twirl) = (0.0, 0.0, 0.0) //as above w/ gyroscope
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinDecal.image = spinDecal.image?.withRenderingMode(.alwaysTemplate)
        spinDecal.tintColor = UIColor.black
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        //motionManager.startMagnetometerUpdates()
        //motionManager.startDeviceMotionUpdates()
        myLabel.numberOfLines=4
        
        timer = Timer.scheduledTimer(timeInterval: 1.0/1000.0, target: self, selector: #selector(GameViewController.update), userInfo: nil, repeats: true)
        
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
    //taking in and using sensor data to parse throws
    @objc func update() {
        if let accelerometerData = motionManager.accelerometerData {
            //print(accelerometerData, motionManager.gyroData ?? 0)
            
            //set accel vars to sensor data
            aX = accelerometerData.acceleration.x
            aY = accelerometerData.acceleration.y
            aZ = accelerometerData.acceleration.z
            aN = ( aX*aX + aY*aY + aZ*aZ ) //magnitude of acceleration
            
            //if still applying force
            if (aN > aMaxN){
                aMaxN = aN
            }
            
            //if phone begins freefall
            if (thrown(yeet:aN) && !up){
                t0 = Int(Date().timeIntervalSince1970 * 1000)
                up = true
                if (!spinThrown(gN0: gPrevMag, gN1: gMag)){
                    twirl = 0
                    //todo: temp pause on gyro updates
                }
                //TODO: set label to indicate twirl
                //TODO: INVERT DISPLAY COLORS
                myButton.tintColor = UIColor.orange
            }
            
            //phone lands
            if (up && landed(yeet: aN) && !spinThrown(gN0: gPrevMag, gN1: gMag)){
                t1 = Int(Date().timeIntervalSince1970 * 1000)
                air = t1 - t0 //airtime in ms
                aLastMaxN = aMaxN //log max yeet of prev throw
                //TODO: SET TEXT FILTER TO SHOW MAX YEET
                aMaxN = 0
                
                //TODO: SAVE PREV THROW SOMEWHERE
                
                //TODO: CHECK FOR BEST AIRTIME
                if (air > best){
                    best = air
                    //TODO: set best airtime onscreen somewhere
                }
                
                //TODO: determine if throw meets quest parameters, win or lose
                //TODO: UNINVERT COLORS
                myButton.tintColor = UIColor.black
                spinDecal.tintColor = UIColor.black
                up = false
                if (air > 50){
                    myLabel.text=(
                        "airtime: " + String(air) + //airtime is displaying werid
                        "ms\nspin: " + String(Int(twirl)) +
                        "\nyeet: " + String(format: "%f", aLastMaxN) +
                        "\nbest airtime: " + String(best) + "ms"
                    )
                }
            }
            
            /*
            myLabel.text=(
                "x:" + String(format: "%f",aX) +
                "\ny:" + String(format: "%f",aY) +
                "\nz:" + String(format: "%f",aZ) +
                "\nMANGITUDE:" + String( format: "%f", aN)
            )*/
             
        }
        if let gyroData = motionManager.gyroData {
            //print(motionManager.accelerometerData ?? 0, gyroData)
            gX = gyroData.rotationRate.x
            gY = gyroData.rotationRate.y
            gZ = gyroData.rotationRate.z
            
            /* gyro raw logging
            myLabel.text=(
                "gX:" + String(format: "%f",gX) +
                "\ngY:" + String(format: "%f",gY) +
                "\ngZ:" + String(format: "%f",gZ)
            )
            */
            
            //min: -36 max: 36
            //red: gX
            
            gPrevMag = gMag
            gMag = ( gX*gX + gY*gY + gZ*gZ )
            
            //detect spinning throw
            if (spinThrown(gN0: gMag, gN1: gPrevMag) && !up){
                t0 = Int(Date().timeIntervalSince1970 * 1000)
                twirl = gMag
                //TODO: SET LABEL FOR TWIRL AMOUNT
                //INVERT DISPLAY COLORS
                myButton.tintColor = UIColor.orange
                /*TODO: set tint until land in a way that doesn't constantly check.
                 saucy responsive and efficient. noticeable on rapidly spinning device
                options:
                 
                //color per axis,
                //color per axis direction
                //xyz -> rgb, twirl-> saturation, aNMax -> brightness)?
                */
                freeSpin = true
                up = true
                
                spinDecal.tintColor = UIColor(red: (gX+36)/72.0, green: (gY+36)/72.0, blue: (gZ+36)/72.0, alpha: twirl/3888.0)//todo: set based on gyro data, map
            }
        }
    }
    
    //if phone is probably falling
    func thrown(yeet: Double) -> Bool{
        return ((yeet < 0.025)); //this might have to change value depending on hopw accel is between ios and android
    }
    
    //if phone is spinning at a consistent rate, it's probably not being supported externally
    func spinThrown(gN0 : Double, gN1 : Double) -> Bool{
        return (((gN1-gN0)/gN0 < 0.1) && (gN1 > 100))//might have to tweak the last constant here
    }
    
    func landed(yeet: Double) -> Bool{
        return ((yeet > 0.98)); //this might have to change value depending on hopw accel is between ios and android
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
