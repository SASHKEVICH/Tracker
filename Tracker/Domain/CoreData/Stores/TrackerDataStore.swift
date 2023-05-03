//
//  TrackerDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

final class TrackerDataStore {
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

extension TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }
    }
}
