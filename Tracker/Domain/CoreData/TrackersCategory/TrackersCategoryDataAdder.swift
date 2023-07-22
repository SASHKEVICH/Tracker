//
//  TrackersCategoryDataAdder.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//
import CoreData
import Foundation

protocol TrackersCategoryDataAdderProtocol {
    func add(category: TrackerCategory) throws
}

struct TrackersCategoryDataAdder {
    private let context: NSManagedObjectContext
    private let trackersCategoryDataStore: TrackersCategoryDataStore
    private let trackersCategoryFactory: TrackersCategoryFactory

    init(
        trackersCategoryDataStore: TrackersCategoryDataStore,
        trackersCategoryFactory: TrackersCategoryFactory
    ) {
        self.trackersCategoryDataStore = trackersCategoryDataStore
        self.trackersCategoryFactory = trackersCategoryFactory
        context = trackersCategoryDataStore.managedObjectContext
    }
}

// MARK: - TrackersCategoryDataAdderProtocol

extension TrackersCategoryDataAdder: TrackersCategoryDataAdderProtocol {
    func add(category: TrackerCategory) throws {
        let categoryCoreData = trackersCategoryFactory.makeCategoryCoreData(from: category, context: context)
        try trackersCategoryDataStore.add(category: categoryCoreData)
    }
}
