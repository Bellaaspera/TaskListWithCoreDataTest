//
//  StorageManager.swift
//  TaskListWithCoreDataTest
//
//  Created by Светлана Сенаторова on 26.04.2023.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "TaskListWithCoreDataTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}
    
    
    func fetch() -> [Task] {
        let context = persistentContainer.viewContext
        let fetchRequest = Task.fetchRequest()
        var tasks: [Task] = []
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        return tasks
    }
    
   func save() {
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
    
    func delete(task: Task) {
        let context = persistentContainer.viewContext
        context.delete(task)
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
}
