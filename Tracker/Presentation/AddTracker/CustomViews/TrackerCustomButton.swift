//
//  TrackerCustomButton.swift
//  Tracker
//
//  Created by Александр Бекренев on 15.04.2023.
//

import UIKit

enum TrackerCustomButtonState {
    case cancel
    case normal
    case disabled
}

final class TrackerCustomButton: UIButton {
    var buttonState: TrackerCustomButtonState {
        didSet {
            setNeededButtonState()
        }
    }
    
    private var title: String
    
    init(state: TrackerCustomButtonState, title: String) {
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
    func setCancelState() {
        self.isEnabled = true
        backgroundColor = .trackerWhiteDay
        
        let border = CAShapeLayer()
        border.frame = self.bounds
        border.strokeColor = UIColor.trackerRed.cgColor
        border.lineWidth = 1
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath
        self.layer.addSublayer(border)
        
        setAttributedButtonTitle()
        setTitleColor(.trackerRed, for: .normal)
    }
    
    func setNormalState() {
        self.isEnabled = true
        layer.backgroundColor = UIColor.trackerBlackDay.cgColor
        
        setAttributedButtonTitle()
        setTitleColor(.trackerWhiteDay, for: .normal)
    }
    
    func setupDisabledState() {
        self.isEnabled = false
        layer.backgroundColor = UIColor.trackerGray.cgColor
        
        setAttributedButtonTitle()
        setTitleColor(.trackerWhiteDay, for: .normal)
    }
    
    func setNeededButtonState() {
        switch buttonState {
        case .cancel:
            setCancelState()
        case .normal:
            setNormalState()
        case .disabled:
            setupDisabledState()
        }
    }
    
    func setAttributedButtonTitle() {
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let mySelectedAttributedTitle =
            NSAttributedString(string: title,
                               attributes: [NSAttributedString.Key.font: font])
        setAttributedTitle(mySelectedAttributedTitle, for: .normal)
    }
}
