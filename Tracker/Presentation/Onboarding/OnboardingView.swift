import UIKit

protocol OnboardingViewProtocol: UIView {
    var action: Action<OnboardingView.Event>? { get set }
    func update(with inputData: OnboardingView.InputData)
}

final class OnboardingView: UIView, OnboardingViewProtocol {
    struct InputData {
        let pagesCount: Int
        let currentPage: Int
    }

    enum Event {
        case onboardingButtonTapped
    }

    private enum Constants {
        static let onboardingButtonSideInset: CGFloat = 20
        static let onboardingButtonBottomInset: CGFloat = 50
        static let onboardingButtonHeight: CGFloat = 60

        static let pageControlBottomInset: CGFloat = 24
        static let pageControlHeight: CGFloat = 6
    }

    var action: Action<Event>?

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .Static.black
        pageControl.pageIndicatorTintColor = .Static.black.withAlphaComponent(0.3)
        return pageControl
    }()

    private lazy var onboardingButton: TrackerCustomButton = {
        let buttonTitle = R.string.localizable.onboardingButtonTitle()
        let button = TrackerCustomButton(state: .onboarding, title: buttonTitle)
        button.addTarget(self, action: #selector(self.didTapOnboardingButton(_:)), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.addConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with inputData: InputData) {
        self.pageControl.numberOfPages = inputData.pagesCount
        self.pageControl.currentPage = inputData.currentPage
    }
}

private extension OnboardingView {
    func addSubviews() {
        self.addSubview(self.onboardingButton)
        self.addSubview(self.pageControl)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            self.onboardingButton.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: Constants.onboardingButtonSideInset
            ),
            self.onboardingButton.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -Constants.onboardingButtonSideInset
            ),
            self.onboardingButton.bottomAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.onboardingButtonBottomInset
            ),
            self.onboardingButton.heightAnchor.constraint(equalToConstant: Constants.onboardingButtonHeight),
        ])

        NSLayoutConstraint.activate([
            self.pageControl.bottomAnchor.constraint(
                equalTo: self.onboardingButton.topAnchor,
                constant: -Constants.pageControlBottomInset
            ),
            self.pageControl.heightAnchor.constraint(equalToConstant: Constants.pageControlHeight),
            self.pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
}

// MARK: - Actions
private extension OnboardingView {
    @objc
    func didTapOnboardingButton(_ sender: UIButton) {
        self.action?(.onboardingButtonTapped)
    }
}
