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
    
//MARK: - Core Data Stack
    
    private let context: NSManagedObjectContext
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListWithCoreDataTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {
        context = persistentContainer.viewContext
    }
    
//MARK: - CRUD
    
    func create(taskTitle: String, completion: (Task) -> Void) {
        let task = Task(context: context)
        task.title = taskTitle
        completion(task)
        saveContext()
    }
    
    func fetch(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        do {
            let tasks = try context.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func delete(task: Task) {
        context.delete(task)
        saveContext()
    }
    
    func update(task: Task, with newTitle: String) {
        task.title = newTitle
        saveContext()
    }

//MARK: - Core Data Saving Support
    
    func saveContext() {
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
