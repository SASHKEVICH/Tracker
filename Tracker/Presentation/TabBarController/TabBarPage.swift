import UIKit

enum TabBarPage {
    case trackers
    case statistics

    init?(index: Int) {
        switch index {
        case 0:
            self = .trackers
        case 1:
            self = .statistics
        default:
            return nil
        }
    }

    var pageTitleValue: String {
        switch self {
        case .trackers:
            return R.string.localizable.tabbarTracker()
        case .statistics:
            return R.string.localizable.tabbarStatistics()
        }
    }

    var pageOrderNumber: Int {
        switch self {
        case .trackers:
            return 0
        case .statistics:
            return 1
        }
    }

    var icon: UIImage? {
        switch self {
        case .trackers:
            return .TabBar.trackers
        case .statistics:
            return .TabBar.statistics
        }
    }
}
