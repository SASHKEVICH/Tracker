//
//  WeekDay.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import Foundation

public enum WeekDay: Int, Comparable, CaseIterable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var fullStringRepresentaion: String {
        let localizable = R.string.localizable
        switch self {
        case .monday: return localizable.weekDayMonday()
        case .tuesday: return localizable.weekDayTuesday()
        case .wednesday: return localizable.weekDayWednesday()
        case .thursday: return localizable.weekDayThursday()
        case .friday: return localizable.weekDayFriday()
        case .saturday: return localizable.weekDaySaturday()
        case .sunday: return localizable.weekDaySunday()
        }
    }

    var shortStringRepresentaion: String {
        let localizable = R.string.localizable
        switch self {
        case .monday: return localizable.weekDayMondayShort()
        case .tuesday: return localizable.weekDayTuesdayShort()
        case .wednesday: return localizable.weekDayWednesdayShort()
        case .thursday: return localizable.weekDayThursdayShort()
        case .friday: return localizable.weekDayFridayShort()
        case .saturday: return localizable.weekDaySaturdayShort()
        case .sunday: return localizable.weekDaySundayShort()
        }
    }

    var englishStringRepresentation: String {
        switch self {
        case .monday: return "monday"
        case .tuesday: return "tuesday"
        case .wednesday: return "wednesday"
        case .thursday: return "thursday"
        case .friday: return "friday"
        case .saturday: return "saturday"
        case .sunday: return "sunday"
        }
    }

    public static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
