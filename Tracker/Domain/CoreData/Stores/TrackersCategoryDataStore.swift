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
    }
}

extension TrackersCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext {
		self.context
    }
    
    func category(with id: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let predicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(TrackerCategoryCoreData.id), id)
        request.predicate = predicate
        request.fetchLimit = 1
        
        let categoriesCoreData = try? context.fetch(request)
        return categoriesCoreData?.first
    }
    
    func add(category: TrackerCategoryCoreData) throws {
		try? self.context.save()
	}
    
    func delete(_ record: NSManagedObject) throws {
        context.delete(record)
        try context.save()
    }
}
