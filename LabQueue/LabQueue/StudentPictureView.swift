//
//  StudentPictureView.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/7/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
@IBDesignable

class StudentPictureView: UIView {

    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.blackColor().setStroke()
        path.stroke()
        
    }
}