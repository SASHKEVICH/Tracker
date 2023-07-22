//
//  TrackerCustomTextField.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

final class TrackerCustomTextField: UITextField {
    private enum Padding {
        static let insets: UIEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 40)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: Padding.insets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: Padding.insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: Padding.insets)
    }
}

private extension TrackerCustomTextField {
    func setupTextField() {
        textColor = .Dynamic.blackDay
        backgroundColor = .Dynamic.backgroundDay

        layer.cornerRadius = 16
        layer.masksToBounds = true

        font = .Regular.medium

        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.Static.gray]
            )
        }
    }
}
