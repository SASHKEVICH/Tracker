//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.05.2023.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}

	var onboardingText: String? {
		didSet {
			onboardingLabel.text = onboardingText
		}
	}

	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	private let onboardingLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textAlignment = .center
		label.font = .Bold.medium
		label.textColor = .Static.black
		return label
	}()

	private let constantConfiguration = OnboardingConstants.configuration

    override func viewDidLoad() {
        super.viewDidLoad()

		self.addSubviews()
		self.addConstraints()
    }
}

private extension OnboardingPageViewController {
	func addSubviews() {
		self.view.addSubview(imageView)
		self.view.addSubview(onboardingLabel)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: view.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])

		NSLayoutConstraint.activate([
			onboardingLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: constantConfiguration.topConstantConstraint),
			onboardingLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constantConfiguration.bottomConstantConstraint),
			onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])
	}
}
