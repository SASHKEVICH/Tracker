//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 26.04.2023.
//

import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell {
	var color: UIColor? {
		didSet {
			colorView.backgroundColor = color
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
		view.layer.borderColor = UIColor.Dynamic.blackDay.withAlphaComponent(0.4).cgColor
		view.layer.borderWidth = 3
		return view
	}()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColorView()
        setupSelectionBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ColorsCollectionViewCell {
    func setupColorView() {
        contentView.addSubview(colorView)
        
        let padding: CGFloat = 6
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
        ])
    }
    
    func setupSelectionBorder() {
        selectedBackgroundView = borderView
    }
    
}
