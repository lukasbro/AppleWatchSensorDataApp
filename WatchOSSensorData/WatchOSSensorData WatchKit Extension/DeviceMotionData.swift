//
//  DeviceMotionData.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Abiram Pakeerathan and Lukas Bröning in 2021.
//

import WatchKit
import Foundation
import CoreMotion

class DeviceMotionData {
    
    let motionManager       = CMMotionManager()
    var timer               = 0.0
    var initialTime         = 0.0
    var frequency           = 0.2     //max. 100Hz - current: 5 Hz
    var postDataFrequency   = 0.0
    var dataCounter         = 0.0
    var previousAccelX      = 0.0
    var previousAccelY      = 0.0
    var previousAccelZ      = 0.0
    var motionArray : [MotionCodable] = []
    
    func startMotionTracking(timeInSeconds: Double)
    {
        //check if CMMotionManager is available and start
        if (motionManager.isDeviceMotionAvailable)
        {
            //set timer and initialTime
            timer = timeInSeconds
            initialTime = Date().timeIntervalSince1970
            
            //set frequency, set postDataFrequency to print or post Data once every second
            motionManager.deviceMotionUpdateInterval = frequency
            postDataFrequency = 1/frequency
            
            //capture all of the incoming DeviceMotion data with handler by queueing
            let handler:CMDeviceMotionHandler = {(data, error) in
                if (data != nil)
                {
                    //stop tracking if time is up
                    if (Date().timeIntervalSince1970 >= self.initialTime + self.timer)
                    {
                        self.stopMotionTracking()
                        print("Time (", String((self.dataCounter)/self.postDataFrequency), "sec ) is up!")
                    }
                    
                    //set label text in UI
                    if let accessUI = WKExtension.shared().rootInterfaceController as? InterfaceController {
                        accessUI.upperLabel.setText("Seconds active: ")
                        accessUI.lowerLabel.setText(String(self.dataCounter/self.postDataFrequency))
                    }
                    
                    //count collected data
                    self.dataCounter+=1
                    
                    //set timestamp of collected data
                    let d = Date()
                    let df = DateFormatter()
                    df.dateFormat = "y-MM-dd H:mm:ss-SS"
                    let currentDate = df.string(from: d)
                    
                    //remove noise, smooth acceleration data by low-pass filtering
                    let newAccelX = data!.userAcceleration.x
                    let newAccelY = data!.userAcceleration.y
                    let newAccelZ = data!.userAcceleration.z
                    
                    let outputAccelX = self.frequency * newAccelX + (1.0-self.frequency) * self.previousAccelX
                    let outputAccelY = self.frequency * newAccelY + (1.0-self.frequency) * self.previousAccelY
                    let outputAccelZ = self.frequency * newAccelZ + (1.0-self.frequency) * self.previousAccelZ
                    
                    self.previousAccelX = outputAccelX
                    self.previousAccelY = outputAccelY
                    self.previousAccelZ = outputAccelZ
                    
                    //elimante redundant data - threshold PROBLEM
//                    if (outputAccelX < 0.5) {
//                        outputAccelX = 0.0
//                    } else if (outputAccelY < 0.5) {
//                        outputAccelY = 0.0
//                    } else if (outputAccelZ < 0.5) {
//                        outputAccelZ = 0.0
//                    }
                    
                    //append current motion data to array
                    self.motionArray.append(MotionCodable(
                                                timeStamp: currentDate,
                                                xAccelUser: outputAccelX,
                                                yAccelUser: outputAccelY,
                                                zAccelUser: outputAccelZ,
                                                xGravity: data!.gravity.x,
                                                yGravity: data!.gravity.y,
                                                zGravity: data!.gravity.z,
                                                xGyro: data!.rotationRate.x,
                                                yGyro: data!.rotationRate.y,
                                                zGyro: data!.rotationRate.z,
                                                pitch: data!.attitude.pitch,
                                                roll: data!.attitude.roll,
                                                yaw: data!.attitude.yaw,
                                                dataNum: self.dataCounter))

                    //print and post Data once every second
                    //self.dataCounter % self.postDataFrequency == 0
                    let postDataChecker = self.dataCounter.truncatingRemainder(dividingBy: self.postDataFrequency)
                    if (postDataChecker == 0)
                    {
                        self.encodeAndPost(arr: self.motionArray)
                        //empty array
                        self.motionArray = []
                    }
                }
            }
            //start delivery of DeviceMotion data
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: handler)
        }
        else
        {
            //if CMMotionManager is not available
            print("CMMotionManager not available")
        }
    }
    
    
    func encodeAndPost(arr: [MotionCodable]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(self.motionArray)
        print(String(data: data, encoding: .utf8)!)
    }

    
    func stopMotionTracking () {
        if (motionManager.isDeviceMotionActive)
        {
            motionManager.stopDeviceMotionUpdates()
            //PROBLEM Abhängigkeit der heart rate von device motion!
            HeartRateData().stopHeartRateUpdates()
            if let accessUI = WKExtension.shared().rootInterfaceController as? InterfaceController {
                accessUI.isTrackingActive = false
                accessUI.upperLabel.setText("Start again?")
            }
            //PROBLEM ExtendedRuntimeSession ERROR
            //ExtensionDelegate().session.invalidate()
        }
    }
    
    
    func stopMotionTrackingManually () {
        //PROBLEM geht in Funktion rein, ändert auch kurz UI, aber STOPPT NICHT!
        stopMotionTracking()
        print("Manually stopped!")
    }
}
