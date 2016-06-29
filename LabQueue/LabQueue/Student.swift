//
//  student.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/10/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//
//  Student data type

import UIKit

/// Student data type
///
/// Attributes:
/// * name: name of student
/// * netID: netid of student
/// * helpMessage: student's help message
/// * beenHelped: has the student been helped?
/// * canceled: was the request canceled?
/// * inQueue: is the stuednt in the queue?
/// * requestTime: time that the request was made
/// * helpedTime: time that the student was helped
/// * attendingTA: TA that helped the student
/// * course: course that the student is in
/// * placeInQueue: place in line
@IBDesignable class Student: NSObject, NSCoding {
    
    var name: String
    var netID: String
    var helpMessage: String
    var course: String
    var placeInQueue: Int
    
    init(name: String, helpMessage: String, course: String, netid: String) {
        self.name = name
        netID = netid
        self.helpMessage = helpMessage
        self.course = course
        placeInQueue = 0
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let helpMessage = aDecoder.decodeObjectForKey("helpMessage") as! String
        let course = aDecoder.decodeObjectForKey("course") as! String
        self.init(name: name, helpMessage: helpMessage, course: course, netid: "")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(helpMessage, forKey: "helpMessage")
        aCoder.encodeObject(course, forKey: "course")
    }
    
}