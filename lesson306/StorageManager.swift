//
//  StorageManager.swift
//  lesson306
//
//  Created by Garib Agaev on 12.09.2023.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "lesson306")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
