//
//  TrackerPlaceholderView.swift
//  Tracker
//
//  Created by Александр Бекренев on 02.04.2023.
//

import UIKit

final class TrackerPlaceholderView: UIView {
	enum State {
		case emptyForDay
		case emptySearch
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
		case .emptyForDay:
			self.set(image: .Placeholder.emptyForDay, text: "Что будем отслеживать?")
		case .emptySearch:
			self.set(image: .Placeholder.emptySearch, text: "Ничего не найдено")
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
			self.textLabel.widthAnchor.constraint(equalToConstant: 343)
		])
	}
}
