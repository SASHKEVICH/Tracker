//
//  StatisticsTableViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.07.2023.
//

import UIKit

final class StatisticsTableViewCell: UITableViewCell {
    var count: String? {
        didSet {
            countLabel.text = count
        }
    }

    var title: String? {
        didSet {
            titleLabel.text = title
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

        addSubviews()
        addConstraints()
        configure()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setGradientBorder()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        count = nil
        title = nil
    }
}

private extension StatisticsTableViewCell {
    func configure() {
        backgroundColor = .Dynamic.whiteDay
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
    }

    func addSubviews() {
        contentView.addSubview(containerView)

        containerView.addSubview(countLabel)
        containerView.addSubview(titleLabel)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
        ])

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            countLabel.heightAnchor.constraint(equalToConstant: 41),
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func setGradientBorder() {
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true

        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: containerView.frame.size)
        gradient.colors = [UIColor.Selection.color1.cgColor, UIColor.Selection.color9.cgColor, UIColor.Selection.color3.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        let shape = CAShapeLayer()
        shape.lineWidth = 3
        shape.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor

        gradient.mask = shape

        containerView.layer.addSublayer(gradient)
    }
}
