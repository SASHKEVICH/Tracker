//
//  TrackersDataProvider.swift
//  Tracker
//
//  Created by Александр Бекренев on 30.04.2023.
//

import Foundation
import CoreData

protocol TrackersDataProviderDelegate: AnyObject {
	func storeDidUpdate()
	func fetchDidPerformed()
}

protocol TrackersDataProviderProtocol {
	var delegate: TrackersDataProviderDelegate? { get set }
    var numberOfSections: Int { get }
	var trackers: [TrackerCoreData] { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func fetchTrackers(currentWeekDay: WeekDay)
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay)
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func categoryTitle(at indexPath: IndexPath) -> String?
}

// MARK: - TrackersDataProvider
final class TrackersDataProvider: NSObject {
	weak var delegate: TrackersDataProviderDelegate?

	private let context: NSManagedObjectContext
	
	private var currentWeekDay = Date().weekDay?.englishStringRepresentation

	private lazy var fetchedResultsController: NSFetchedResultsController = {
		let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
		let sortDescriptors = [
			NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
			NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true)
		]
		request.sortDescriptors = sortDescriptors

		let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.weekDays), currentWeekDay ?? "")
		request.predicate = predicate

		let fetchedResultsController = NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
			cacheName: nil
		)
		fetchedResultsController.delegate = self

		try? fetchedResultsController.performFetch()
		return fetchedResultsController
	}()

	init(context: NSManagedObjectContext) {
		self.context = context
    }
}

// MARK: - TrackersDataProviderProtocol
extension TrackersDataProvider: TrackersDataProviderProtocol {
    var numberOfSections: Int {
		self.fetchedResultsController.sections?.count ?? 0
    }

	var trackers: [TrackerCoreData] {
		self.fetchedResultsController.fetchedObjects ?? []
	}
    
    func numberOfItemsInSection(_ section: Int) -> Int {
		self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func fetchTrackers(currentWeekDay: WeekDay) {
		self.fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation)
		try? self.fetchedResultsController.performFetch()
		self.delegate?.fetchDidPerformed()
    }
    
    func fetchTrackers(titleSearchString: String, currentWeekDay: WeekDay) {
		self.fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.title), titleSearchString,
            #keyPath(TrackerCoreData.weekDays), currentWeekDay.englishStringRepresentation)
		try? self.fetchedResultsController.performFetch()
		self.delegate?.fetchDidPerformed()
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
		self.fetchedResultsController.object(at: indexPath)
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
		let trackerCoreData = self.fetchedResultsController.object(at: indexPath)
        return trackerCoreData.category.title
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersDataProvider: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.delegate?.storeDidUpdate()
	}
}
