import UIKit

protocol TitleTextFieldHelperProtocol: UITextFieldDelegate {}

final class TitleTextFieldHelper: NSObject {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}

// MARK: - TitleTextFieldHelperProtocol

extension TitleTextFieldHelper: TitleTextFieldHelperProtocol {}
