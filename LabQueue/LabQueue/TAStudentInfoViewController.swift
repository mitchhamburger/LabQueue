//
//  TAStudentInfoViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/13/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
@IBDesignable

class TAStudentInfoViewController: UIViewController {
    
    @IBOutlet weak var pageTitle: UINavigationItem!
    
    @IBOutlet weak var studentNumber: UILabel!
    
    @IBOutlet weak var studentName: UILabel!
    
    @IBOutlet weak var studentEmail: UILabel!
    
    @IBOutlet weak var studentCourse: UILabel!
    
    @IBOutlet weak var studentHelpMessage: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    var currentStudent: Student = Student(name: "", helpMessage: "", course: "")
    
    //@IBOutlet weak var pageTitle: UINavigationItem!
    
    override func viewDidLoad() {
        studentName.text = "Student Name: " + currentStudent.name
        studentNumber.text = "Place in Queue: " + "\(currentStudent.placeInQueue)"
        studentEmail.text = "Email: " + currentStudent.netID + "@princeton.edu"
        studentCourse.text = "Course: " + currentStudent.course
        studentHelpMessage.text = "Help Message: " + currentStudent.helpMessage
        pageTitle.title = "More Info About " + currentStudent.name
        if (currentStudent.placeInQueue == 1) {
            acceptButton.hidden = false
        }
        else {
            acceptButton.hidden = true
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
