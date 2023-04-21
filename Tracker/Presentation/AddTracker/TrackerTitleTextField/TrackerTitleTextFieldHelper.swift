//
//  TrackerTitleTextFieldHelper.swift
//  Tracker
//
//  Created by Александр Бекренев on 17.04.2023.
//

import UIKit

protocol TrackerTitleTextFieldHelperProtocol: UITextFieldDelegate {
    var presenter: AddTrackerViewPresenterProtocol? { get set }
}

final class TrackerTitleTextFieldHelper: NSObject, TrackerTitleTextFieldHelperProtocol {
    weak var presenter: AddTrackerViewPresenterProtocol?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}
