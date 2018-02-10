//
//  Buttons.swift
//  Work Hours
//
//  Created by Giovanni Palusa on 2018-02-10.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class outlinedButton: UIButton {
    
    @IBInspectable open var shadowing: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var contouring: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 7 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable open var borderColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if contouring {
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor.cgColor
            layer.cornerRadius = cornerRadius
        }
        
        if shadowing {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize.zero
            layer.shadowRadius = 10
            layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
            layer.shouldRasterize = true
        }
    }
}














