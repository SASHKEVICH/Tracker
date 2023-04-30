//
//  AlertPresenterService.swift
//  Tracker
//
//  Created by Александр Бекренев on 12.04.2023.
//

import UIKit

protocol AlertPresenterServiceDelegate: AnyObject {
    func didRecieve(alert: UIAlertController)
}

protocol AlertPresenterSerivceProtocol {
    var delegate: AlertPresenterServiceDelegate? { get set }
    func requestAlert(_ alertModel: AlertModel)
}

struct AlertPresenterService: AlertPresenterSerivceProtocol {
    weak var delegate: AlertPresenterServiceDelegate?
    
    func requestAlert(_ alertModel: AlertModel) {
        guard let delegate = delegate else { return }
        let alertController = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        guard let titles = alertModel.actionTitles else {
            delegate.didRecieve(alert: alertController)
            return
        }
        
        for (index, title) in titles.enumerated() {
            let handler = alertModel.completions?[safe: index]
            let action = UIAlertAction(title: title, style: .default, handler: handler)
            action.accessibilityIdentifier = title
            alertController.addAction(action)
        }
        delegate.didRecieve(alert: alertController)
    }
}
