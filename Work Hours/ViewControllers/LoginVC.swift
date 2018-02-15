//
//  LoginVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var emailTxf: UITextField!
    @IBOutlet weak var passwordTxf: UITextField!
    
    
    // MARK: - Application runtime
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        // Setup dynamic background (horizontally)
        setMotion()
    }
    
    
    // MARK: - Rotations
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation == .portrait {
            setMotion()
        } else {
            for effect in backgroundImageView.motionEffects {
                backgroundImageView.removeMotionEffect(effect)
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if emailTxf.text != "" && passwordTxf.text != ""  {
            guard let typedInEmail = emailTxf.text,
                let password = passwordTxf.text
                else {
                    showAlert(messageForUser: "Something went wrong, please try again.")
                    return
            }
            var email = typedInEmail.lowercased()
            email = email.trimmingCharacters(in: .whitespaces)
            
            if password.count >= 6 {
                AuthManager.shared.createNewAccount(newEmail: email, newPassword: password, handler: { (user, error) in
                    if let error = error {
                        if error.localizedDescription == "The email address is already in use by another account." {
                            AuthManager.shared.signInUser(email: email, password: password, handler: { (user, error) in
                                if let error = error {
                                    print(error)
                                } else {
                                    self.performSegue(withIdentifier: "TimeReportsVCSegue", sender: nil)
                                }
                                
                            })
                        } else {
                            self.showAlert(messageForUser: error.localizedDescription)
                        }
                    } else {
                        AuthManager.shared.signInUser(email: email, password: password, handler: { (user, error) in
                            if let error = error {
                                print(error)
                            } else {
                                self.performSegue(withIdentifier: "TimeReportsVCSegue", sender: nil)
                            }
                            
                        })
                    }
                })
            } else {
                showAlert(messageForUser: "Password needs to be at least 6 characters long")
            }
        } else {
            showAlert(messageForUser: "You have to fill both fields if you wish to log in.")
        }
    }
    
    
    // MARK: - Functions
    
    func setMotion() {
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -100
        horizontalMotionEffect.maximumRelativeValue = 100
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect]
        backgroundImageView.addMotionEffect(motionEffectGroup)
    }
    
    // MARK: - Textfield delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            passwordTxf.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
