//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Александр Бекренев on 26.04.2023.
//

import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: ColorsCollectionViewCell.self)
    
    private let colorView = UIView()
    private let borderLayer = CALayer()
    
    var color: UIColor? {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColorView()
        addSelectionBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ColorsCollectionViewCell {
    func setupColorView() {
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 6
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
        ])
    }
    
    func addSelectionBorder() {
        borderLayer.cornerRadius = 8
        borderLayer.borderColor = UIColor.trackerBlackDay.withAlphaComponent(0.5).cgColor
        borderLayer.borderWidth = 3
        
        layer.addSublayer(borderLayer)
    }
    
    func removeSelectionBorder() {
        borderLayer.removeFromSuperlayer()
    }
}
