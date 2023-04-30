//
//  TrackersDataProvider.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//

import UIKit
import CoreData

protocol TrackersDataProviderDelegate: AnyObject {
    
}

protocol TrackersDataProviderProtocol {
    
}

final class TrackersDataProvider: NSObject {
    enum TrackersDataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: TrackersDataProviderDelegate?
    
    private var context: NSManagedObjectContext
    
    private let trackerDataStore: TrackerDataStore
    private let trackerRecordDataStore: TrackerRecordDataStore
    private let trackerCategoryDataStore: TrackerCategoryDataStore
    
    private var insertedIndexes: IndexSet?
    
    init(delegate: TrackersDataProviderDelegate) throws {
        do {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            let container = try appDelegate.getPersistentContainer()
            let viewContext = container.viewContext
            
            self.context = viewContext
            self.trackerDataStore = TrackerDataStore(context: context, container: container)
            self.trackerRecordDataStore = TrackerRecordDataStore(context: context, container: container)
            self.trackerCategoryDataStore = TrackerCategoryDataStore(context: context, container: container)
        } catch {
            throw error
        }
        
        self.delegate = delegate
    }
}
