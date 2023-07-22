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
            switch buttonState {
            case .completed:
                setTrackerDone()
            case .increase:
                setTrackerCountIncrease()
            case .decrease:
                setTrackerCountDecrease()
            }
        }
    }

    var color: UIColor? {
        didSet {
            self.backgroundColor = self.color
        }
    }

    override func draw(_: CGRect) {
        setupButton()
    }
}

// MARK: - Setup button appearence and logic

private extension CompleteTrackerButton {
    func setupButton() {
        layer.cornerRadius = 17
        layer.masksToBounds = true
        backgroundColor = color

        imageView?.contentMode = .center
        imageView?.tintColor = .Dynamic.whiteDay
    }

    func setTrackerDone() {
        let image = UIImage.CompleteTrackerButton.completed
        setImage(image, for: .normal)
        backgroundColor = color
        alpha = 0.3
    }

    func setTrackerCountIncrease() {
        let image = UIImage.CompleteTrackerButton.increase
        setImage(image, for: .normal)
        backgroundColor = color
        alpha = 1
    }

    func setTrackerCountDecrease() {
        let image = UIImage.CompleteTrackerButton.decrease
        setImage(image, for: .normal)
        backgroundColor = color
        alpha = 1
    }
}
