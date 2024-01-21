import UIKit

final class BaseLabel: UILabel {
    convenience init() {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
