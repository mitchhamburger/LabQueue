//
//  StudentStudentInfoViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/13/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit


///  View Controller to display info about inidivudal
///  students that is available to other students.
///
///  Information available:
///
///  1. place in queue
///  2. student name
///  3. student email
///  4. course that student is in
class StudentStudentInfoViewController: UIViewController {
    var currentStudent: Student = Student(name: "", helpMessage: "", course: "", netid: "")
    
    @IBOutlet weak var studentNumber: UILabel!
    
    @IBOutlet weak var studentName: UILabel!
    
    @IBOutlet weak var studentEmail: UILabel!
    
    @IBOutlet weak var studentCourse: UILabel!
    
    override func viewDidLoad() {
        studentNumber.text = "\(currentStudent.placeInQueue)"
        studentName.text = currentStudent.name
        studentEmail.text = currentStudent.netID + "@princeton.edu"
        studentCourse.text = currentStudent.course
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


