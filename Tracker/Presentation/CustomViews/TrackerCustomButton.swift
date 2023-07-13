//
//  TrackerCustomButton.swift
//  Tracker
//
//  Created by Александр Бекренев on 15.04.2023.
//

import UIKit

final class TrackerCustomButton: UIButton {
	enum State {
		case cancel
		case normal
		case disabled
	}

	var buttonState: TrackerCustomButton.State {
		didSet {
			self.setNeededButtonState()
		}
	}
	
    private var title: String
    
	init(state: TrackerCustomButton.State, title: String) {
        self.buttonState = state
        self.title = title
        super.init(frame: .zero)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
		self.setNeededButtonState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TrackerCustomButton {
    func setNeededButtonState() {
		switch self.buttonState {
        case .cancel:
			self.setCancelState()
        case .normal:
			self.setNormalState()
        case .disabled:
			self.setDisabledState()
        }
    }
    
    func setCancelState() {
        self.isEnabled = true
        
        let border = CAShapeLayer()
        border.frame = self.bounds

		let color = UIColor.Static.red
		border.strokeColor = color.cgColor
        border.lineWidth = 1
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath
        self.layer.addSublayer(border)
        
		self.setAttributedButtonTitle(with: color)
    }
    
    func setNormalState() {
        self.isEnabled = true
		self.layer.backgroundColor = UIColor.Dynamic.blackDay.cgColor
        
		self.setAttributedButtonTitle(with: .Dynamic.whiteDay)
    }
    
    func setDisabledState() {
        self.isEnabled = false
		self.layer.backgroundColor = UIColor.Static.gray.cgColor
        
		self.setAttributedButtonTitle(with: .white)
    }
    
	func setAttributedButtonTitle(with color: UIColor) {
		let font = UIFont.Medium.big
        let attributedTitle = NSAttributedString(
            string: title,
			attributes: [NSAttributedString.Key.font: font,
						 NSAttributedString.Key.foregroundColor: color])
		self.setAttributedTitle(attributedTitle, for: .normal)
    }
}
