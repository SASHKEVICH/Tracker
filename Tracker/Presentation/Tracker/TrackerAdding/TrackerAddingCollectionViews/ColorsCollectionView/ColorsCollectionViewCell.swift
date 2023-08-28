//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 26.04.2023.
//

import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    var color: UIColor? {
        didSet {
            self.colorView.backgroundColor = color
            self.borderView.layer.borderColor = color?.withAlphaComponent(0.4).cgColor
        }
    }

    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 3
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.addConstraints()
        self.setupSelectionBorder()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ColorsCollectionViewCell {
    func addSubviews() {
        self.contentView.addSubview(colorView)
    }

    func addConstraints() {
        let padding: CGFloat = 6
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
        ])
    }

    func setupSelectionBorder() {
        selectedBackgroundView = self.borderView
    }
}
