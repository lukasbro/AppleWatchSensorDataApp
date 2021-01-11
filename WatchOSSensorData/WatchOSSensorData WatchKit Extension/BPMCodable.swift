//
//  BPMCodable.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Lukas Bröning on 10.01.21.
//

import Foundation

struct BPMCodable: Codable {
    var timeStamp   : String?
    var heartRate   : Double?
    var dataNum     : Double?
}
