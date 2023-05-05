//
//  WeekDay.swift
//  Tracker
//
//  Created by Александр Бекренев on 03.04.2023.
//

import Foundation

enum WeekDay: Int, Comparable, CaseIterable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var fullStringRepresentaion: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortStringRepresentaion: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
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
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
