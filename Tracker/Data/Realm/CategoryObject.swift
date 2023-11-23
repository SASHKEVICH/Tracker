import Foundation
import RealmSwift

final class CategoryObject: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var title: String
    @Persisted var trackers: List<TrackerObject>
    @Persisted var isPinning: Bool
}
