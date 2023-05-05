//
//  String+WeekDay.swift
//  Tracker
//
//  Created by Александр Бекренев on 01.05.2023.
//

import Foundation

extension String {
    var weekDay: WeekDay? {
        switch self {
        case "monday":
            return .monday
        case "tuesday":
            return .tuesday
        case "wednesday":
            return .wednesday
        case "thursday":
            return .thursday
        case "friday":
            return .friday
        case "saturday":
            return .saturday
        case "sunday":
            return .sunday
        default:
            return nil
        }
    }
}
