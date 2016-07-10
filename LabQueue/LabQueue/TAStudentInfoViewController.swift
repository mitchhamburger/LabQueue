//
//  TAStudentInfoViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/13/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//


import UIKit
import CoreData

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
    
    //@IBOutlet weak var studentNumber: UILabel!
    
    //@IBOutlet weak var studentName: UILabel!
    
    //@IBOutlet weak var studentEmail: UILabel!
    
    //@IBOutlet weak var studentCourse: UILabel!
    
    //@IBOutlet weak var studentHelpMessage: UILabel!
    
    @IBOutlet weak var studentPic: UIImageView!
    
    var currentStudent: Student = Student(name: "", helpMessage: "", course: "", netid: "", requestID: 0)
    var isCurrentStudent: Bool = false
    
    
    override func viewDidLoad() {
        
        if (isCurrentStudent) {
            //studentNumber.hidden = true
        }
        //studentName.text = "Student Name: " + currentStudent.name
        //studentNumber.text = "Place in Queue: " + "\(currentStudent.placeInQueue)"
        //studentEmail.text = "Email: " + currentStudent.netID + "@princeton.edu"
        //studentCourse.text = "Course: " + currentStudent.course
        //studentHelpMessage.text = "Help Message: " + currentStudent.helpMessage
        request()
        
        studentPic.layer.cornerRadius = studentPic.frame.size.width / 2;
        studentPic.clipsToBounds = true
        studentPic.layer.borderWidth = 2
        studentPic.layer.borderColor = UIColor.blackColor().CGColor
        
        super.viewDidLoad()
        
    }
    
    func request() {
        var studentPic = ""
        let path = NSBundle.mainBundle().pathForResource("initial_data-2016-1", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
            do {
                let jsonResult: NSArray = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                for item in jsonResult {
                    if item["fields"]!!["net_id"] as! String == currentStudent.netID {
                        studentPic = item["fields"]!!["photo_link"] as! String
                    }
                }
            } catch {
                print("f")
            }
        
        let url: NSURL = NSURL(string: "http://www.princeton.edu\(studentPic)")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            if error == nil && data != nil {
                self.studentPic.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
