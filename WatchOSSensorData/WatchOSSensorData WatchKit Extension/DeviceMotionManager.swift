//
//  DeviceMotionManager.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Abiram Pakeerathan and Lukas Bröning in 2021.
//

import WatchKit
import Foundation
import CoreMotion

class DeviceMotionManager {
    
    let motionManager       = CMMotionManager()
    var initialTime         = 0.0
    var postRequestFrequency = 0.0
    var dataCounter         = 0.0
    var previousAccelX      = 0.0
    var previousAccelY      = 0.0
    var previousAccelZ      = 0.0
    let extensionDelegate   = ExtensionDelegate()
    var jsonString          = ""
    var motionArray: MotionArray = MotionArray(array: [])
    
    
    func startMotionTracking(timeInSeconds: Double = 60, frequency: Double = 1.0/32.0) {
        //check if CMMotionManager is available and start
        if (motionManager.isDeviceMotionAvailable) {
            //set initialTime
            initialTime = Date().timeIntervalSince1970
            
            //set frequency, set postRequestFrequency to print or post Data once every second
            motionManager.deviceMotionUpdateInterval = frequency
            postRequestFrequency = 1/frequency
            
            //capture all of the incoming DeviceMotion data with handler by queueing
            let handler:CMDeviceMotionHandler = {(data, error) in
                if let motionData = data {

                    //set label text in UI
                    if let accessUI = WKExtension.shared().rootInterfaceController as? InterfaceController {
                        accessUI.upperLabel.setText("Seconds active: ")
                        accessUI.lowerLabel.setText(String(self.dataCounter/self.postRequestFrequency))
                    }
                    
                    //stop tracking if time is up
                    if (Date().timeIntervalSince1970 >= self.initialTime + timeInSeconds) {
                        //stop tracking and print time is up
                        print("Time (", String((self.dataCounter)/self.postRequestFrequency), "sec ) is up!")
                        self.stopMotionTracking()
                    } else {
                        //count collected data
                        self.dataCounter+=1
                        
                        //set timestamp of collected data
                        let d = Date()
                        let df = DateFormatter()
                        df.dateFormat = "y-MM-dd H:mm:ss-SS"
                        let currentDate = df.string(from: d)
                        
                        //remove noise, smooth acceleration data by low-pass filtering
                        /*
                        let newAccelX = motionData.userAcceleration.x
                        let newAccelY = motionData.userAcceleration.y
                        let newAccelZ = motionData.userAcceleration.z
                        
                        let outputAccelX = frequency * newAccelX + (1.0-frequency) * self.previousAccelX
                        let outputAccelY = frequency * newAccelY + (1.0-frequency) * self.previousAccelY
                        let outputAccelZ = frequency * newAccelZ + (1.0-frequency) * self.previousAccelZ
                        
                        self.previousAccelX = outputAccelX
                        self.previousAccelY = outputAccelY
                        self.previousAccelZ = outputAccelZ
                        */
                        
                        //only get movements - threshold: 0.3
                        if (motionData.userAcceleration.x > 0.3 || motionData.userAcceleration.y > 0.3 || motionData.userAcceleration.z > 0.3 || motionData.rotationRate.x > 0.3 || motionData.rotationRate.y > 0.3 || motionData.rotationRate.z > 0.3) {
                            
                            //append current motion data to array
                            self.motionArray.array.append(MotionArray.AppleWatchMotion(
                                                        objNum: self.dataCounter,
                                                        timestamp: currentDate,
                                                        accelUserX: motionData.userAcceleration.x,
                                                        accelUserY: motionData.userAcceleration.y,
                                                        accelUserZ: motionData.userAcceleration.z,
                                                        gravityX: motionData.gravity.x,
                                                        gravityY: motionData.gravity.y,
                                                        gravityZ: motionData.gravity.z,
                                                        gyroX: motionData.rotationRate.x,
                                                        gyroY: motionData.rotationRate.y,
                                                        gyroZ: motionData.rotationRate.z,
                                                        attitudePitch: motionData.attitude.pitch,
                                                        attitudeRoll: motionData.attitude.roll,
                                                        attitudeYaw: motionData.attitude.yaw))
                            //print(self.dataCounter)
                        }
                        
                        //print and post Data once every second
                        //self.dataCounter % self.postRequestFrequency == 0
                        let postRequestCountChecker = self.dataCounter.truncatingRemainder(dividingBy: self.postRequestFrequency)
                        if (postRequestCountChecker == 0 && self.motionArray.array.count != 0) {
                            self.encodeMotionToJSON(arr: self.motionArray.array)
                            //empty array
                            self.motionArray.array = []
                        }
                    }
                }
            }
            //start delivery of DeviceMotion data
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: handler)
        } else {
            //if CMMotionManager is not available
            print("CMMotionManager not available")
        }
    }

    
    func encodeMotionToJSON (arr: [MotionArray.AppleWatchMotion]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            let data = try encoder.encode(self.motionArray)
            let json = String(data: data, encoding: .utf8)!
            self.jsonString = json
            print(self.jsonString)
        } catch {
            print("error handling")
        }
    }

    
    func stopMotionTracking() {
        if (motionManager.isDeviceMotionActive) {
            motionManager.stopDeviceMotionUpdates()
            
            if let accessUI = WKExtension.shared().rootInterfaceController as? InterfaceController {
                accessUI.isTrackingActive = false
                accessUI.upperLabel.setText("Start again?")
            }
            dataCounter = 0
            //TODO: stop ExtendedRuntimeSession?
            //extensionDelegate.stopExtRunSession()
        }
    }
    
    
    func stopMotionTrackingManually() {
        if (motionManager.isDeviceMotionActive) {
            stopMotionTracking()
            print("Manually stopped!")
        }
    }
}
