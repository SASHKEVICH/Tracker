//
//  UUID+Static.swift
//  Tracker
//
//  Created by Александр Бекренев on 15.07.2023.
//

import Foundation

struct StaticUUID {
	struct FilterCategories {
		static let all = UUID()
		static let today = UUID()
		static let completed = UUID()
		static let incompleted = UUID()
	}
}
