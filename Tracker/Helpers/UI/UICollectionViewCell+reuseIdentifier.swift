//
//  UICollectionViewCell+reuseIdentifier.swift
//  Tracker
//
//  Created by Александр Бекренев on 05.07.2023.
//

import UIKit

extension UICollectionViewCell {
	static var reuseIdentifier: String {
		String(describing: Self.self)
	}
}
