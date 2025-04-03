//
//  CoreDataManager.swift
//  PasswordManager
//
//  Created by chetu on 02/04/25.
//
import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager() 

    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "AccountDetails")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func save() {
        do {
            try context.save()
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
}

