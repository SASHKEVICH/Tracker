//
//  UIFont+Extensions.swift
//  Tracker
//
//  Created by Александр Бекренев on 05.07.2023.
//

import UIKit

extension UIFont {
	struct Bold {
		static let big = UIFont.boldSystemFont(ofSize: 34)
		static let medium = UIFont.boldSystemFont(ofSize: 32)
		static let small = UIFont.boldSystemFont(ofSize: 19)
	}

	struct Regular {
		static let medium = UIFont.systemFont(ofSize: 17, weight: .regular)
	}

	struct Medium {
		static let big = UIFont.systemFont(ofSize: 16, weight: .medium)
		static let medium = UIFont.systemFont(ofSize: 12, weight: .medium)
		static let small = UIFont.systemFont(ofSize: 10, weight: .medium)
	}
}
