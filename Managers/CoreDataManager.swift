//
//  CoreDataManager.swift
//  QRScanner
//

import Foundation
import CoreData
import AATools

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let localPersistanceContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        localPersistanceContainer.viewContext
    }
    
    private init() {
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageTransformer"))
        
        localPersistanceContainer = NSPersistentContainer(name: "Model")
        localPersistanceContainer.loadPersistentStores { description, error in
            
            if let error = error {
                fatalError("Failed to init core data with error, \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            Debug.log(message: "Failed to save entity in core data with error: ", variable: error.localizedDescription)
        }
    }
    
    func delete(_ record: CoreDataRecord) {
        
        viewContext.delete(record as! NSManagedObject)
        
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            Debug.log(message: "Failed to delete prop with error:", variable: error.localizedDescription)
        }
    }
}
