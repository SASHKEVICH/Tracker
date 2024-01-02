//
//  AlertActionModel.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.07.2023.
//

import UIKit

struct AlertActionModel {
    let title: String?
    let style: UIAlertAction.Style
    let completion: ((UIAlertAction) -> Void)?
}
