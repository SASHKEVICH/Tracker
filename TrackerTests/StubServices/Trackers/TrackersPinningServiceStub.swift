//
//  TrackersPinningServiceStub.swift
//  TrackerTests
//
//  Created by Александр Бекренев on 17.07.2023.
//

import Foundation
import Tracker

final class TrackersPinningServiceStub {}

// MARK: - TrackersPinningServiceProtocol

extension TrackersPinningServiceStub: TrackersPinningServiceProtocol {
    func pin(tracker _: Tracker) {}
    func unpin(tracker _: Tracker) {}
}
