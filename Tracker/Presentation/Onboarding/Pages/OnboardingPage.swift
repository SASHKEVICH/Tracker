import UIKit

final class OnboardingPage: UIViewController {
    struct InputData {
        let image: UIImage?
        let onboardingText: String
    }

    enum Index {
        case first
        case second
    }

    private enum Constants {
        static let onboardingLabelSideInset: CGFloat = 16
    }

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

    private let constantConfiguration = OnboardingConstants.configuration

    init(inputData: InputData) {
        self.imageView.image = inputData.image
        self.onboardingLabel.text = inputData.onboardingText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSubviews()
        self.addConstraints()
    }
}

private extension OnboardingPage {
    func addSubviews() {
        self.view.addSubview(imageView)
        self.view.addSubview(onboardingLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.onboardingLabel.topAnchor.constraint(
                equalTo: self.view.topAnchor,
                constant: constantConfiguration.topConstantConstraint
            ),
            self.onboardingLabel.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor,
                constant: -constantConfiguration.bottomConstantConstraint
            ),
            self.onboardingLabel.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: Constants.onboardingLabelSideInset
            ),
            self.onboardingLabel.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -Constants.onboardingLabelSideInset
            ),
        ])
    }
}
