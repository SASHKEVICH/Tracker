import Foundation

public struct Category: Equatable {
    public static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID
    let title: String
    let trackers: [Tracker]
    let isPinning: Bool
}
