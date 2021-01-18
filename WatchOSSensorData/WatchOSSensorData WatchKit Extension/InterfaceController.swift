//
//  InterfaceController.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Abiram Pakeerathan and Lukas Bröning in 2021.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var upperLabel   : WKInterfaceLabel!
    @IBOutlet weak var lowerLabel   : WKInterfaceLabel!
    @IBOutlet weak var startButton  : WKInterfaceButton!
    @IBOutlet weak var stopButton   : WKInterfaceButton!
    var isTrackingActive    = false
    let deviceMotionManager = DeviceMotionManager()
    let healthManager       = HealthManager()
    let extensionDelegate   = ExtensionDelegate()
    
    
    func startTracking(timeInSeconds: Double = 60, frequency: Double = 1.0/32.0, sensorType: String = "deviceMotion") {
        
        //start tracking of sensor type
        switch sensorType {
        case "deviceMotion":
            deviceMotionManager.startMotionTracking(timeInSeconds: timeInSeconds, frequency: frequency)
        case "heartRate":
            healthManager.startHeartRateTracking(timeInSeconds: timeInSeconds)
        case "oxygenSaturation":
            healthManager.fetchOxygenSaturationData()
        case "ecg":
            healthManager.fetchEcgData()
        default:
            print("default")
        }
    }
    
    @IBAction func startTrackingButtonPressed() {
        //start tracking
        if (isTrackingActive == false) {
            isTrackingActive = true
            extensionDelegate.startExtRunSession()
            //startTracking(timeInSeconds: 5, frequency: 1.0/32.0, sensorType: "deviceMotion")
            startTracking(timeInSeconds: 20, sensorType: "heartRate")
            
            //set UI
            self.startButton.setBackgroundColor(UIColor.lightGray)
            self.stopButton.setBackgroundColor(UIColor.red)
        }
    }
 
    @IBAction func stopTrackingButtonPressed() {
        //stop tracking
        if (isTrackingActive == true) {
            //TODO: only stop the active one
            deviceMotionManager.stopMotionTracking()
            healthManager.stopHeartRateUpdates()
            print("stopped manually")
            
            extensionDelegate.stopExtRunSession()
            
            //set UI
            self.startButton.setBackgroundColor(UIColor.green)
            self.stopButton.setBackgroundColor(UIColor.lightGray)
        }
    }
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        self.startButton.setBackgroundColor(UIColor.green)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
}
