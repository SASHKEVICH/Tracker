//
//  CellReusingUtils.swift
//  Tracker
//
//  Created by Aleksandr Bekrenev on 28.08.2023.
//

import UIKit

protocol ReuseIdentifying {
    static var defaultReuseIdentifier: String { get }
}

extension ReuseIdentifying where Self: UITableViewCell {
    static var defaultReuseIdentifier: String {
        NSStringFromClass(self).components(separatedBy: ".").last ?? NSStringFromClass(self)
    }
}

extension ReuseIdentifying where Self: UICollectionViewCell {
    static var defaultReuseIdentifier: String {
        NSStringFromClass(self).components(separatedBy: ".").last ?? NSStringFromClass(self)
    }
}

protocol ReusableCollecectionViewIdentifying: ReuseIdentifying {
    static var kind: String { get }
}

extension ReusableCollecectionViewIdentifying where Self: UICollectionReusableView {
    static var defaultReuseIdentifier: String {
        NSStringFromClass(self).components(separatedBy: ".").last ?? NSStringFromClass(self)
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: ReuseIdentifying {
        self.register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: ReuseIdentifying {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            assertionFailure("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
            return T()
        }
        return cell
    }

    func cellForRow<T: UITableViewCell>(indexPath: IndexPath) -> T where T: ReuseIdentifying {
        guard let cell = self.cellForRow(at: indexPath) as? T else {
            assertionFailure("Could not get cell with type: \(T.self)")
            return T()
        }
        return cell
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReuseIdentifying {
        self.register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }

    func register<T: UICollectionReusableView>(_: T.Type) where T: ReusableCollecectionViewIdentifying {
        self.register(T.self, forSupplementaryViewOfKind: T.kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: ReuseIdentifying {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            assertionFailure("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier) for: \(indexPath)")
            return T()
        }
        return cell
    }

    func cellForItem<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: ReuseIdentifying {
        guard let cell = self.cellForItem(at: indexPath) as? T else {
            assertionFailure("Could not get cell with type: \(T.self)")
            return T()
        }
        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        indexPath: IndexPath
    ) -> T where T: ReusableCollecectionViewIdentifying {
        guard let view = self.dequeueReusableSupplementaryView(
            ofKind: T.kind,
            withReuseIdentifier: T.defaultReuseIdentifier,
            for: indexPath
        ) as? T else {
            assertionFailure("Could not get supplementary view with type: \(T.self)")
            return T()
        }

        return view
    }
}
