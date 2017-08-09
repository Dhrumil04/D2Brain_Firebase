//
//  DesignableButton.swift
//  D2Brain
//
//  Created by Purvang Shah on 25/07/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var BorderWidth: CGFloat = 0.0 {
        didSet{
            self.layer.borderWidth = BorderWidth
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
}
