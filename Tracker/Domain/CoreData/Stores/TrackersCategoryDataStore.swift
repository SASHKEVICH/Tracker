//
//  TrackersCategoryDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

struct TrackersCategoryDataStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        checkCategoryExistence()
    }
}

extension TrackersCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }
    
    func category(with name: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let predicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(TrackerCategoryCoreData.title), name)
        request.predicate = predicate
        request.fetchLimit = 1
        
        let categoriesCoreData = try? context.fetch(request)
        return categoriesCoreData?.first
    }
    
    func add(newCategory: TrackerCategory) throws {}
    
    func delete(_ record: NSManagedObject) throws {
        context.delete(record)
        try context.save()
    }
}

private extension TrackersCategoryDataStore {
    func checkCategoryExistence() {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let count = try? context.count(for: request)
        
        if let count = count, count == 0 {
            createDefaultCategory()
        }
    }
    
    func createDefaultCategory() {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.id = UUID().uuidString
        trackerCategoryCoreData.title = "Категория 1"
        trackerCategoryCoreData.trackers = NSSet()
        try? context.save()
    }
}
