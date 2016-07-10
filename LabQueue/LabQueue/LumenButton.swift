//
//  LumenButton.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/10/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

@IBDesignable class LumenButton: UIButton {

    @IBInspectable var mainColor: UIColor = UIColor.blueColor()
    @IBInspectable var borderColor: UIColor = UIColor.redColor()
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        super.layer.backgroundColor = mainColor.CGColor
        let bottomBorder = UIView(frame: CGRect(x: 0, y: super.frame.size.height - 4, width: super.frame.size.width, height: 3))
        bottomBorder.layer.backgroundColor = borderColor.CGColor
        bottomBorder.layer.cornerRadius = 5
        super.addSubview(bottomBorder)
        super.layer.cornerRadius = 5
        
        self.addTarget(self, action: #selector(LumenButton.pushed), forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: #selector(LumenButton.unpushed), forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: #selector(LumenButton.unpushed), forControlEvents: UIControlEvents.TouchUpOutside)
    }
    func pushed() {
        super.layer.backgroundColor = borderColor.CGColor
    }
    func unpushed() {
        super.layer.backgroundColor = mainColor.CGColor
    }
}
