//
//  CompleteTrackerButton.swift
//  Tracker
//
//  Created by Александр Бекренев on 05.04.2023.
//

import UIKit

final class CompleteTrackerButton: UIButton {
	enum State {
		case completed
		case increase
		case decrease
	}

	var buttonState: State = .increase {
		didSet {
			switch self.buttonState {
			case .completed:
				self.setTrackerDone()
			case .increase:
				self.setTrackerCountIncrease()
			case .decrease:
				self.setTrackerCountDecrease()
			}
		}
	}
    
    var color: UIColor? {
        didSet {
			self.backgroundColor = self.color
        }
    }
    
    override func draw(_ rect: CGRect) {
		self.setupButton()
    }
}

// MARK: - Setup button appearence and logic
private extension CompleteTrackerButton {
    func setupButton() {
        self.layer.cornerRadius = 17
        self.layer.masksToBounds = true
		self.backgroundColor = self.color

		self.imageView?.contentMode = .center
		self.imageView?.tintColor = .Dynamic.whiteDay
    }
    
    func setTrackerDone() {
		let image = UIImage.CompleteTrackerButton.completed
		self.setImage(image, for: .normal)
		self.backgroundColor = self.color
		self.alpha = 0.3
    }
    
    func setTrackerCountIncrease() {
        let image = UIImage.CompleteTrackerButton.increase
		self.setImage(image, for: .normal)
		self.backgroundColor = self.color
		self.alpha = 1
    }

	func setTrackerCountDecrease() {
		let image = UIImage.CompleteTrackerButton.decrease
		self.setImage(image, for: .normal)
		self.backgroundColor = self.color
		self.alpha = 1
	}
}
