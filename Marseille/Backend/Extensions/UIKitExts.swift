//
//  UIKitExts.swift
//  Marseille
//
//  Created by Serena on 15/01/2023
//
	

import UIKit

extension UIViewController {
    /// Display an alert with a title, message, and given actions.
    func errorAlert(title: String,
                    message: String?,
                    actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .cancel)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        present(alert, animated: true)
    }
}

extension UILabel {
    /// A convenince initializer to setup a ``UILabel``
    /// with given text, font, and textColor.
    convenience init(text: String?, font: UIFont? = nil, textColor: UIColor? = nil) {
        self.init(frame: .zero)
        self.text = text
        self.font = font ?? self.font
        self.textColor = textColor ?? self.textColor
    }
}


extension UIColor {
    static let borderedButtonColor = UIColor(
        red: 0.0392157, green:  0.517647, blue: 1, alpha: 0.25
    )
    
    static let borderedProminentButtonColor = UIColor(
        red: 0.231373, green: 0.614118, blue: 1, alpha: 1
    )
}

extension UIUserInterfaceStyle {
    var tagDescription: String {
        switch self {
        case .light:
            return "light"
        default:
            return "dark"
        }
    }
}
