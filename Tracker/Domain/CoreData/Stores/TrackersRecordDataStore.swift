//
//  TrackersRecordDataStore.swift
//  Tracker
//
//  Created by Александр Бекренев on 29.04.2023.
//

import Foundation
import CoreData

struct TrackersRecordDataStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackersRecordDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }
    
    func completeTracker(with id: String, date: Date) throws {
        guard let date = date.onlyDate else { return }
        let record = TrackerRecordCoreData(context: context)
        record.id = id
        record.date = date
        try context.save()
    }
    
    func incompleteTracker(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
    }
    
    func completedTimesCount(trackerId: String) throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.id), trackerId)
        request.predicate = predicate
        request.resultType = .countResultType
        
        let fetchResult = try context.execute(request) as! NSAsynchronousFetchResult<NSFetchRequestResult>
        guard
            let count = fetchResult.finalResult?.first,
            let countInt = count as? Int
        else { return 0 }
        
        return countInt
    }
    
    func completedTrackers(for date: NSDate) -> [TrackerRecordCoreData] {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.date), date)
        request.predicate = predicate
        
        let records = try? context.fetch(request)
        return records ?? []
    }
    
    func record(with id: String, date: NSDate) -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.id), id,
            #keyPath(TrackerRecordCoreData.date), date)
        request.predicate = predicate
        request.fetchLimit = 1
        
        let records = try? context.fetch(request)
        return records?.first
    }
}
