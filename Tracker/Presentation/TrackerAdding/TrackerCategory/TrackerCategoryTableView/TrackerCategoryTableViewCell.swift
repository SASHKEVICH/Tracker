//
//  TrackerCategoryTableViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 19.06.2023.
//

import UIKit

final class TrackerCategoryTableViewCell: UITableViewCell {
	var categoryTitle: String? {
		didSet {
			categoryTitleLable.text = categoryTitle
		}
	}

	var isCellSelected: Bool = false {
		didSet {
			selectedCellImageView.isHidden = !isCellSelected
		}
	}
	
	private let categoryTitleLable: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Regular.medium
		label.textAlignment = .left
		label.numberOfLines = 0
		return label
	}()

	private let selectedCellImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.image = .Categories.selected
		imageView.isHidden = true
		return imageView
	}()
	
	private let selectBackgroundView = CellSelectBackgroundView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		addSubviews()
		addConstraints()

		selectedBackgroundView = selectBackgroundView
		backgroundColor = .Dynamic.backgroundDay
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		self.categoryTitle = ""
		self.isCellSelected = false
	}
}

private extension TrackerCategoryTableViewCell {
	func addSubviews() {
		contentView.addSubview(categoryTitleLable)
		contentView.addSubview(selectedCellImageView)
	}
	
	func addConstraints() {
		NSLayoutConstraint.activate([
			categoryTitleLable.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
			categoryTitleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			categoryTitleLable.trailingAnchor.constraint(equalTo: selectedCellImageView.leadingAnchor),
			categoryTitleLable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),
		])

		NSLayoutConstraint.activate([
			selectedCellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			selectedCellImageView.widthAnchor.constraint(equalToConstant: 24),
			selectedCellImageView.heightAnchor.constraint(equalToConstant: 24),
			selectedCellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
}
