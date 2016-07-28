//
//  StudentHomeViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//


import UIKit
import CoreData
import SCLAlertView

/// Home View Controller for students. Displays Queue and allows students to add themselves to the Queue
///
/// Attributes:
/// * navBar, acceptButton, toolBar, queueTable: UI Elements
@IBDesignable class StudentHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //UI Elements
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
        UISetup()
    }
    
    
    /// Set up the User Interface
    func UISetup() {
        self.queueTable.rowHeight = 50
        toolBar.backgroundColor = UIColor(netHex:0x4183D7)
        self.navigationController?.navigationBar.barTintColor = UIColor(netHex:0x4183D7)
        self.navigationItem.setHidesBackButton(true, animated: false)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.queueTable.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(StudentHomeViewController.refresh(_:)), forControlEvents: .ValueChanged)
        queueTable.addSubview(refreshControl)
        
        let toolBarBorder = UIView(frame: CGRect(x: 0, y: self.view.frame.height - toolBar.frame.height, width: self.view.frame.width, height: 5))
        toolBarBorder.layer.backgroundColor = UIColor(netHex: 0x3B7CD1).CGColor
        toolBarBorder.layer.cornerRadius = 2
        self.view.addSubview(toolBarBorder)
    }
    
    /// Called when user pulls down to refresh
    func refresh(refreshControl: UIRefreshControl) {
        syncQueue()
        self.queueTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    /// Remove observer for silent notifications
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: removeStudentFromQueue, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: addStudentToQueue, object: nil)
    }
    
    /// Check if Queue is in sync before silent add/remove
    func checkSilentSync(notification: NSNotification) -> Bool {
        let token = getSyncToken()
        var test: Bool = true
        
        if token != notification.userInfo!["Sync Token"]! as! String {
            test = false
            SCLAlertView().showInfo("The Queue is out of sync", subTitle: "Pull down to refresh before continuing")
        }
        return test
    }
    
    /// Handler for silent addStudentToQueue Notification
    func silentAdd(notification: NSNotification) {
        //check if queue is in sync
        if checkSilentSync(notification) == false {
            return
        }
        
        //add request to core data
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
        
        //update UI
        queueTable.beginUpdates()
        self.queueTable.insertRowsAtIndexPaths([
            NSIndexPath(forRow: queueTable.numberOfRowsInSection(0), inSection: 0)
            ], withRowAnimation: UITableViewRowAnimation.Right)
        queueTable.endUpdates()
    }
    
    /// Handler for silent removeStudentFromQueue Notification
    func silentRemove(notification: NSNotification) {
        //check if Queue is in sync
        if checkSilentSync(notification) == false {
            return
        }
        
        //Remove request from core data
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
        
        //Update UI
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: hit, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        queueTable.reloadData()
    }
    
    /// Returns number of rows in Queue, ie: counts number of requests in core data
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
    
    /// Configures the cell at indexPath
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
    
    /// Show student info page when user selects a row in the table
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
    
    //Prepare destination view controllers before segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ShowStudentInfo") {
            let dest = segue.destinationViewController as! StudentStudentInfoViewController
            dest.currentStudent = sender as! Student
            //dest.eventId = sender as! Int
            //dest.eventId = sender as! String
            
        }
        else if (segue.identifier == "StudentHelpSession") {
            let dest = segue.destinationViewController as! StudentHelpSessionViewController
            //dest.currentStudent = sender as! Student
            dest.ta = sender as! LabTA
        }
    }
    
    /// Handler for when a student pushes the button to add
    /// himself to the Queue. Configures and displays alert
    /// view controller.
    @IBAction func addNamePushed(sender: UIButton) {
        
        // Initialize SCLAlertView using custom Appearance
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            shouldAutoDismiss: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        let textField = alert.addTextView()
        var course = ""
        let firstbutton = alert.addButton("109", backgroundColor: UIColor(netHex: 0x2866BF), textColor: UIColor.whiteColor(), showDurationStatus: false, action: {
            course = "109"
        })
        
        let secondButton = alert.addButton("126", backgroundColor: UIColor(netHex: 0x2866BF), textColor: UIColor.whiteColor(), showDurationStatus: false, action: {
            course = "126"
        })
        let thirdButton = alert.addButton("217", backgroundColor: UIColor(netHex: 0x2866BF), textColor: UIColor.whiteColor(), showDurationStatus: false, action: {
            course = "217"
        })
        
        let fourthButton = alert.addButton("226", backgroundColor: UIColor(netHex: 0x2866BF), textColor: UIColor.whiteColor(), showDurationStatus: false, action: {
            course = "226"
        })
        
        //add actions for alert buttons
        firstbutton.addTarget(self, action: #selector(StudentHomeViewController.courseButtonTapped(_:)), forControlEvents: UIControlEvents.TouchDown)
        secondButton.addTarget(self, action: #selector(StudentHomeViewController.courseButtonTapped(_:)), forControlEvents: UIControlEvents.TouchDown)
        thirdButton.addTarget(self, action: #selector(StudentHomeViewController.courseButtonTapped(_:)), forControlEvents: UIControlEvents.TouchDown)
        fourthButton.addTarget(self, action: #selector(StudentHomeViewController.courseButtonTapped(_:)), forControlEvents: UIControlEvents.TouchDown)
        
        alert.addButton("Submit", backgroundColor: UIColor(netHex: 0x006400), textColor: UIColor.whiteColor(), showDurationStatus: true, action: {
            alert.hideView()
            if self.checkTA(globalNetId) == false {
                return
            }
            if self.checkDuplicate(globalNetId) == false {
                return
            }
            self.addToQueue(textField.text, course: "COS \(course)", netid: globalNetId)
        })
        
        //add close button (little x in the upper corner)
        let rect = alert.getFrame()
        let base = alert.getBase()
        let subview = UIView(frame: CGRect(x: rect.maxX - 15, y: rect.minY + 35, width: 10, height: 10))
        let butt = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        butt.setTitle("×", forState: UIControlState.Normal)
        butt.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        subview.addSubview(butt)
        butt.addTarget(self, action: #selector(StudentHomeViewController.canceled), forControlEvents: UIControlEvents.TouchUpInside)
        
        let responder = alert.showEdit("Submit your info", subTitle: "Select your course and write a descriptive help message!", colorStyle: 0x2866BF)
        self.responder = responder
        base.addSubview(subview)
    }
    
    //alert responder
    var responder: AnyObject? = nil
    
    ///handler for when a course button is tapped in alert
    func courseButtonTapped(sender: AnyObject) {
        let responder = self.responder as! SCLAlertViewResponder
        let thisButton = sender as! SCLButton
        responder.setTitle("Course: \(thisButton.titleLabel!.text!)")
        responder.setSubTitle("")
    }
    
    ///handler for when cancel button is tapped in alert
    func canceled() {
        let responder = self.responder as! SCLAlertViewResponder
        responder.close()
    }
    
    /// Check whether the student is already on the Queue
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
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "HelveticaNeue", size: 16)!,
                        showCircularIcon: true
                    )
                    let alert = SCLAlertView(appearance: appearance)
                    alert.showInfo("You are already on the Queue", subTitle: "")
                    return false
                }
            }
            
        } catch {
            print("error fetching for checkDuplicate()")
        }
        return true
    }
    
    /// Check if the student is an active TA
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
                            let appearance = SCLAlertView.SCLAppearance(
                                kTitleFont: UIFont(name: "HelveticaNeue", size: 16)!,
                                showCircularIcon: true
                            )
                            let alert = SCLAlertView(appearance: appearance)
                            alert.showInfo("You are an active TA", subTitle: "")
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
            SCLAlertView().showInfo("The Queue is out of sync", subTitle: "Pull down to refresh before continuing")
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
        
        /*update UI*/
        self.queueTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.queueTable.numberOfRowsInSection(0), inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
        self.queueTable.reloadData()
        
    }
    
    /// get the full name of a student from their NetID through the TigerBook API
    func getName(netid: String) -> String {
        var name: String = ""
        
        let url: NSURL = NSURL(string: "https://tigerbook-sandbox.herokuapp.com/api/v1/undergraduates/\(netid)")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        let headers = getWSSEHeaders()
        request.allHTTPHeaderFields = headers
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            if error == nil && data != nil {
                do {
                    let jsonObj = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                    name = jsonObj["full_name"] as! String
                } catch {
                    
                }
            }
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return name
    }
}