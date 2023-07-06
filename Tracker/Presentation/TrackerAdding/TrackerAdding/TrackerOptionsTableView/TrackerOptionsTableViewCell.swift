//
//  TrackerOptionsTableViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

final class TrackerOptionsTableViewCell: UITableViewCell {
	var cellTitle: String? {
		didSet {
			cellTitleLabel.text = cellTitle
			cellTitleLabel.sizeToFit()
		}
	}

	var additionalInfo: String? {
		didSet {
			relayoutCellTitleLabel()
			additionalInfoLabel.text = additionalInfo
			additionalInfoLabel.isHidden = false
		}
	}

	private let cellTitleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .Dynamic.blackDay
		label.font = .Regular.medium
		return label
	}()

	private let additionalInfoLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Regular.medium
		label.textColor = .Static.gray
		label.isHidden = true
		return label
	}()

    private let selectBackgroundView = CellSelectBackgroundView()
    
    private lazy var titleLableTopConstraint = NSLayoutConstraint(
		item: self.cellTitleLabel,
		attribute: .top,
		relatedBy: .equal,
		toItem: self.contentView,
		attribute: .top,
		multiplier: 1,
		constant: 26)

    private lazy var titleLableBottomConstraint = NSLayoutConstraint(
		item: self.cellTitleLabel,
		attribute: .bottom,
		relatedBy: .equal,
		toItem: self.contentView,
		attribute: .bottom,
		multiplier: 1,
		constant: -25)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
		addConstraints()
        configureDefaultCellBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TrackerOptionsTableViewCell {
	func addSubviews() {
		contentView.addSubview(cellTitleLabel)
		contentView.addSubview(additionalInfoLabel)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			cellTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			cellTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56),
			titleLableTopConstraint,
			titleLableBottomConstraint
		])

		NSLayoutConstraint.activate([
			additionalInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			additionalInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56),
			additionalInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 39),
			additionalInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
		])
	}
    
    func configureDefaultCellBackground() {
		backgroundColor = .Dynamic.backgroundDay
        selectedBackgroundView = selectBackgroundView
    }
}

private extension TrackerOptionsTableViewCell {
    func relayoutCellTitleLabel() {
		self.titleLableTopConstraint.constant = 15
		self.titleLableBottomConstraint.constant = -38
		self.layoutIfNeeded()
    }
}
