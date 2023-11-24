import Foundation

public struct Tracker {
    public enum TrackerType: String {
        case tracker
        case regularEvent
    }

    let id: UUID
    let previousCategoryId: UUID
    let type: TrackerType
    let title: String
    let color: String
    let emoji: String
    let schedule: [WeekDay]
}
