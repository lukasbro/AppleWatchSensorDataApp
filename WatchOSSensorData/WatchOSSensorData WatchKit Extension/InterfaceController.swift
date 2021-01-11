//
//  InterfaceController.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Abiram Pakeerathan and Lukas Bröning in 2021.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var upperLabel: WKInterfaceLabel!
    @IBOutlet weak var lowerLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var stopButton: WKInterfaceButton!
    
    var isTrackingActive = false
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    
    
    @IBAction func startTrackingButtonPressed() {
        //start tracking
        if (isTrackingActive == false) {
            isTrackingActive = true
            startTracking(timeInSeconds: 5)
        }
    }
 
    @IBAction func stopTrackingButtonPressed() {
        //stop tracking
        if (isTrackingActive == true) {
            DeviceMotionData().stopMotionTrackingManually()
        }
    }
    
    func startTracking (timeInSeconds: Double){
        let timer = timeInSeconds
        DeviceMotionData().startMotionTracking(timeInSeconds: timer)
        HeartRateData().startHeartRateTracking(timeInSeconds: timer)
    }
}
