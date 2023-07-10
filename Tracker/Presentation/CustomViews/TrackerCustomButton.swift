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
			setNeededButtonState()
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
        
        setNeededButtonState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TrackerCustomButton {
    func setNeededButtonState() {
        switch buttonState {
        case .cancel:
            setCancelState()
        case .normal:
            setNormalState()
        case .disabled:
            setDisabledState()
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
        
        setAttributedButtonTitle()
        setTitleColor(color, for: .normal)
    }
    
    func setNormalState() {
        self.isEnabled = true
		layer.backgroundColor = UIColor.Dynamic.blackDay.cgColor
        
        setAttributedButtonTitle()
		setTitleColor(.Dynamic.whiteDay, for: .normal)
    }
    
    func setDisabledState() {
        self.isEnabled = false
		layer.backgroundColor = UIColor.Static.gray.cgColor
        
        setAttributedButtonTitle()
        setTitleColor(.Dynamic.whiteDay, for: .normal)
    }
    
    func setAttributedButtonTitle() {
		let font = UIFont.Medium.big
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [NSAttributedString.Key.font: font])
        setAttributedTitle(attributedTitle, for: .normal)
    }
}
