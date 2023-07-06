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
	
	var isCellSelected: Bool = true {
		didSet {
			selectedCellImageView.isHidden = !isCellSelected
		}
	}
	
	private let categoryTitleLable = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Regular.medium
		label.textAlignment = .left
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
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension TrackerCategoryTableViewCell {
	func addSubviews() {
		addSubview(categoryTitleLable)
		addSubview(selectedCellImageView)
	}
	
	func addConstraints() {
		NSLayoutConstraint.activate([
			categoryTitleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			categoryTitleLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			categoryTitleLable.heightAnchor.constraint(equalToConstant: 22),
			categoryTitleLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])

		NSLayoutConstraint.activate([
			selectedCellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			selectedCellImageView.widthAnchor.constraint(equalToConstant: 24),
			selectedCellImageView.heightAnchor.constraint(equalToConstant: 24),
			selectedCellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
}
