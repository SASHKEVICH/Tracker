import Foundation

struct CategoryDTO {
    let id: UUID
    let title: String
    let trackers: [Tracker]
    let isPinning: Bool

    func toDomain() -> Category {
        .init(
            id: self.id,
            title: self.title,
            trackers: self.trackers,
            isPinning: self.isPinning
        )
    }
}
