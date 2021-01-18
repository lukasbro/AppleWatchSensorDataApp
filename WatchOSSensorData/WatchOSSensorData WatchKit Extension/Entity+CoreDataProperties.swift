//
//  Entity+CoreDataProperties.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Lukas Bröning on 18.01.21.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var json: String?

}

extension Entity : Identifiable {

}
