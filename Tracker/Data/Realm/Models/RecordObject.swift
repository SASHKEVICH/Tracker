import Foundation
import RealmSwift

final class RecordObject: Object, Identifiable {

    @Persisted(primaryKey: true) var id: UUID
    @Persisted var date: Date
    @Persisted var tracker: TrackerObject
}
