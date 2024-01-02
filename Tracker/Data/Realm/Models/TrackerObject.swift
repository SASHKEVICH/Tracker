import Foundation
import RealmSwift

final class TrackerObject: Object, Identifiable {

    @Persisted(primaryKey: true) var id: UUID
    @Persisted var hexColor: String
    @Persisted var emoji: String
    @Persisted var title: String
    @Persisted var previousCategoryId: CategoryObject.ID
    @Persisted var type: TrackerTypeObject
    @Persisted var weekDays: List<WeekdayObject>

    func toDomain() -> Tracker {
        .init(
            id: self.id,
            previousCategoryId: self.previousCategoryId,
            type: Tracker.TrackerType(rawValue: self.type.rawValue) ?? .tracker,
            title: self.title,
            color: self.hexColor,
            emoji: self.emoji,
            schedule: self.weekDays.compactMap { WeekDay(rawValue: $0.rawValue) }
        )
    }
}

enum WeekdayObject: Int, PersistableEnum {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

enum TrackerTypeObject: String, PersistableEnum {
    case tracker
    case regularEvent
}
