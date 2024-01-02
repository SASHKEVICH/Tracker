import UIKit

final class OnboardingSinglePageViewController: UIViewController {

    struct ViewData {
        let image: UIImage?
        let text: String
    }

    // MARK: - Private properties

    private let constantConfiguration = OnboardingConstants.configuration

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let onboardingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .Bold.medium
        label.textColor = .Static.black
        return label
    }()

    // MARK: - Init

    init(viewData: ViewData) {
        self.imageView.image = viewData.image
        self.onboardingLabel.text = viewData.text

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSubviews()
        self.addConstraints()
    }
}

private extension OnboardingSinglePageViewController {

    enum Constants {
        static let labelHorizontalSpacing: CGFloat = 16
    }

    func addSubviews() {
        self.view.addSubview(imageView)
        self.view.addSubview(onboardingLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            onboardingLabel.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: constantConfiguration.topConstantConstraint
            ),
            onboardingLabel.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -constantConfiguration.bottomConstantConstraint
            ),
            onboardingLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.labelHorizontalSpacing
            ),
            onboardingLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.labelHorizontalSpacing
            )
        ])
    }
}
