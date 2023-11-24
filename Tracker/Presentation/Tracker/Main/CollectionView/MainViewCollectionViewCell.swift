import UIKit

final class MainViewCollectionViewCell: UICollectionViewCell {
    weak var delegate: MainViewCollectionHelperCellDelegate?

    var dayCount: String = "" {
        didSet {
            self.dayCountLabel.text = dayCount
        }
    }

    var tracker: OldTrackerEntity? {
        didSet {
            guard let tracker = tracker else { return }
            topContainerView.backgroundColor = tracker.color
            trackerTitleLable.text = tracker.title
            emojiLabel.text = tracker.emoji
            emojiLabel.sizeToFit()
            completeTrackerButton.color = tracker.color
        }
    }

    var isPinned: Bool = false {
        didSet {
            self.pinnedImageView.isHidden = !self.isPinned
        }
    }

    var isCompleted: Bool = false {
        didSet {
            completeTrackerButton.buttonState = self.isCompleted ? .completed : .increase
        }
    }

    private let trackerTitleLable: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = .Medium.medium
        lable.textColor = .white
        lable.contentMode = .bottomLeft
        lable.numberOfLines = 0
        return lable
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Medium.big
        return label
    }()

    private let topContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()

    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var pinnedImageView: UIImageView = {
        let imageView = UIImageView(image: .MainScreen.pinned)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .center
        imageView.isHidden = !self.isPinned
        return imageView
    }()

    private lazy var dayCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Medium.medium
        label.textColor = .Dynamic.blackDay
        return label
    }()

    private lazy var completeTrackerButton: CompleteTrackerButton = {
        let button = CompleteTrackerButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCompleteTrackerButton), for: .touchUpInside)
        return button
    }()

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        self.addSubviews()
        self.addConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        self.dayCount = ""
        self.completeTrackerButton.buttonState = .increase
    }
}

private extension MainViewCollectionViewCell {
    func addSubviews() {
        contentView.addSubview(topContainerView)

        topContainerView.addSubview(trackerTitleLable)
        topContainerView.addSubview(emojiBackgroundView)
        topContainerView.addSubview(emojiLabel)
        topContainerView.addSubview(pinnedImageView)

        contentView.addSubview(dayCountLabel)
        contentView.addSubview(completeTrackerButton)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 90)
        ])

        NSLayoutConstraint.activate([
            trackerTitleLable.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            trackerTitleLable.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            trackerTitleLable.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 44),
            trackerTitleLable.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            dayCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            dayCountLabel.widthAnchor.constraint(equalToConstant: 118),
            dayCountLabel.heightAnchor.constraint(equalToConstant: 18)
        ])

        NSLayoutConstraint.activate([
            completeTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeTrackerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completeTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.heightAnchor.constraint(equalToConstant: 34)
        ])

        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24)
        ])

        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            pinnedImageView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 18),
            pinnedImageView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12)
        ])
    }
}

// MARK: - Callbacks

private extension MainViewCollectionViewCell {
    @objc
    func didTapCompleteTrackerButton() {
        self.delegate?.didTapCompleteCellButton(self)
    }
}
