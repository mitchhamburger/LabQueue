//
//  LabTA.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/11/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//
//  LabTA data type

import UIKit

/// LabTA data type
///
/// Attributes:
/// * name: first name of Lab TA
/// * netID: netid of Lab TA
/// * classYear: class year of Lab TA
/// * isActive: whether or not the Lab TA is currently active
@IBDesignable class LabTA {
    
    var name: String
    var netID: String
    var classYear: Int
    var isActive: Bool
    
    init() {
        name = ""
        netID = ""
        classYear = 0
        isActive = true
    }
}
