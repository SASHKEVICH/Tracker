//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.05.2023.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private let onboardingLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textAlignment = .center
		label.font = .boldSystemFont(ofSize: 32)
		label.textColor = .trackerBlackDay
		return label
	}()
	
	private let constantConfiguration = OnboardingConstants.configuration
	
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
	
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
		addConstraints()
    }
}

private extension OnboardingPageViewController {
	func addSubviews() {
		view.addSubview(imageView)
		view.addSubview(onboardingLabel)
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
