//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import UIKit

final class StatisticsTableViewCell: UITableViewCell, ReuseIdentifying {
    var count: String? {
        didSet {
            self.countLabel.text = self.count
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Bold.big
        label.textColor = .Dynamic.blackDay
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Medium.medium
        label.textColor = .Dynamic.blackDay
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addSubviews()
        self.addConstraints()
        self.configure()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setGradientBorder()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.count = nil
        self.title = nil
    }
}

private extension StatisticsTableViewCell {
    func configure() {
        self.backgroundColor = .Dynamic.whiteDay
        self.containerView.layer.cornerRadius = 16
        self.containerView.layer.masksToBounds = true
    }

    func addSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.countLabel)
        self.containerView.addSubview(self.titleLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
        ])

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            countLabel.heightAnchor.constraint(equalToConstant: 41),
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.countLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),
        ])
    }

    func setGradientBorder() {
        self.containerView.layer.cornerRadius = 16
        self.containerView.clipsToBounds = true

        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: self.containerView.frame.size)
        gradient.colors = [UIColor.Selection.color1.cgColor, UIColor.Selection.color9.cgColor, UIColor.Selection.color3.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        let shape = CAShapeLayer()
        shape.lineWidth = 3
        shape.path = UIBezierPath(roundedRect: self.containerView.bounds, cornerRadius: self.containerView.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor

        gradient.mask = shape

        self.containerView.layer.addSublayer(gradient)
    }
}
