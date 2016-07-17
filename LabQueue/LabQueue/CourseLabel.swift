//
//  CourseLabel.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/16/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

@IBDesignable class CourseLabel: UILabel {
    
    @IBInspectable var color: UIColor = UIColor.lightGrayColor()
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.layer.cornerRadius = 4
        self.backgroundColor = color
    }
}
