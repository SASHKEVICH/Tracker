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
}

enum WeekdayObject: String, PersistableEnum {
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
