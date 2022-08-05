//
//  LoginManager.swift
//  
//
//  Created by Anastasia Bilous on 2022-08-02.
//

import Foundation

enum LoginStatus: Int {
    case off
    case on
}

final class LoginStatusManager {
    
    static let shared = LoginStatusManager()
    
    var loginStatus: LoginStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "status")
        }
        get {
            LoginStatus(rawValue: UserDefaults.standard.integer(forKey: "status")) ?? .off
        }
    }
}
