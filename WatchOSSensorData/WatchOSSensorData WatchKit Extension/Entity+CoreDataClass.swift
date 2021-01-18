//
//  Entity+CoreDataClass.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Lukas Bröning on 18.01.21.
//
//

import Foundation
import CoreData

@objc(Entity)
public class Entity: NSManagedObject {
    struct Json {
        var reference: NSManagedObjectID!
    }
}
