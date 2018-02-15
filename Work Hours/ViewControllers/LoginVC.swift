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
        
        // Setup dynamic background (horizontally)
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -300
        horizontalMotionEffect.maximumRelativeValue = 300
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect]
        backgroundImageView.addMotionEffect(motionEffectGroup)
        
        hideKeyboardWhenTappedAround()

    }
    
    // MARK: - IBActions
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        // Check authentication
    }
    
    // MARK: - Functions
    
    

}