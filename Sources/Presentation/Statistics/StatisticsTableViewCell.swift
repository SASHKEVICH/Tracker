import UIKit

final class StatisticsTableViewCell: UITableViewCell {

    // MARK: - Types

    struct ViewData {
        let title: String
        let count: String
    }

    // MARK: - Private Properties

    private let containerView: BaseView = {
        let view = BaseView()
        view.layer.cornerRadius = Constants.containerCornerRadius
        view.layer.masksToBounds = true
        return view
    }()

    private let countLabel: BaseLabel = {
        let label = BaseLabel()
        label.font = .Bold.big
        label.textColor = .Dynamic.blackDay
        return label
    }()

    private let titleLabel: BaseLabel = {
        let label = BaseLabel()
        label.font = .Medium.medium
        label.textColor = .Dynamic.blackDay
        return label
    }()
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addSubviews()
        self.addConstraints()
        self.setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setGradientBorder()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.countLabel.text = nil
        self.titleLabel.text = nil
    }

    // MARK: - Internal Methods

    func configure(viewData: ViewData) {
        self.countLabel.text = viewData.count
        self.titleLabel.text = viewData.title
    }
}

// MARK: - Private methods

private extension StatisticsTableViewCell {

    enum Constants {
        static let containerCornerRadius: CGFloat = 16
        static let containerTopOffset: CGFloat = 12
        static let containerSideSpacing: CGFloat = 16
        static let containerHeight: CGFloat = 90

        static let countLabelTopOffset: CGFloat = 12
        static let countLabelSideSpacing: CGFloat = 12
        static let countLabelHeight: CGFloat = 41

        static let titleLabelTopOffset: CGFloat = 7
        static let titleLabelSideSpacing: CGFloat = 12
        static let titleLabelBottomOffset: CGFloat = 12
    }

    func setup() {
        self.backgroundColor = .Dynamic.whiteDay
        //        self.containerView.layer.cornerRadius = Constants.containerCornerRadius
        //        self.containerView.layer.masksToBounds = true
    }

    func addSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.countLabel)
        self.containerView.addSubview(self.titleLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: self.contentView.topAnchor,
                constant: Constants.containerTopOffset
            ),
            containerView.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor,
                constant: Constants.containerSideSpacing
            ),
            containerView.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor,
                constant: -Constants.containerSideSpacing
            ),
            containerView.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor
            ),
            containerView.heightAnchor.constraint(
                equalToConstant: Constants.containerHeight
            )
        ])

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(
                equalTo: self.containerView.topAnchor,
                constant: Constants.countLabelTopOffset
            ),
            countLabel.leadingAnchor.constraint(
                equalTo: self.containerView.leadingAnchor,
                constant: Constants.countLabelSideSpacing
            ),
            countLabel.trailingAnchor.constraint(
                equalTo: self.containerView.trailingAnchor,
                constant: -Constants.countLabelSideSpacing
            ),
            countLabel.heightAnchor.constraint(
                equalToConstant: Constants.countLabelHeight
            )
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: self.countLabel.bottomAnchor,
                constant: Constants.titleLabelTopOffset
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: self.containerView.leadingAnchor,
                constant: Constants.titleLabelSideSpacing
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: self.containerView.trailingAnchor,
                constant: -Constants.titleLabelSideSpacing
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor,
                constant: -Constants.titleLabelBottomOffset
            )
        ])
    }
}

// MARK: - Gradient

private extension StatisticsTableViewCell {

    func setGradientBorder() {
        self.containerView.layer.cornerRadius = Constants.containerCornerRadius
        self.containerView.clipsToBounds = true

        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: self.containerView.frame.size)

        gradient.colors = [
            UIColor.Selection.color1.cgColor,
            UIColor.Selection.color9.cgColor,
            UIColor.Selection.color3.cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        let shape = CAShapeLayer()
        shape.lineWidth = 3
        shape.path = UIBezierPath(
            roundedRect: self.containerView.bounds,
            cornerRadius: self.containerView.layer.cornerRadius
        ).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor

        gradient.mask = shape

        self.containerView.layer.addSublayer(gradient)
    }
}
