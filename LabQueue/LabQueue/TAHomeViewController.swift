//
//  TAHomeViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//


import UIKit
import CoreData


/// Home View Controller for TA's. Displays TA's current student, a picture of that student, and the current student queue.
///
/// Attributes:
/// * students: List of students to populate queue
/// * managedObjectContext: NSManagedObjectContext for NSData
@IBDesignable class TAHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var studentPicture: StudentPictureView!
    @IBOutlet weak var queueTable: UITableView!
    
    @IBOutlet weak var titleBar: UINavigationBar!
    var currentQueue = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TAHomeViewController.silentRemove), name: removeStudentFromQueue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TAHomeViewController.silentAdd), name: addStudentToQueue, object: nil)
        studentPicture.layer.cornerRadius = studentPicture.frame.size.width / 2;
        studentPicture.clipsToBounds = true
        studentPicture.layer.borderWidth = 2
        studentPicture.layer.borderColor = UIColor.blackColor().CGColor
        studentPicture.image = UIImage(named: "mitch pic.jpg")
        populateTable()
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
        self.queueTable.layer.borderWidth = 2
        self.queueTable.layer.cornerRadius = 10
        self.queueTable.separatorColor = UIColor.blackColor()
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let studentData = prefs.objectForKey("TACurrentStudent") {
            let student = NSKeyedUnarchiver.unarchiveObjectWithData(studentData as! NSData) as! Student
            titleBar.topItem?.title = "Your Current Student is " + student.name
            TACurrentStudent = student
        }
        else {
            titleBar.topItem?.title = "Welcome to Lab TAs!"
        }
        //syncQueue()
    }
    
    /// Handler for addStudentToQueue Notification
    func silentAdd() {
        syncQueue()
        populateTable()
        queueTable.beginUpdates()
        self.queueTable.insertRowsAtIndexPaths([
            NSIndexPath(forRow: self.currentQueue.count - 1, inSection: 0)
            ], withRowAnimation: UITableViewRowAnimation.Right)
        queueTable.endUpdates()
        self.queueTable.reloadData()
    }
    
    /// Handler for removeStudentFromQueue Notification
    func silentRemove() {
        syncQueue()
        queueTable.beginUpdates()
        currentQueue.removeFirst()
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        queueTable.endUpdates()
        queueTable.reloadData()
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQueue.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("TAcustomcell")! as! TAQueueCustomCell
        cell.studentName.text = "\(indexPath.row + 1). " + self.currentQueue[indexPath.row].name
        if (indexPath.row == 0) {
            cell.acceptButton.hidden = false
            cell.rejectButton.hidden = false
        }
        else {
            cell.acceptButton.hidden = true
            cell.rejectButton.hidden = true
        }
        
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("you tapped \(indexPath.row)")
        
        self.currentQueue[indexPath.row].placeInQueue = indexPath.row + 1
        self.performSegueWithIdentifier("ToSpecificStudent", sender: self.currentQueue[indexPath.row])
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ToSpecificStudent") {
            let dest = segue.destinationViewController as! TAStudentInfoViewController
            dest.currentStudent = sender as! Student
        }
            
        else if (segue.identifier == "ShowCurrentStudent") {
            let dest = segue.destinationViewController as! TAStudentInfoViewController
            dest.currentStudent = TACurrentStudent
            dest.isCurrentStudent = true
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

    /// Handles when a TA accepts a student. Queries the API
    /// and and removes the student from the visible queue
    @IBAction func acceptStudent(sender: UIButton) {
        
        let currentStudent: Student = currentQueue[0]
        
        //WILL PUT NSUSER TA NAME HERE
        TACurrentStudent = currentStudent
        let prefs = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(currentStudent)
        prefs.setObject(encodedData, forKey: "TACurrentStudent")
        //prefs.setValue(currentStudent, forKey: "TACurrentStudent")
        
        titleBar.topItem?.title = "Your Current Student is " + currentStudent.name
        
        /*update currentQueue and UI*/
        queueTable.beginUpdates()
        currentQueue.removeFirst()
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        queueTable.endUpdates()
        queueTable.reloadData()
        
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
    }
    
    /// Handles when a TA rejects a student. Queries the API
    /// and and removes the student from the visible queue
    @IBAction func cancelStudent(sender: UIButton) {
        
        let currentStudent: Student = currentQueue[0]
        
        /*update currentQueue and UI*/
        queueTable.beginUpdates()
        currentQueue.removeFirst()
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        queueTable.endUpdates()
        queueTable.reloadData()
        
        //HTTP REQUEST
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(globalNetId)/Requests/\(currentStudent.netID)/Canceled")!
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
        //END HTTP REQUEST
        
        /*Remove the entry from Core Data*/
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        
        // Initialize and configure Fetch Request
        let fetchRequest = NSFetchRequest()
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
        
    }
    
    /// Handles when a TA pushes the picture of his/her current student.
    @IBAction func currenStudentPushed(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowCurrentStudent", sender: TACurrentStudent)
    }
}
