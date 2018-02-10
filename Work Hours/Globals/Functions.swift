//
//  Functions.swift
//  Work Hours
//
//  Created by Giovanni Palusa on 2018-02-10.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import Foundation
import UIKit

// This function pulsates
func pulsate(view : UIView) {
    let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
    pulseAnimation.duration = 1
    pulseAnimation.fromValue = 0.5
    pulseAnimation.toValue = 1
    pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    pulseAnimation.autoreverses = true
    pulseAnimation.repeatCount = .greatestFiniteMagnitude
    view.layer.add(pulseAnimation, forKey: "animateOpacity")
}
