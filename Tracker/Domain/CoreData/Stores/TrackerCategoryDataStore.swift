//
//  TrackerCategoryDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

final class TrackerCategoryDataStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    init(container: NSPersistentContainer) {
        self.container = container
        self.context = container.viewContext
        
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

extension TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }
    func add(newCategory: TrackerCategory) throws {
        try performSync { context in
            Result {
                let category = TrackerCategoryCoreData(context: context)
                category.id = UUID().uuidString
                category.title = newCategory.title
                newCategory.trackers.forEach {
                    let trackerCoreData = TrackerCoreData(context: context)
                    trackerCoreData.id = $0.id.uuidString
                    trackerCoreData.title = $0.title
                    trackerCoreData.colorHex = UIColorMarshalling.serilizeToHex(color: $0.color)
                    trackerCoreData.emoji = $0.emoji
                    trackerCoreData.type = Int16($0.type.rawValue)
                    
                    let schedule = $0.schedule?.reduce("") { $0 + "," + $1.englishStringRepresentation }
                    trackerCoreData.weekDays = schedule
                    
                    category.addToTrackers(trackerCoreData)
                }
                try context.save()
            }
        }
    }
    
    func delete(_ record: NSManagedObject) throws {
        try performSync { context in
            Result {
                context.delete(record)
                try context.save()
            }
        }
    }
}

