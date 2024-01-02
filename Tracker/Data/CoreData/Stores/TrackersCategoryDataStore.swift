//
//  TrackersCategoryDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import CoreData
import Foundation

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

    func category(for tracker: OldTrackerEntity) -> TrackerCategoryCoreData? {
        let trackerRequest = TrackerCoreData.fetchRequest()
        let trackerPredicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(TrackerCoreData.id), tracker.id.uuidString)
        trackerRequest.predicate = trackerPredicate
        trackerRequest.fetchLimit = 1

        guard let object = try? self.context.fetch(trackerRequest),
              let trackerCoreData = object.first
        else { return nil }

        return self.category(with: trackerCoreData.category.id)
    }

    func category(with id: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(TrackerCategoryCoreData.id), id)
        request.predicate = predicate
        request.fetchLimit = 1

        do {
            let categoriesCoreData = try context.fetch(request)
            return categoriesCoreData.first
        } catch {
            assertionFailure("Cannot get category with id: \(id)")
            return nil
        }
    }

    func rename(category: TrackerCategoryCoreData, newTitle: String) {
        category.title = newTitle
        do {
            try context.save()
        } catch {
            assertionFailure("Cannot rename categor")
            print(error)
        }
    }

    func add(category _: TrackerCategoryCoreData) throws {
        try? self.context.save()
    }

    func delete(_ record: NSManagedObject) throws {
        context.delete(record)
        try context.save()
    }
}
