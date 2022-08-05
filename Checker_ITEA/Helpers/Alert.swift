//
//  Alert.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-28.
//

import Foundation

import UIKit

class Alert {
    static func showBasicWithTimer(title: String,
                                   message:String,
                                   vc: UIViewController,
                                   color: UIColor) {
        let alert = UIAlertController (title: title,
                                       message: message,
                                       preferredStyle: .alert)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = color
        vc.present(alert,animated: true)
        
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true)
        }
    }
    static func showBasic(title: String,
                          vc: UIViewController) {
        let alert = UIAlertController (title: title,
                                       message: nil,
                                       preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "Ok",
            style: .default)
        alert.addAction(okAction)
        vc.present(alert,animated: true)
    }
}
