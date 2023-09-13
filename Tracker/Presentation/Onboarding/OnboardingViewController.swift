import UIKit

// MARK: - OnboardingViewController
final class OnboardingViewController<View: OnboardingView>: BaseViewController<View> {
    var onEndOnboarding: VoidAction?
    var pages: [UIViewController]?

    private let pageViewController = OnboardingPageViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
}

private extension OnboardingViewController {
    func makeOnboardingViewInputData(pageIndex: Int) -> OnboardingView.InputData {
        OnboardingView.InputData(pagesCount: self.pageViewController.pagesCount, currentPage: pageIndex)
    }
}

private extension OnboardingViewController {
    func setup() {
        self.setupPageViewController()
        self.setupView()
        self.addChildren()
        self.setActions()
    }

    func setupPageViewController() {
        if let viewController = self.pageViewController.firstViewController {
            self.pageViewController.setViewControllers(
                [viewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }

        if let pages {
            self.pageViewController.set(pages: pages)
        }
    }

    func setupView() {
        self.rootView.update(with: self.makeOnboardingViewInputData(pageIndex: 0))
    }

    func addChildren() {
        self.addChild(self.pageViewController)
        self.rootView.insertSubview(self.pageViewController.view, at: 0)
        self.pageViewController.view.frame = self.rootView.frame
    }

    func setActions() {
        self.pageViewController.onCurrentPageChanged = { [weak self] index in
            guard let self else { return }
            let inputData = self.makeOnboardingViewInputData(pageIndex: index)
            self.rootView.update(with: inputData)
        }

        self.rootView.action = { [weak self] action in
            if action == .onboardingButtonTapped {
                self?.onEndOnboarding?()
            }
        }
    }
}
