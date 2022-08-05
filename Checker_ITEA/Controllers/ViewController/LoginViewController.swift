//
//  LoginViewController.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-31.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailViewOutlet: UIView!
    @IBOutlet weak var passwordViewOutlet: UIView!
    @IBOutlet weak var emailField: UITextField!    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var loginVisibilityOutlet: UIButton!
    
    let loginManager = LoginManager()
    
    let signInConfig = GIDConfiguration(
        clientID: "813565878218-c2c437splgqfbtjg4u8f2sf0vaeje349.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        emailField.delegate = self
        passwordField.delegate = self
        loginButtonOutlet.layer.cornerRadius = 10
        loginVisibilityOutlet.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 16), forImageIn: .normal)
        
        emailViewOutlet.layer.cornerRadius = 10
        emailViewOutlet.layer.borderWidth = 2
        emailViewOutlet.layer.borderColor = #colorLiteral(red: 0.6352941176, green: 0.6352941176, blue: 0.6509803922, alpha: 1)
        
        passwordViewOutlet.layer.cornerRadius = 10
        passwordViewOutlet.layer.borderWidth = 2
        passwordViewOutlet.layer.borderColor = #colorLiteral(red: 0.6352941176, green: 0.6352941176, blue: 0.6509803922, alpha: 1)
        
        if let token = AccessToken.current, !token.isExpired {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        if GIDSignIn.sharedInstance.currentUser != nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController
            self.navigationController?.pushViewController(vc!, animated: true)
        }

        if LoginStatusManager.shared.loginStatus == .on {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           if textField.returnKeyType == .next {
               if  emailField.text?.isEmpty == true {
                   Alert.showBasic(
                    title: "Please enter your email address",
                    vc: self)
                   return false
               } else {
                       emailField.resignFirstResponder()
                       passwordField.becomeFirstResponder()
                   }
           } else if textField.returnKeyType == .go {
               if passwordField.text?.isEmpty == true {
                   Alert.showBasic(
                    title: "Please enter your password or click forgot password",
                    vc: self)
                   return false
               } else if passwordField.text?.count ?? 0 < 6  {
                   Alert.showBasic(
                    title: "Password must be minimum 6 symbols",
                    vc: self)
                   passwordField.text = ""
                   return false
               } else {
                   passwordField.resignFirstResponder()
                   LoginStatusManager.shared.loginStatus = .on
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController
                   self.navigationController?.pushViewController(vc!, animated: true)
                   emailField.text = ""
                   passwordField.text = ""
               }
           }
           return true
       }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToMainTabBar" {
            if  emailField.text?.isEmpty == true {
                Alert.showBasic(
                    title: "Please enter your email address",
                    vc: self)
                return false
            } else if passwordField.text?.isEmpty == true {
                Alert.showBasic(
                    title: "Please enter your password or click forgot password",
                    vc: self)
                return false
            } else if passwordField.text?.count ?? 0 < 6  {
                Alert.showBasic(
                    title: "Password must be minimum 6 symbols",
                    vc: self)
                passwordField.text = ""
                return false
            }
            LoginStatusManager.shared.loginStatus = .on
            emailField.text = ""
            passwordField.text = ""
            return true
        }
        return true
    }
    
    @IBAction func facebookLoginButton(_ sender: UIButton) {
        loginManager.logIn(permissions: ["public_profile"], from: self) { result, error in
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController
                self.navigationController?.pushViewController(vc!, animated: true)
                print("Logged In")
            }
        }
    }
    
    @IBAction func googleLoginButton(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func passwordVisibilityButton(_ sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        if passwordField.isSecureTextEntry {
            if let image = UIImage(systemName: "eye.slash.fill") {
                sender.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(systemName: "eye.fill") {
                sender.setImage(image, for: .normal)
            }
        }
    }    
}

