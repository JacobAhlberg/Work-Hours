//
//  SpinnerManager.swift
//  Work Hours
//
//  Created by Giovanni Palusa on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import Foundation
import UIKit

class SpinnerManager {
    static let shared = SpinnerManager()
    
    private var window = UIApplication.shared.keyWindow!
    private var backgroundView: UIView
    private var darkView: UIView
    private var spinner: UIActivityIndicatorView
    
    private init() {
        backgroundView = UIView(frame: CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height))
        backgroundView.backgroundColor = .clear
        darkView = UIView(frame: CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height))
        darkView.backgroundColor = .black
        darkView.alpha = 0.5
        spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.color = .white
        spinner.center = backgroundView.center
        
        backgroundView.addSubview(darkView)
        backgroundView.addSubview(spinner)
    }
    
    func startSpinner() {
        spinner.startAnimating()
        window.addSubview(backgroundView)
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
        backgroundView.removeFromSuperview()
    }
}
