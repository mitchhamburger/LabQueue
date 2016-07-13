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
    
    @IBOutlet weak var acceptButton: LumenButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var queueTable: UITableView!
    var navBar:UINavigationBar=UINavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentHomeViewController.silentRemove), name: removeStudentFromQueue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentHomeViewController.silentAdd), name: addStudentToQueue, object: nil)
        syncQueue()
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
        self.queueTable.rowHeight = 50
        toolBar.backgroundColor = UIColor(netHex:0x4183D7)
        self.navigationController?.navigationBar.barTintColor = UIColor(netHex:0x4183D7)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.queueTable.tableFooterView = UIView()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        queueTable.addSubview(refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        // Do your job, when done:
        syncQueue()
        self.queueTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: removeStudentFromQueue, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: addStudentToQueue, object: nil)
    }
    
    func checkSilentSync(notification: NSNotification) -> Bool {
        let token = getSyncToken()
        var test: Bool = true
        
        if token != notification.userInfo!["Sync Token"]! as! String {
            test = false
            let alertController = UIAlertController(title: "The Queue is out of Sync, please refresh before continuing", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: ({
                (_) in
                //syncQueue()
                //self.queueTable.reloadData()
            }))
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        return test
    }
    
    /// Handler for addStudentToQueue Notification
    func silentAdd(notification: NSNotification) {
        if checkSilentSync(notification) == false {
            return
        }

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentName = notification.userInfo!["studentinfo"]!["Name"] as! String
        let studentCourse = notification.userInfo!["studentinfo"]!["Course"] as! String
        let studentMessage = notification.userInfo!["studentinfo"]!["Help Message"] as! String
        let studentID = notification.userInfo!["studentinfo"]!["NetID"] as! String
        let requestID = notification.userInfo!["studentinfo"]!["RequestID"] as! Int
        let thisStudent = Student(name: studentName, helpMessage: studentMessage, course: studentCourse, netid: studentID, requestID: requestID)
        
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let inputStudentObj = NSManagedObject(entity: studentEntity!, insertIntoManagedObjectContext: managedContext)
        inputStudentObj.setValue(thisStudent.name, forKey: "name")
        inputStudentObj.setValue(thisStudent.helpMessage, forKey: "helpmessage")
        inputStudentObj.setValue(thisStudent.course, forKey: "course")
        inputStudentObj.setValue(thisStudent.netID, forKey: "netid")
        inputStudentObj.setValue(thisStudent.requestID, forKey: "requestid")
        do {
            try managedContext!.save()
        } catch {
            print("error witth \(thisStudent.netID)")
        }
        
        queueTable.beginUpdates()
        self.queueTable.insertRowsAtIndexPaths([
            NSIndexPath(forRow: queueTable.numberOfRowsInSection(0), inSection: 0)
            ], withRowAnimation: UITableViewRowAnimation.Right)
        queueTable.endUpdates()
    }
    
    /// Handler for removeStudentFromQueue Notification
    func silentRemove(notification: NSNotification) {
        if checkSilentSync(notification) == false {
            return
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        
        let fetchRequest = NSFetchRequest()
        let sectionSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.entity = studentEntity
        
        var hit: Int = 0
        var count: Int = 0
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            for request in result {
                let requestObj = request as! NSManagedObject
                if requestObj.valueForKey("requestid") as! Int == notification.userInfo!["id"] as! Int {
                    hit = count
                    let thisStudent = requestObj
                    managedContext?.deleteObject(thisStudent)
                }
                count += 1
            }
        } catch {
            print("error fetching")
        }
        do {
            try managedContext?.save()
        } catch {
            print("error deleting \(notification.userInfo!["id"])")
        }
        
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: hit, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        queueTable.reloadData()
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = studentEntity
        var count: Int = 0
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            count = result.count
        } catch {
            count = 0
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = studentEntity
        let sectionSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.entity = studentEntity
        
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("customcell")! as! StudentQueueCustomCell
        var result: [NSManagedObject] = [NSManagedObject]()
        do {
            result = try managedContext!.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            
        }
        
        let normalText = result[indexPath.row].valueForKey("name") as! String
        
        let boldText  = "     \(indexPath.row+1). "
        
        let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
        let boldString = NSMutableAttributedString(string:boldText, attributes:attrs)
        
        let attributedString = NSMutableAttributedString(attributedString: boldString)
        
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.appendAttributedString(normalString)
        cell.studentName.attributedText = attributedString
        cell.studentID = result[indexPath.row].valueForKey("netid") as! String
        

        if cell.studentID != globalNetId {
            cell.editButton.hidden = true
        }
        if cell.studentID == globalNetId {
            cell.editButton.hidden = false
        }
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = studentEntity
        let sectionSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.entity = studentEntity
        
        var result: [NSManagedObject] = [NSManagedObject]()
        do {
            result = try managedContext!.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            print("error")
        }
        let studentobj = result[indexPath.row]
        let name = studentobj.valueForKey("name")
        let netID = studentobj.valueForKey("netid")
        let helpMessage = studentobj.valueForKey("helpmessage")
        let course = studentobj.valueForKey("course")
        let requestID = studentobj.valueForKey("requestid")
        let thisStudent: Student = Student(name: name as! String, helpMessage: helpMessage as! String, course: course as! String, netid: netID as! String, requestID: requestID as! Int)
        thisStudent.placeInQueue = indexPath.row + 1
        print("you tapped \(indexPath.row)")
        
        self.performSegueWithIdentifier("ShowStudentInfo", sender: thisStudent)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ShowStudentInfo") {
            let dest = segue.destinationViewController as! StudentStudentInfoViewController
            dest.currentStudent = sender as! Student
            //dest.eventId = sender as! Int
            //dest.eventId = sender as! String
            
        }
    }
    
    /// Handler for when a student pushes the button to add
    /// himself to the Queue. Configures and displays alert
    /// view controller.
    @IBAction func addNamePushed(sender: UIButton) {
        let alertController = UIAlertController(title: "Add yourself to the Queue", message: "Submit your info", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: ({
            (_) in
            let problem = alertController.textFields![0]
            let course = alertController.textFields![1]
            if self.checkDuplicate(globalNetId) == false {
                return
            }
            if self.checkTA(globalNetId) == false {
                return
            }
            
            self.addToQueue(problem.text!, course: course.text!, netid: globalNetId)
        }))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
       /* alertController.addTextFieldWithConfigurationHandler({
            (textField) in
            textField.placeholder = "Name"
            
        })*/
        
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
    
    /*func checkName(name: String) -> Bool {
        if name == "" {
            let invalidController = UIAlertController(title: "Please fill in your name", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            invalidController.addAction(okAction)
            self.presentViewController(invalidController, animated: true, completion: nil)
            return false
        }
        return true
    }*/
    
    func checkDuplicate(netid: String) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = studentEntity
        
        do {
            let result = try managedContext?.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for entry in result {
                if entry.valueForKey("netid") as! String == netid {
                    let invalidController = UIAlertController(title: "You are already on the Queue", message: "", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                    invalidController.addAction(okAction)
                    self.presentViewController(invalidController, animated: true, completion: nil)
                    return false
                }
            }
            
        } catch {
            print("error fetching for checkDuplicate()")
        }
        return true
    }
    
    func checkTA(netid: String) -> Bool {
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(globalNetId)/TAs/ActiveTAs")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let semaphore = dispatch_semaphore_create(0)
        var flag: Bool = true
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            if error == nil && data != nil {
                do {
                    // Convert NSData to Dictionary where keys are of type String, and values are of any type
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
                    for entry in (json["TAs"]! as! NSArray) {
                        if entry["NetID"] as! String == netid {
                            let invalidController = UIAlertController(title: "You are an active TA", message: "", preferredStyle: .Alert)
                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                            invalidController.addAction(okAction)
                            self.presentViewController(invalidController, animated: true, completion: nil)
                            flag = false
                        }
                    }
                } catch {
                    "error with json serialization"
                }
            }
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return flag
    }
    
    /// Create a Student object and add it to the Queue through the API.
    ///
    /// Args:
    /// * nameField: name of the student
    /// * problemField: help message of the student
    /// * courseField: course of the student
    func addToQueue(helpMessage: String, course: String, netid: String) {
        let test = checkSync()
        
        if test == false {
            let alertController = UIAlertController(title: "The Queue is out of Sync, please refresh before continuing", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: ({
                (_) in
                //syncQueue()
                //self.queueTable.reloadData()
            }))
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        var name = getName(netid)
        if name == "" {
            name = netid
        }
        
        var index = 0
        
        //let thisStudent: Student = Student(name: name, helpMessage: helpMessage, course: course, netid: netid)
        
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
            do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
                print(json)
                index = json["RequestID"] as! Int
                print(index)
            } catch {
                print("failed getting json response")
            }
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        /*END HTTP REQUEST*/
        
        /*Add the entry to Core Data*/
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        
        let inputStudentObj = NSManagedObject(entity: studentEntity!, insertIntoManagedObjectContext: managedContext)
        inputStudentObj.setValue(name, forKey: "name")
        inputStudentObj.setValue(helpMessage, forKey: "helpmessage")
        inputStudentObj.setValue(course, forKey: "course")
        inputStudentObj.setValue(netid, forKey: "netid")
        inputStudentObj.setValue(index, forKey: "requestid")
        do {
            try managedContext?.save()
        } catch {
            print("error saving \(netid) into core data")
        }
        
        /*update currentQueue and UI*/
        self.queueTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.queueTable.numberOfRowsInSection(0), inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
        self.queueTable.reloadData()
        
    }
    
    func getName(netid: String) -> String {
        var name: String = ""
        let path = NSBundle.mainBundle().pathForResource("initial_data-2016-1", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        do {
            let jsonResult: NSArray = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            for item in jsonResult {
                if item["fields"]!!["net_id"] as! String == netid {
                    name = item["fields"]!!["full_name"] as! String
                }
            }
        } catch {
            print("f")
        }
        
        /*let url: NSURL = NSURL(string: "http://www.princeton.edu\(studentPic)")!
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
        task.resume()*/
        return name
    }
    
    @IBAction func backPressed(sender: UIButton) {
        self.performSegueWithIdentifier("back", sender: sender)
    }
}