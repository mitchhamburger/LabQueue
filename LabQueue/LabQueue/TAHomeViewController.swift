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
    
    

    @IBOutlet weak var toolBarLabel: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var queueTable: UITableView!
    
    //let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TAHomeViewController.silentRemove), name: removeStudentFromQueue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TAHomeViewController.silentAdd), name: addStudentToQueue, object: nil)
        /*studentPicture.layer.cornerRadius = studentPicture.frame.size.width / 2;
        studentPicture.clipsToBounds = true
        studentPicture.layer.borderWidth = 2
        studentPicture.layer.borderColor = UIColor.blackColor().CGColor
        studentPicture.image = UIImage(named: "mitch pic.jpg")*/
        let count = syncQueue()
        toolBarLabel.text = "\(count) Students in Queue"
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
        
        toolBar.backgroundColor = UIColor(netHex:0x4183D7)
        self.navigationController?.navigationBar.barTintColor = UIColor(netHex:0x4183D7)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        /*self.queueTable.layer.borderWidth = 2
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
        }*/
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
            let okAction = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Cancel, handler: ({
                (_) in
                syncQueue()
                self.queueTable.reloadData()
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
        let thisStudent = Student(name: studentName, helpMessage: studentMessage, course: studentCourse, netid: studentID)
        
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let inputStudentObj = NSManagedObject(entity: studentEntity!, insertIntoManagedObjectContext: managedContext)
        inputStudentObj.setValue(thisStudent.name, forKey: "name")
        inputStudentObj.setValue(thisStudent.helpMessage, forKey: "helpmessage")
        inputStudentObj.setValue(thisStudent.course, forKey: "course")
        inputStudentObj.setValue(thisStudent.netID, forKey: "netid")
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
                if requestObj.valueForKey("netid") as! String == notification.userInfo!["id"] as! String {
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
        
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("customcell")! as! TAQueueCustomCell
        var result: [NSManagedObject] = [NSManagedObject]()
        do {
            result = try managedContext!.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            
        }
        cell.studentName.text = "\(indexPath.row + 1). \(result[indexPath.row].valueForKey("name") as! String)"
        cell.studentID = result[indexPath.row].valueForKey("netid") as! String
        cell.studentCourse.text = result[indexPath.row].valueForKey("course") as? String
        cell.studentHelpMessage.text = result[indexPath.row].valueForKey("helpmessage") as? String
        cell.studentHelpMessage.lineBreakMode = .ByTruncatingTail
        //let cell = self.queueTable.dequeueReusableCellWithIdentifier("TAcustomcell")! as! TAQueueCustomCell
        //cell.studentName.text = "\(indexPath.row + 1). " + self.currentQueue[indexPath.row].name
        
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
        let thisStudent: Student = Student(name: name as! String, helpMessage: helpMessage as! String, course: course as! String, netid: netID as! String)
        thisStudent.placeInQueue = indexPath.row + 1
        print("you tapped \(indexPath.row)")
        
        //self.currentQueue[indexPath.row].placeInQueue = indexPath.row + 1
        self.performSegueWithIdentifier("ToSpecificStudent", sender: thisStudent)
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let reject = UITableViewRowAction(style: .Normal, title: "Reject") { action, index in
            self.cancelConfirmed(indexPath)
        }
        reject.backgroundColor = UIColor.redColor()
        
        let accept = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
            self.acceptConfirmed(indexPath)
        }
        accept.backgroundColor = UIColor.greenColor()
        
        let details = UITableViewRowAction(style: .Normal, title: "Details") { action, index in
            self.tableView(self.queueTable, didSelectRowAtIndexPath: indexPath)
        }
        details.backgroundColor = UIColor.lightGrayColor()
        return [reject, accept, details]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
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
    
    func acceptConfirmed(index: NSIndexPath) {
        let test = checkSync()
        
        if test == false {
            let alertController = UIAlertController(title: "The Queue is out of Sync, please refresh before continuing", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Cancel, handler: ({
                (_) in
                syncQueue()
                self.queueTable.reloadData()
            }))
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        /*Remove the entry from Core Data*/
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Configure Fetch Request
        fetchRequest.entity = studentEntity
        let cell = queueTable.cellForRowAtIndexPath(NSIndexPath(forRow: index.row, inSection: 0)) as! TAQueueCustomCell
        let id = cell.studentID
        let predicate = NSPredicate(format: "%K == %@", "netid", id)
        fetchRequest.predicate = predicate
        let currentStudent: Student = Student(name: "", helpMessage: "", course: "", netid: "")
        
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            let studentObj = result[0] as! NSManagedObject
            currentStudent.name = studentObj.valueForKey("name") as! String
            currentStudent.course = studentObj.valueForKey("course") as! String
            currentStudent.helpMessage = studentObj.valueForKey("helpmessage") as! String
            currentStudent.netID = studentObj.valueForKey("netid") as! String
            managedContext?.deleteObject(result[0] as! NSManagedObject)
        } catch {
            print("error fetching \(currentStudent.netID)")
        }
        do {
            try managedContext?.save()
        } catch {
            print("error saving context after deleting \(currentStudent.netID)")
        }
        
        //WILL PUT NSUSER TA NAME HERE
        TACurrentStudent = currentStudent
        let prefs = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(currentStudent)
        prefs.setObject(encodedData, forKey: "TACurrentStudent")
        //prefs.setValue(currentStudent, forKey: "TACurrentStudent")
        
        //titleBar.topItem?.title = "Your Current Student is " + currentStudent.name
        
        /*BEGIN HTTP REQUEST*/
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(globalNetId)/Requests/\(currentStudent.netID)/Helped")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        //let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            //dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        /*END HTTP REQUEST*/
        
        /*update currentQueue and UI*/
        queueTable.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
        queueTable.reloadData()
    }
    
    func cancelConfirmed(index: NSIndexPath) {
        let test = checkSync()
        
        if test == false {
            let alertController = UIAlertController(title: "The Queue is out of Sync, please refresh before continuing", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Cancel, handler: ({
                (_) in
                syncQueue()
                self.queueTable.reloadData()
                }))
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        /*Remove the entry from Core Data*/
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Configure Fetch Request
        fetchRequest.entity = studentEntity
        let cell = queueTable.cellForRowAtIndexPath(NSIndexPath(forRow: index.row, inSection: 0)) as! TAQueueCustomCell
        let id = cell.studentID
        let predicate = NSPredicate(format: "%K == %@", "netid", id)
        fetchRequest.predicate = predicate
        let currentStudent: Student = Student(name: "", helpMessage: "", course: "", netid: "")
        
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            let studentObj = result[0] as! NSManagedObject
            currentStudent.name = studentObj.valueForKey("name") as! String
            currentStudent.course = studentObj.valueForKey("course") as! String
            currentStudent.helpMessage = studentObj.valueForKey("helpmessage") as! String
            currentStudent.netID = studentObj.valueForKey("netid") as! String
            managedContext?.deleteObject(result[0] as! NSManagedObject)
        } catch {
            print("error fetching \(currentStudent.netID)")
        }
        do {
            try managedContext?.save()
        } catch {
            print("error saving context after deleting \(currentStudent.netID)")
        }

        //HTTP REQUEST
        let url = NSURL(string: "\(hostName)/LabQueue/v2/\(globalNetId)/Requests/\(currentStudent.netID)/Canceled")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        //request.allHTTPHeaderFields = ["SyncToken": "iuhdfivuhdfiuvh"]
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
        }
        task.resume()
        //END HTTP REQUEST
        
        /*update currentQueue and UI*/
        queueTable.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
        queueTable.reloadData()
    }
}
