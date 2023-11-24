import UIKit

public struct OldTrackerEntity {
    public enum TrackerType: Int {
        case tracker = 1
        case irregularEvent = 2
    }

    let id: UUID
    let previousCategoryId: UUID
    let type: TrackerType
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    let isPinned: Bool
}
