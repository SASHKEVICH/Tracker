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
    func requestDeleteTrackerAlert(completion: @escaping (UIAlertAction) -> Void)
}

// MARK: - AlertPresenterService

final class AlertPresenterService {
    weak var delegate: AlertPresenterServiceDelegate?
    private let localizable = R.string.localizable
}

// MARK: - AlertPresenterSerivceProtocol

extension AlertPresenterService: AlertPresenterSerivceProtocol {
    func requestChosenFutureDateAlert() {
        let title = localizable.alertChosenFutureDateTitle()
        let message = localizable.alertChosenFutureDateMessage()
        let actionTitle = localizable.alertChosenFutureDateActionOk()

        let actionModel = AlertActionModel(title: actionTitle, style: .default, completion: nil)
        let model = AlertModel(title: title, message: message, actions: [actionModel])
        requestAlert(with: model, prefferedStyle: .alert)
    }

    func requestDeleteTrackerAlert(completion: @escaping (UIAlertAction) -> Void) {
        let deleteActionTitle = localizable.alertDeleteTrackerActionDelete()
        let deleteActionModel = AlertActionModel(title: deleteActionTitle, style: .destructive, completion: completion)

        let cancelActionTitle = localizable.alertDeleteTrackerActionCancel()
        let cancelActionModel = AlertActionModel(title: cancelActionTitle, style: .cancel, completion: nil)

        let message = localizable.alertDeleteTrackerMessage()
        let model = AlertModel(title: nil, message: message, actions: [deleteActionModel, cancelActionModel])
        requestAlert(with: model, prefferedStyle: .actionSheet)
    }
}

private extension AlertPresenterService {
    func requestAlert(with alertModel: AlertModel, prefferedStyle: UIAlertController.Style) {
        guard let delegate = delegate else { return }
        let alertController = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: prefferedStyle
        )

        guard let actions = alertModel.actions else {
            delegate.didRecieve(alert: alertController)
            return
        }

        actions.forEach { actionModel in
            let action = UIAlertAction(title: actionModel.title, style: actionModel.style, handler: actionModel.completion)
            action.accessibilityIdentifier = action.title
            alertController.addAction(action)
        }

        delegate.didRecieve(alert: alertController)
    }
}
