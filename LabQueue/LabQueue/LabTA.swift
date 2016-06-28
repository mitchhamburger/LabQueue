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
/// * firstName: first name of Lab TA
/// * lastName: last name of Lab TA
/// * email: email address of Lab TA
/// * classYear: class year of Lab TA
/// * isActive: whether or not the Lab TA is currently active
@IBDesignable class LabTA {
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var classYear: Int?
    var isActive: Bool?
    
    init() {
        firstName = nil
        lastName = nil
        email = nil
        classYear = nil
        isActive = nil
    }
}
