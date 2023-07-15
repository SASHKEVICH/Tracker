//
//  Date+WeekDay.swift
//  Tracker
//
//  Created by Александр Бекренев on 20.04.2023.
//

import Foundation

let dateTimeDefaultFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .none
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter
}()

extension Date {
    var weekDay: WeekDay? {
        let weekDay = Calendar.current.component(.weekday, from: self)
        switch weekDay {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return nil
        }
    }
    
    func isDayEqualTo(_ otherDate: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: otherDate, toGranularity: .day)
    }
    
    var withoutTime: Date? {
		let calender = Calendar.current
		var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
		dateComponents.timeZone = NSTimeZone.system
		return calender.date(from: dateComponents)
    }
}
