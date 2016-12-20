//
//  PersistencyManager.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 08/04/16.
//  Copyright © 2016 eComNation . All rights reserved.
//

import UIKit
import CoreData

public protocol PersistencyOperation {
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int)
}

let persistencyManager = PersistencyManager.sharedManager

open class PersistencyManager: NSObject {

    // MARK: Properties
    /// Singleton instance of `PersistencyManager`
    open static let sharedManager = PersistencyManager()
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.RP.Greenfibre" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Greenfibre", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: Fetching
    /**
     Fetches first entity with given entity name.
     
     - Parameter entityName: Name of the core data entity for which to fetch detail.
     
     - Returns: First entity from entity collection if found, else `nil`.
     */
    func fetchFirst<T: NSManagedObject>(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> T? {
        
        let allEntities: [T]? = fetchAll(entityName, predicate: predicate, sortDescriptors: sortDescriptors)
        if ((allEntities?.isEmpty) == false) {
            return allEntities?.first
        }
        
        return nil
    }
    
    /**
     Fetches last entity with given entity name.
     
     - Parameter entityName: Name of the core data entity for which to fetch detail.
     
     - Returns: Last entity from entity collection if found, else `nil`.
     */
    func fetchLast<T: NSManagedObject>(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> T? {
        
        let allEntities: [T]? = fetchAll(entityName, predicate: predicate, sortDescriptors: sortDescriptors)
        if ((allEntities?.isEmpty) == false) {
            return allEntities?.last
        }
        
        return nil
    }
    
    /**
     Fetches all entity with given entity name.
     
     - Parameters:
        - entityName: Name of the core data entity for which to fetch detail.
        - predicate: An optional predict to apply on fetching if result is needed based on some condition.
     
     - Returns: An array entity collection if found, else `nil`.
     */
    func fetchAll<T: NSManagedObject>(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> Array<T>? {
        
        //Prepare fetch request
        let fetchRequest:  NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        if sortDescriptors != nil {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results as? Array<T>
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    // MARK: - Insertion
    func insert(_ entityName: String, entityData: Dictionary<String, AnyObject>, autoSave: Bool = true, position: Int = 0) {
        let entityDescription =  NSEntityDescription.entity(forEntityName: entityName, in:managedObjectContext)
        let entity = NSManagedObject(entity: entityDescription!, insertInto: managedObjectContext)
        if let entityObj = entity as? PersistencyOperation {
            entityObj.setWithDictionary(entityData, position: position)
            if autoSave {
                saveContext()
            }
        } else {
            managedObjectContext.delete(entity)
            print("\(entityName) Not following protocol")
        }
    }
    
    func insert(_ entityName: String, entitiesArray: Array<Dictionary<String, AnyObject>>, autoSave: Bool = true) {
        for (index, entityData) in entitiesArray.enumerated() {
            insert(entityName, entityData: entityData, autoSave: false, position: index)
        }
        
        if autoSave {
            saveContext()
        }
    }
    
    func append(_ entityName: String, entitiesArray: Array<Dictionary<String, AnyObject>>, autoSave: Bool = true) {
        let counts = count(entityName) - 1
        let currentCount:Int =  counts < 0 ? 0 : counts
        for (index, entityData) in entitiesArray.enumerated() {
            insert(entityName, entityData: entityData, autoSave: false, position: index + currentCount)
        }
        
        if autoSave {
            saveContext()
        }
    }
    
    func prepare(_ entityName: String, entityData: Dictionary<String, AnyObject>, position: Int = 0) -> NSManagedObject {
        let entityDescription =  NSEntityDescription.entity(forEntityName: entityName, in:managedObjectContext)
        let entity = NSManagedObject(entity: entityDescription!, insertInto: managedObjectContext)
        if let entityObj = entity as? PersistencyOperation {
            entityObj.setWithDictionary(entityData, position: position)
        } else {
            managedObjectContext.delete(entity)
            print("\(entityName) Not following protocol")
        }
        
        return entity
    }
    
    func prepare(_ entityName: String, entitiesArray: Array<Dictionary<String, AnyObject>>) -> Array<NSManagedObject> {
        var entityArray: [NSManagedObject] = []
        for (index, entityData) in entitiesArray.enumerated() {
            entityArray.append(prepare(entityName, entityData: entityData, position: index))
        }
        return entityArray
    }
    
    // MARK: Replacing
    /**
     Replaces all entities with array of new entities for given entity name.
     
     - Parameters:
        - entityName: Name of the core data entity to replace.
        - entitiesArray: Array of dictionaries with details of entities.
     */
    func replaceAllWithArray(_ entityName: String, entitiesArray: Array<Dictionary<String, AnyObject>>, autoSave: Bool = true, predicate: NSPredicate? = nil) {
        deleteAll(entityName, predicate: predicate)
        insert(entityName, entitiesArray: entitiesArray, autoSave: autoSave)
    }
    
    // MARK: Deletion
    /**
     Deletes first entitiy for given entity name.
     
     - Parameter entityName: Name of an entity which needs to be deleted.
     */
    func deleteFirst(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        if let firstEntity: NSManagedObject = fetchFirst(entityName, predicate: predicate, sortDescriptors: sortDescriptors) {
            managedObjectContext.delete(firstEntity)
            saveContext()
        } else {
            print("Couldn't Deleting first entity of type : " + entityName)
        }
    }
    
    /**
     Deletes last entitiy for given entity name.
     
     - Parameter entityName: Name of an entity which needs to be deleted.
     */
    func deleteLast(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        if let lastEntity: NSManagedObject = fetchLast(entityName, predicate: predicate, sortDescriptors: sortDescriptors) {
            managedObjectContext.delete(lastEntity)
            saveContext()
        } else {
            print("Couldn't Deleting last entity of type : " + entityName)
        }
    }
    
    /**
     Deletes all entities for given entity name.
     
     - Parameter entityName: Name of an entity which needs to be deleted.
     */
    func deleteAll(_ entityName: String, predicate: NSPredicate? = nil) {
        
        let allEntities: [NSManagedObject]? = fetchAll(entityName, predicate: predicate)

        for entity in allEntities! {
            managedObjectContext.delete(entity)
        }
        
        saveContext()
    }
    
    // MARK: - Utility operations
    func count(_ entityName: String, predicate: NSPredicate? = nil) -> Int {
        
        let fetchRequest:  NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: entityName, in:managedObjectContext)
        fetchRequest.predicate = predicate
        fetchRequest.includesSubentities = false
        
        do {
            let count = try managedObjectContext.count(for: fetchRequest)
            return count as Int
    
        } catch {
            return 0
        }
    }
}
