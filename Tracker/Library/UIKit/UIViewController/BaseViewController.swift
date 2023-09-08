import UIKit

class BaseViewController<View: UIView>: UIViewController {
    typealias OnBackButtonTap = () -> Void

    var rootView: View { self.view as! View }
    var onBackButtonTap: OnBackButtonTap?

    override func loadView() {
        self.view = View.loadView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            self.onBackButtonTap?()
        }
    }
}
