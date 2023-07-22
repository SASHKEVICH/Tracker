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
        case filter
        case onboarding
    }

    var buttonState: TrackerCustomButton.State {
        didSet {
            setNeededButtonState()
        }
    }

    private var title: String

    init(state: TrackerCustomButton.State, title: String) {
        buttonState = state
        self.title = title
        super.init(frame: .zero)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = 16
        layer.masksToBounds = true

        setNeededButtonState()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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
        case .filter:
            setFilterState()
        case .onboarding:
            setOnboardingState()
        }
    }

    func setCancelState() {
        isEnabled = true

        let border = CAShapeLayer()
        border.frame = bounds

        let color = UIColor.Static.red
        border.strokeColor = color.cgColor
        border.lineWidth = 1
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.addSublayer(border)

        let font = UIFont.Medium.big
        setAttributedButtonTitle(with: color, font: font)
    }

    func setNormalState() {
        isEnabled = true
        layer.backgroundColor = UIColor.Dynamic.blackDay.cgColor

        let font = UIFont.Medium.big
        setAttributedButtonTitle(with: .Dynamic.whiteDay, font: font)
    }

    func setDisabledState() {
        isEnabled = false
        layer.backgroundColor = UIColor.Static.gray.cgColor

        let font = UIFont.Medium.big
        setAttributedButtonTitle(with: .white, font: font)
    }

    func setFilterState() {
        layer.backgroundColor = UIColor.Static.blue.cgColor

        let font = UIFont.Regular.medium
        setAttributedButtonTitle(with: .white, font: font)
    }

    func setOnboardingState() {
        isEnabled = true
        layer.backgroundColor = UIColor.Static.black.cgColor

        let font = UIFont.Medium.big
        setAttributedButtonTitle(with: .white, font: font)
    }

    func setAttributedButtonTitle(with color: UIColor, font: UIFont) {
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [NSAttributedString.Key.font: font,
                         NSAttributedString.Key.foregroundColor: color]
        )
        setAttributedTitle(attributedTitle, for: .normal)
    }
}
