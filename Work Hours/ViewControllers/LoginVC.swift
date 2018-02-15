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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TimeReportsVCSegue" {
            if let timeReportsVC = segue.destination as? TimeReportsVC {
                timeReportsVC.user = sender as! User
            }
            
        }
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
            
            if password.count > 6 {
                AuthManager.instance.createNewAccount(newEmail: email, newPassword: password, handler: { (user, error) in
                    if let error = error {
                        if error.localizedDescription == "The email address is already in use by another account." {
                            AuthManager.instance.signInUser(email: email, password: password, handler: { (user, error) in
                                if let error = error {
                                    print(error)
                                } else {
                                    self.performSegue(withIdentifier: "TimeReportsVCSegue", sender: user)
                                }
                                
                            })
                        } else {
                            self.showAlert(messageForUser: error.localizedDescription)
                        }
                    } else {
                        AuthManager.instance.signInUser(email: email, password: password, handler: { (user, error) in
                            if let error = error {
                                print(error)
                            } else {
                                self.performSegue(withIdentifier: "TimeReportsVCSegue", sender: user)
                            }
                            
                        })
                    }
                })
                
                
//                AuthManager.instance.signInUser(email: email, password: password, handler: { (user, error) in
//                    if let error = error {
//                        self.showAlert(messageForUser: error.localizedDescription)
//                        print(error.localizedDescription)
//                    } else {
//                        print("It worked")
//                    }
//                })
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
    
    func showAlert(messageForUser message: String) {
        let alertVC = UIAlertController(title: NSLocalizedString("Information", comment: "Information"), message: NSLocalizedString(message, comment: message), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
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
