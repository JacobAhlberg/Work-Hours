//
//  LoginVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
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
        // Check authentication
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
    

}
