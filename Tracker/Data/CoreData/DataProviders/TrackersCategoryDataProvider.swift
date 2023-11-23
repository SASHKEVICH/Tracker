//
//  TrackersCategoryDataProvider.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import CoreData
import Foundation

public protocol TrackersCategoryDataProviderDelegate: AnyObject {
    func storeDidUpdate()
}

public protocol TrackersCategoryDataProviderProtocol {
    var delegate: TrackersCategoryDataProviderDelegate? { get set }
    var categories: [TrackerCategoryCoreData] { get }
    func numberOfItemsInSection(_ section: Int) -> Int
}

final class TrackersCategoryDataProvider: NSObject {
    weak var delegate: TrackersCategoryDataProviderDelegate?

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: TrackerCategoryCoreData.entityName)
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true)]
        request.sortDescriptors = sortDescriptors
        request.predicate = nil

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
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

// MARK: - TrackersCategoryDataProviderProtocol

extension TrackersCategoryDataProvider: TrackersCategoryDataProviderProtocol {
    var categories: [TrackerCategoryCoreData] {
        self.fetchedResultsController.fetchedObjects ?? []
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackersCategoryDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.storeDidUpdate()
    }
}
