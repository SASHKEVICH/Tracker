//
//  TrackersCollectionSectionHeader.swift
//  Tracker
//
//  Created by Александр Бекренев on 05.04.2023.
//

import UIKit

final class TrackersCollectionSectionHeader: UICollectionReusableView {
    private let headerLabel = UILabel()
    
    static let identifier = String(describing: TrackersCollectionSectionHeader.self)
    
    var headerText: String? {
        didSet {
            headerLabel.text = headerText
            headerLabel.sizeToFit()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeaderLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension TrackersCollectionSectionHeader {
    func setupHeaderLabel() {
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
        
        headerLabel.font = UIFont.boldSystemFont(ofSize: 19)
    }
}
