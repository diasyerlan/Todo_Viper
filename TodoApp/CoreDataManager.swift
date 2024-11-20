////
////  CoreDataManager.swift
////  TodoApp
////
////  Created by Dias Yerlan on 20.11.2024.
////
//
//import Foundation
//import CoreData
//
//class CoreDataManager {
//    static let shared = CoreDataManager()
//    
//    private init() {}
//    
//    var context: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "TodoApp")
//        container.loadPersistentStores { storeDescription, error in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        return container
//    }()
//    
//    func saveTodoToCoreData(todo: Todo) {
//        let context = CoreDataManager.shared.context
//        _ = todo.toTodoEntity(in: context)
//        
//        do {
//            try context.save()
//        } catch {
//            print("Error saving todo: \(error.localizedDescription)")
//        }
//    }
//
//    
//    func fetchTodos() -> [Todo] {
//        let fetchRequest: NSFetchRequest<TodoModel> = TodoModel.fetchRequest()
//        
//        do {
//            let results = try CoreDataManager.shared.context.fetch(fetchRequest)
//            // Map TodoEntity to Todo
//            return results.map { Todo.fromTodoEntity($0) }
//        } catch {
//            print("Error fetching todos: \(error.localizedDescription)")
//            return []
//        }
//    }
//
//
//}
