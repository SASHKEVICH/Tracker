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
	func requestChosenFutureDateAlert()
}

// MARK: - AlertPresenterService
struct AlertPresenterService {
    weak var delegate: AlertPresenterServiceDelegate?
	private let localizable = R.string.localizable
}

// MARK: - AlertPresenterSerivceProtocol
extension AlertPresenterService: AlertPresenterSerivceProtocol {
	func requestChosenFutureDateAlert() {
		let title = self.localizable.alertChosenFutureDateTitle()
		let message = self.localizable.alertChosenFutureDateMessage()
		let actionTitle = self.localizable.alertChosenFutureDateActionOk()

		let model = AlertModel(title: title, message: message, actionTitles: [actionTitle])
		self.requestAlert(with: model, prefferedStyle: .alert)
	}
}

private extension AlertPresenterService {
	func requestAlert(with alertModel: AlertModel, prefferedStyle: UIAlertController.Style) {
		guard let delegate = self.delegate else { return }
		let alertController = UIAlertController(
			title: alertModel.title,
			message: alertModel.message,
			preferredStyle: prefferedStyle
		)

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
