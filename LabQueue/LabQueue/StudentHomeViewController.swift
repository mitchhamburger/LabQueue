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
/// * currentQueue: List of students to populate queue
@IBDesignable class StudentHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var queueTable: UITableView!
    var currentQueue = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentHomeViewController.silentRemove), name: removeStudentFromQueue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentHomeViewController.silentAdd), name: addStudentToQueue, object: nil)
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
        self.queueTable.layer.borderWidth = 2
        self.queueTable.layer.cornerRadius = 10
        self.queueTable.separatorColor = UIColor.blackColor()
        populateTable()
    }
    
    /// Handler for addStudentToQueue Notification
    func silentAdd() {
        populateTable()
        self.queueTable.insertRowsAtIndexPaths([
            NSIndexPath(forRow: self.currentQueue.count - 1, inSection: 0)
            ], withRowAnimation: UITableViewRowAnimation.Right)
        self.queueTable.reloadData()
    }
    
    /// Handler for removeStudentFromQueue Notification
    func silentRemove() {
        currentQueue.removeFirst()
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        queueTable.reloadData()
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQueue.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("customcell")! as! StudentQueueCustomCell
        cell.studentName.text = "\(indexPath.row + 1). " + currentQueue[indexPath.row].name
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("you tapped \(indexPath.row)")
        
        self.currentQueue[indexPath.row].placeInQueue = indexPath.row + 1
        self.performSegueWithIdentifier("ShowStudentInfo", sender: self.currentQueue[indexPath.row])
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ShowStudentInfo") {
            let dest = segue.destinationViewController as! StudentStudentInfoViewController
            dest.currentStudent = sender as! Student
            //dest.eventId = sender as! Int
            //dest.eventId = sender as! String
            
        }
    }
    
    /// Populates currentQueue from core data
    func populateTable() {
        currentQueue.removeAll()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        
        // Initialize and configure Fetch Request
        let fetchRequest = NSFetchRequest()
        let sectionSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.entity = studentEntity
        
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            
            for student in result {
                let studentobj = student as! NSManagedObject
                
                let name = studentobj.valueForKey("name")
                let netID = studentobj.valueForKey("netid")
                let helpMessage = studentobj.valueForKey("helpmessage")
                let course = studentobj.valueForKey("course")
                let thisStudent: Student = Student(name: name as! String, helpMessage: helpMessage as! String, course: course as! String, netid: netID as! String)
                currentQueue.append(thisStudent)
            }
        } catch {
            let fetchError = error as NSError
            print("Error fetching from core data")
            print(fetchError)
        }
    }
    
    
    /// Handler for when a student pushes the button to add
    /// himself to the Queue. Configures and displays alert
    /// view controller.
    @IBAction func addNamePushed(sender: UIButton) {
        
        let alertController = UIAlertController(title: "Add yourself to the Queue", message: "Submit your info", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: ({
            (_) in
            let name = alertController.textFields![0] 
            let problem = alertController.textFields![1]
            let course = alertController.textFields![2]
            self.addToQueue(name.text!, helpMessage: problem.text!, course: course.text!, netid: globalNetId)
            }))
        
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
    func addToQueue(name: String, helpMessage: String, course: String, netid: String) {
        let thisStudent: Student = Student(name: name, helpMessage: helpMessage, course: course, netid: netid)
        
        /*BEGIN HTTP REQUEST*/
        let jsonObj = ["Name": name,
                       "NetID": netid,
                       "Help Message": helpMessage,
                       "Course": course]
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(globalNetId)/Requests")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: .PrettyPrinted)
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
        } catch {
            print("error converting input to json")
        }
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        /*END HTTP REQUEST*/
        
        /*update currentQueue and UI*/
        self.queueTable.beginUpdates()
        currentQueue.append(thisStudent)
        self.queueTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.currentQueue.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
        self.queueTable.reloadData()
        self.queueTable.endUpdates()
        
        /*Add the entry to Core Data*/
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        
        let inputStudentObj = NSManagedObject(entity: studentEntity!, insertIntoManagedObjectContext: managedContext)
        inputStudentObj.setValue(name, forKey: "name")
        inputStudentObj.setValue(helpMessage, forKey: "helpmessage")
        inputStudentObj.setValue(course, forKey: "course")
        inputStudentObj.setValue(netid, forKey: "netid")
        
        do {
            try managedContext?.save()
        } catch {
            print("error saving \(netid) into core data")
        }
    }
}