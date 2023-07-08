//
//  TrackersCategoryDataAdder.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//
import Foundation
import CoreData

protocol TrackersCategoryDataAdderProtocol {
	func add(category: TrackerCategory) throws
}

struct TrackersCategoryDataAdder {
	private let context: NSManagedObjectContext
	private let trackersCategoryDataStore: TrackersCategoryDataStore
	private let trackersCategoryFactory: TrackersCategoryFactory

	init(trackersCategoryDataStore: TrackersCategoryDataStore, trackersCategoryFactory: TrackersCategoryFactory) {
		self.trackersCategoryDataStore = trackersCategoryDataStore
		self.trackersCategoryFactory = trackersCategoryFactory
		self.context = trackersCategoryDataStore.managedObjectContext
	}
}

extension TrackersCategoryDataAdder: TrackersCategoryDataAdderProtocol {
	func add(category: TrackerCategory) throws {
		let categoryCoreData = self.trackersCategoryFactory.makeCategoryCoreData(from: category, context: self.context)
		try trackersCategoryDataStore.add(category: categoryCoreData)
	}
}
