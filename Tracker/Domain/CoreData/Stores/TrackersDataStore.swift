//
//  TrackersDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

struct TrackersDataStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackersDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }
    
    func add(tracker: TrackerCoreData, in category: TrackerCategoryCoreData) throws {
        category.addToTrackers(tracker)
        try context.save()
    }
}
