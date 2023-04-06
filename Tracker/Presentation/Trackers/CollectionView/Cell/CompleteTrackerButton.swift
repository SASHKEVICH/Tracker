//
//  CompleteTrackerButton.swift
//  Tracker
//
//  Created by Александр Бекренев on 05.04.2023.
//

import UIKit

final class CompleteTrackerButton: UIButton {
    var isDone: Bool = false
    var color: UIColor? {
        didSet {
            self.backgroundColor = color
        }
    }
    
    override func draw(_ rect: CGRect) {
        setupButton()
    }
}

// MARK: - Setup button appearence and logic
private extension CompleteTrackerButton {
    func setupButton() {
        self.layer.cornerRadius = 17
        self.layer.masksToBounds = true
        self.backgroundColor = color

        imageView?.contentMode = .center
        imageView?.tintColor = .trackerWhiteDay

        isDone ? setTrackerDone() : setTrackerUndone()
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    @objc
    func onPress() {
        isDone.toggle()
        isDone ? setTrackerDone() : setTrackerUndone()
    }
    
    func setTrackerDone() {
        let image = UIImage(systemName: "checkmark")
        setImage(image, for: .normal)
        self.backgroundColor = color?.withAlphaComponent(0.3)
    }
    
    func setTrackerUndone() {
        let image = UIImage(systemName: "plus")
        setImage(image, for: .normal)
        self.backgroundColor = color
    }
}
