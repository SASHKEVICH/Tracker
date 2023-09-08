import UIKit

extension UIView {
    static func loadView() -> Self {
        self.init(frame: UIScreen().bounds)
    }
}
