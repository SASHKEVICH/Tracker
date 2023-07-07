//
//  TrackerPlaceholderView.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import UIKit

final class TrackerPlaceholderView: UIView {
	enum State {
		case emptyTrackersForDay
		case emptyTrackersSearch
		case emptyCategories
	}

	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let textLabel: UILabel = {
		let textLabel = UILabel()
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.font = .Medium.medium
		textLabel.textColor = .Dynamic.blackDay
		textLabel.textAlignment = .center
		textLabel.numberOfLines = 0
		return textLabel
	}()

	private var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}

	private var text: String? {
		didSet {
			textLabel.text = text
		}
	}

	init() {
		super.init(frame: .zero)
		self.addSubviews()
		self.addConstraints()
	}
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension TrackerPlaceholderView {
	func set(state: TrackerPlaceholderView.State) {
		switch state {
		case .emptyTrackersForDay:
			self.set(image: .Placeholder.emptyForDay, text: "Что будем отслеживать?")
		case .emptyTrackersSearch:
			self.set(image: .Placeholder.emptySearch, text: "Ничего не найдено")
		case .emptyCategories:
			self.set(image: .Placeholder.emptyForDay, text: "Привычки и события можно \n объединить по смыслу")
		}
	}

	func set(image: UIImage?, text: String?) {
		self.image = image
		self.text = text
	}
}

private extension TrackerPlaceholderView {
	func addSubviews() {
		self.addSubview(imageView)
		self.addSubview(textLabel)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			self.imageView.widthAnchor.constraint(equalToConstant: 80),
			self.imageView.heightAnchor.constraint(equalToConstant: 80),
			self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
		])

		NSLayoutConstraint.activate([
			self.textLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8),
			self.textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
			self.textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
		])
	}
}
