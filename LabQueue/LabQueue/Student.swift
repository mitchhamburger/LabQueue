//
//  student.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/10/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
@IBDesignable

class Student: NSObject, NSCoding {
    
    var name: String
    var netID: String
    var helpMessage: String
    var beenHelped: Bool
    var canceled: Bool
    var inQueue: Bool
    var requestTime: String
    var helpedTime: String
    var attendingTA: String
    var course: String
    var placeInQueue: Int
    
    init(name: String, helpMessage: String, course: String) {
        self.name = name
        netID = ""
        self.helpMessage = helpMessage
        beenHelped = true
        canceled = true
        inQueue = true
        requestTime = ""
        helpedTime = ""
        attendingTA = ""
        self.course = course
        placeInQueue = 0
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let helpMessage = aDecoder.decodeObjectForKey("helpMessage") as! String
        let course = aDecoder.decodeObjectForKey("course") as! String
        self.init(name: name, helpMessage: helpMessage, course: course)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(helpMessage, forKey: "helpMessage")
        aCoder.encodeObject(course, forKey: "course")
    }
    
}