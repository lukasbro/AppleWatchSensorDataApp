//
//  MotionCodable.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Lukas Bröning on 10.01.21.
//

import Foundation

struct MotionCodable: Codable {
    var timeStamp   : String?
    var xAccelUser  : Double?
    var yAccelUser  : Double?
    var zAccelUser  : Double?
    var xGravity    : Double?
    var yGravity    : Double?
    var zGravity    : Double?
    var xGyro   : Double?
    var yGyro   : Double?
    var zGyro   : Double?
    var pitch   : Double?
    var roll    : Double?
    var yaw     : Double?
    var dataNum : Double?
}
