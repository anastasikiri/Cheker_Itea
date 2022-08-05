//
//  MainTabBarController.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-20.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class MainTabBarController: UITabBarController {
    
    let loginVC = LoginViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true

        let topline = CALayer()
        topline.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.width, height: 2)
        topline.backgroundColor = UIColor.systemGray.cgColor
        self.tabBar.layer.addSublayer(topline)
       
        popupMenuLogout()
    }
    
    func popupMenuLogout() {
        let menuHandler: UIActionHandler = { action in
            self.navigationController?.popToRootViewController(animated: true)
            self.loginVC.loginManager.logOut()
            GIDSignIn.sharedInstance.signOut()
            LoginStatusManager.shared.loginStatus = .off
        }
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Logout", comment: ""),
                     image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                     handler: menuHandler)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "",
            image: .actions,
            primaryAction: nil,
            menu: barButtonMenu)
    }
}





