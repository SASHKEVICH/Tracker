//
//  TrackerScheduleTableViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 18.04.2023.
//

import UIKit

final class TrackerScheduleTableViewCell: UITableViewCell {
    weak var delegate: TrackerScheduleTableViewHelperDelegateProtocol?
    var weekDay: WeekDay?

    var cellTitle: String? {
        didSet {
            cellTitleLabel.text = cellTitle
            cellTitleLabel.sizeToFit()
        }
    }

    var isDaySwitchOn: Bool {
        get { daySwitch.isOn }
        set {
            daySwitch.isOn = newValue
        }
    }

    private let cellTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .Dynamic.blackDay
        label.font = .Regular.medium
        return label
    }()

    private let selectBackgroundView = CellSelectBackgroundView()

    private lazy var daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.onTintColor = .Static.switchBackground
        daySwitch.addTarget(self, action: #selector(didChangeSwitchValue), for: .valueChanged)
        return daySwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellTitleLabel()
        setupDefaultCellBackground()
        setupDaySwitch()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TrackerScheduleTableViewCell {
    func setupCellTitleLabel() {
        contentView.addSubview(cellTitleLabel)

        NSLayoutConstraint.activate([
            cellTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -41),
            cellTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
            cellTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),
        ])
    }

    func setupDaySwitch() {
        contentView.addSubview(daySwitch)

        NSLayoutConstraint.activate([
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func setupDefaultCellBackground() {
        backgroundColor = .Dynamic.backgroundDay
        selectedBackgroundView = selectBackgroundView
    }
}

private extension TrackerScheduleTableViewCell {
    @objc
    func didChangeSwitchValue(_ sender: UISwitch) {
        delegate?.didChangeSwitchValue(self, isOn: sender.isOn)
    }
}
