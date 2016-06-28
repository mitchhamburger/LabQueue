//
//  StudentHomeViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//


import UIKit
import CoreData

/// Home View Controller for students. Displays Queue and allows students to add themselves to the Queue
///
/// Attributes:
/// * students: List of students to populate queue
@IBDesignable class StudentHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var queueTable: UITableView!
    var students = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentHomeViewController.silentRemove), name: removeStudentFromQueue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentHomeViewController.silentAdd), name: addStudentToQueue, object: nil)
        getQueueData("\(hostName)/LabQueue/v1/Queue")
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
        self.queueTable.layer.borderWidth = 2
        self.queueTable.layer.cornerRadius = 10
        self.queueTable.separatorColor = UIColor.blackColor()
        allStudents = students
    }
    
    /// Handler for addStudentToQueue Notification
    func silentAdd() {
        students.removeAll()
        getQueueData("\(hostName)/LabQueue/v1/Queue")
        self.queueTable.insertRowsAtIndexPaths([
            NSIndexPath(forRow: self.students.count - 1, inSection: 0)
            ], withRowAnimation: UITableViewRowAnimation.Right)
        self.queueTable.reloadData()
    }
    
    /// Handler for removeStudentFromQueue Notification
    func silentRemove() {
        students.removeFirst()
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        queueTable.reloadData()
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("customcell")! as! StudentQueueCustomCell
        cell.studentName.text = "\(indexPath.row + 1). " + students[indexPath.row].name
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("you tapped \(indexPath.row)")
        
        self.students[indexPath.row].placeInQueue = indexPath.row + 1
        self.performSegueWithIdentifier("ShowStudentInfo", sender: self.students[indexPath.row])
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ShowStudentInfo") {
            let dest = segue.destinationViewController as! StudentStudentInfoViewController
            dest.currentStudent = sender as! Student
            //dest.eventId = sender as! Int
            //dest.eventId = sender as! String
            
        }
    }
    
    /// Populates students array from database using GET
    /// Request through the API
    ///
    /// Paramters:
    /// * urlString: url of API call
    func getQueueData(urlString: String) {
        /*HTTP REQUEST VERSION OF GETQUEUEDATA*/
        let url: NSURL = NSURL(string: urlString)!
         let session = NSURLSession.sharedSession()
         let request = NSMutableURLRequest(URL: url)
         request.HTTPMethod = "GET"
         request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
         
         let semaphore = dispatch_semaphore_create(0)
         let task = session.dataTaskWithRequest(request) {
         (
         let data, let response, let error) in
         guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
         print("error")
         return
         }
         if error == nil && data != nil {
         do {
         // Convert NSData to Dictionary where keys are of type String, and values are of any type
         let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
         var count = 0
         for student in (json["Queue"]! as! NSArray) {
         let thisStudent: Student = Student(name: student["Name"] as! String, helpMessage: student["Help Message"] as! String, course: student["Course"] as! String)
         thisStudent.netID = student["NetID"] as! String
         self.students.append(thisStudent)
         count += 1
         }
         
         } catch {
         // Something went wrong
         }
         }
         dispatch_semaphore_signal(semaphore)
         }
         task.resume()
         dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        
        
        /*CORE DATA VERSION OF GETQUEUEDATA*/
        /*
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let taEntity = NSEntityDescription.entityForName("LabTA", inManagedObjectContext: managedContext!)
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Configure Fetch Request
        fetchRequest.entity = studentEntity
        
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            if (result.count > 0) {
                
                for student in result {
                    let studentobj = student as! NSManagedObject
                    
                    let name = studentobj.valueForKey("name")
                    let netID = studentobj.valueForKey("netid")
                    let attendingTA = studentobj.valueForKey("attendingta")
                    let requestTime = studentobj.valueForKey("requesttime")
                    let helpedTime = studentobj.valueForKey("helpedtime")
                    let beenHelped = studentobj.valueForKey("beenhelped")
                    let helpMessage = studentobj.valueForKey("helpmessage")
                    let course = studentobj.valueForKey("course")
                    let canceled = studentobj.valueForKey("canceled")
                    let inQueue = studentobj.valueForKey("inqueue")
                    
                    let thisStudent: Student = Student(name: name as! String, helpMessage: helpMessage as! String, course: course as!String)
                    
                    
                    //thisStudent.attendingTA = attendingTA as! String
                    thisStudent.netID = netID as! String
                    //thisStudent.canceled = canceled as! Bool
                    //thisStudent.beenHelped = beenHelped as! Bool
                    //thisStudent.inQueue = inQueue as! Bool
                    //thisStudent.requestTime = requestTime as! String
                    //thisStudent.helpedTime = helpedTime as! String
                    self.students.append(thisStudent)
                    
                    
                    //print("name: \(name!), netid: \(netid!), help message: \(helpmessage!)")
                }
            }
            
        } catch {
            let fetchError = error as NSError
            print("here")
            print(fetchError)
        }*/
    }

    /// Handler for when a student pushes the button to add
    /// himself to the Queue. Configures and displays alert
    /// view controller.
    @IBAction func addNamePushed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("NewFormViewController")
        //self.showViewController(vc as! UIViewController, sender: vc)
        
        
        let alertController = UIAlertController(title: "Add yourself to the Queue", message: "Submit your info", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: ({
            (_) in
            if let name = alertController.textFields![0] as? UITextField {
                if let problem = alertController.textFields![1] as? UITextField {
                    if let course = alertController.textFields![2] as? UITextField {
                        self.addToQueue(name.text!, problemField: problem.text!, courseField: course.text!)
                        self.queueTable.beginUpdates()
                        self.queueTable.insertRowsAtIndexPaths([
                            NSIndexPath(forRow: self.students.count-1, inSection: 0)
                            ], withRowAnimation: UITableViewRowAnimation.Right)
                        self.queueTable.reloadData()
                        self.queueTable.endUpdates()
                    }
                }
                
            }
            }
        ))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addTextFieldWithConfigurationHandler({
            (textField) in
            textField.placeholder = "Name"
            
        })
        
        alertController.addTextFieldWithConfigurationHandler({
            (textField) in
            textField.placeholder = "Describe Your Problem"
            
        })
        
        alertController.addTextFieldWithConfigurationHandler({
            (textField) in
            textField.placeholder = "Course"
            
        })
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Create a Student object and add it to the Queue through the API.
    ///
    /// Args:
    /// * nameField: name of the student
    /// * problemField: help message of the student
    /// * courseField: course of the student
    func addToQueue(nameField: String, problemField: String, courseField: String) {
        let thisStudent: Student = Student(name: nameField, helpMessage: problemField, course: courseField)
        let jsonObj = ["Name": nameField,
                       "NetID": globalNetId,
                       "Help Message":problemField,
                       "Been Helped": false,
                       "Canceled": false,
                       "In Queue": true,
                       "Request Time": "",
                       "Helped Time": "",
                       "Attending TA": "",
                       "Course": courseField]
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v1/Queue")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: .PrettyPrinted)
            
            // create post request
            let url = NSURL(string: "\(hostName)/LabQueue/v1/Queue")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            let semaphore = dispatch_semaphore_create(0)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    allStudents.append(thisStudent)
                    self.students.append(thisStudent)
                    //print("Result -> \(result)")
                } catch {
                    print("Error -> \(error)")
                }
                dispatch_semaphore_signal(semaphore)
            }
            task.resume()
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
        } catch {
            print(error)
        }
        
        /*
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        
        let thisStudent: Student = Student(name: nameField, helpMessage: problemField, course: courseField)
        //NEED TO GET THISSTUDENT'S NETID FROM CAS OR WHEREVER
        
        let inputStudentObj = NSManagedObject(entity: studentEntity!, insertIntoManagedObjectContext: managedContext)
        inputStudentObj.setValue(thisStudent.name, forKey: "name")
        inputStudentObj.setValue(thisStudent.helpMessage, forKey: "helpmessage")
        inputStudentObj.setValue(thisStudent.course, forKey: "course")
        inputStudentObj.setValue("temp until CAS", forKey: "netid")
        
        do {
            try inputStudentObj.managedObjectContext?.save()
            
            //HTTP REQUEST
            let jsonObj = ["Name": nameField,
                           "NetID": "gc23",
                           "Help Message":problemField,
                           "Been Helped": false,
                           "Canceled": false,
                           "In Queue": true,
                           "Request Time": "",
                           "Helped Time": "",
                           "Attending TA": "",
                           "Course": courseField]
            let url: NSURL = NSURL(string: "http://localhost:5000/LabQueue/v1/Queue")!
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
            
            do {
                
                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: .PrettyPrinted)
                
                // create post request
                let url = NSURL(string: "http://localhost:5000/LabQueue/v1/Queue")!
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                
                // insert json data to the request
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = jsonData
                
                let semaphore = dispatch_semaphore_create(0)
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                    if error != nil{
                        print("Error -> \(error)")
                        return
                    }
                    
                    do {
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                        
                        //print("Result -> \(result)")
                    } catch {
                        print("Error -> \(error)")
                    }
                    dispatch_semaphore_signal(semaphore)
                }
                task.resume()
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                
            } catch {
                print(error)
            }
            //END HTTP REQUEST
            allStudents.append(thisStudent)
            students.append(thisStudent)
            
        } catch {
            print("error on \(thisStudent.name)")
        }*/
    }
}