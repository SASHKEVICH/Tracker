//
//  TrackerRecordDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

final class TrackerRecordDataStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext, container: NSPersistentContainer) {
        self.container = container
        self.context = context
    }
}
