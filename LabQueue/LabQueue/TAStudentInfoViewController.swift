//
//  TAStudentInfoViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/13/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//


import UIKit

///  View Controller to display info about inidivudal
///  students that is available to LAb TA's.
///
///  Information available:
///
///  1. place in queue
///  2. student name
///  3. student email
///  4. course that student is in
///  5. help message
@IBDesignable class TAStudentInfoViewController: UIViewController {
    
    @IBOutlet weak var pageTitle: UINavigationItem!
    
    @IBOutlet weak var studentNumber: UILabel!
    
    @IBOutlet weak var studentName: UILabel!
    
    @IBOutlet weak var studentEmail: UILabel!
    
    @IBOutlet weak var studentCourse: UILabel!
    
    @IBOutlet weak var studentHelpMessage: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    var currentStudent: Student = Student(name: "", helpMessage: "", course: "", netid: "")
    var isCurrentStudent: Bool = false
    
    
    override func viewDidLoad() {
        
        if (isCurrentStudent) {
            studentNumber.hidden = true
            acceptButton.hidden = true
        }
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func acceptStudent(sender: UIButton) {
        
        let currentStudent: Student = allStudents[0]
        TACurrentStudent = currentStudent
        
        let url: NSURL = NSURL(string: "http://localhost:5000/LabQueue/v1/Queue/" + currentStudent.netID)!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        allStudents.removeFirst()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("TAHomeViewController")
        self.presentViewController(vc, animated: true, completion: nil)
    }
}
