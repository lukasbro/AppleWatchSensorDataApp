//
//  AppleWatchMotion.swift
//  iwatchGyro WatchKit Extension
//
//  Created by Abiram Pakeerathan and Lukas Bröning in 2021.
//

import Foundation


struct MotionArray: Codable {
    
    //dynamic key and nested object
    struct CustomCodingKey: CodingKey {

        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        // We are not using this, thus just return nil
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let objNum = CustomCodingKey(stringValue: "objNum")!
        static let timestamp = CustomCodingKey(stringValue: "timestamp")!
        static let accelUserX = CustomCodingKey(stringValue: "accelUserX")!
        static let accelUserY = CustomCodingKey(stringValue: "accelUserY")!
        static let accelUserZ = CustomCodingKey(stringValue: "accelUserZ")!
        static let gravityX = CustomCodingKey(stringValue: "gravityX")!
        static let gravityY = CustomCodingKey(stringValue: "gravityY")!
        static let gravityZ = CustomCodingKey(stringValue: "gravityZ")!
        static let gyroX = CustomCodingKey(stringValue: "gyroX")!
        static let gyroY = CustomCodingKey(stringValue: "gyroY")!
        static let gyroZ = CustomCodingKey(stringValue: "gyroZ")!
        static let attitudePitch = CustomCodingKey(stringValue: "attitudePitch")!
        static let attitudeRoll = CustomCodingKey(stringValue: "attitudeRoll")!
        static let attitudeYaw = CustomCodingKey(stringValue: "attitudeYaw")!
    }
    
    //motion object
    struct AppleWatchMotion: Codable {
        let objNum:Double
        let timestamp:String
        let accelUserX:Double
        let accelUserY:Double
        let accelUserZ:Double
        let gravityX:Double
        let gravityY:Double
        let gravityZ:Double
        let gyroX: Double
        let gyroY: Double
        let gyroZ: Double
        let attitudePitch: Double
        let attitudeRoll: Double
        let attitudeYaw: Double
    }
    
    //motion object array
    var array:[AppleWatchMotion]
    
    //build JSON object
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKey.self)
        for motion in array {
            if let key = CustomCodingKey(stringValue: motion.timestamp) {
                var nested = container.nestedContainer(keyedBy: CustomCodingKey.self,
                    forKey: key)
                try nested.encode(motion.objNum, forKey: .objNum)
                try nested.encode(motion.timestamp, forKey: .timestamp)
                try nested.encode(motion.accelUserX, forKey: .accelUserX)
                try nested.encode(motion.accelUserY, forKey: .accelUserY)
                try nested.encode(motion.accelUserZ, forKey: .accelUserZ)
                try nested.encode(motion.gravityX, forKey: .gravityX)
                try nested.encode(motion.gravityY, forKey: .gravityY)
                try nested.encode(motion.gravityZ, forKey: .gravityZ)
                try nested.encode(motion.gyroX, forKey: .gyroX)
                try nested.encode(motion.gyroY, forKey: .gyroY)
                try nested.encode(motion.gyroZ, forKey: .gyroZ)
                try nested.encode(motion.attitudePitch, forKey: .attitudePitch)
                try nested.encode(motion.attitudeRoll, forKey: .attitudeRoll)
                try nested.encode(motion.attitudeYaw, forKey: .attitudeYaw)
            }
        }
    }
}
