//
//  AuthManager.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import Foundation
import Firebase

class AuthManager {
    static var instance = AuthManager()
    
    func createNewAccount(newEmail email: String, newPassword password: String, handler: @escaping (_ newUser: User?, _ error: Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                handler(nil, error)
            }
            
            if let user = user {
                handler(user, nil)
            }
        }
    }
    
    func signInUser(email: String, password: String, handler: @escaping (_ newUser: User?, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                handler(nil, error)
            }
            if let user = user {
                handler(user, nil)
            }
        }
    }
    
    func logOutUser(handler: @escaping (_ success: Bool) -> ()) {
        do {
            try Auth.auth().signOut()
        } catch {
            handler(false)
        }
        handler(true)
    }
    
    
    
}
