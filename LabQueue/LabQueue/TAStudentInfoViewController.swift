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
        
        TACurrentStudent = currentStudent
        
        //WILL PUT NSUSER TA NAME HERE
        TACurrentStudent = currentStudent
        let prefs = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(currentStudent)
        prefs.setObject(encodedData, forKey: "TACurrentStudent")
        
        /*BEGIN HTTP REQUEST*/
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(globalNetId)/Requests/\(currentStudent.netID)/Helped")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        /*END HTTP REQUEST*/
        
        /*Remove the entry from Core Data*/
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Configure Fetch Request
        fetchRequest.entity = studentEntity
        let predicate = NSPredicate(format: "%K == %@", "netid", currentStudent.netID)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            managedContext?.deleteObject(result[0] as! NSManagedObject)
        } catch {
            print("error fetching \(currentStudent.netID)")
        }
        do {
            try managedContext?.save()
        } catch {
            print("error saving context after deleting \(currentStudent.netID)")
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("TAHomeViewController")
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
}
