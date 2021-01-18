//
//  DataStorage.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Lukas Bröning on 18.01.21.
//

import Foundation
import CoreData

class DataStorage {

    let context: NSManagedObjectContext { return persistentContainer.viewContext }

    //set up core data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        //container.viewContext.automaticallyMergesChangesFromParent = true
        //container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    func save() {
        
        let json = NSManagedObjectContext(entity: nil, insertInto: context)

        if context.hasChanges {
            do {
                try context.save()
                json.append(json)
            } catch {
                let nserror = error as NSError
                fatalError("Error: \(nserror)")
            }
        }
    }
}
