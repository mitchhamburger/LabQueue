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
    var students = [Student]()
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TAHomeViewController.silentRemove), name: removeStudentFromQueue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TAHomeViewController.silentAdd), name: addStudentToQueue, object: nil)
        studentPicture.layer.cornerRadius = studentPicture.frame.size.width / 2;
        studentPicture.clipsToBounds = true
        studentPicture.layer.borderWidth = 2
        studentPicture.layer.borderColor = UIColor.blackColor().CGColor
        studentPicture.image = UIImage(named: "mitch pic.jpg")
        getQueueData("\(hostName)/LabQueue/v1/Queue")
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
        self.queueTable.layer.borderWidth = 2
        self.queueTable.layer.cornerRadius = 10
        self.queueTable.separatorColor = UIColor.blackColor()
        allStudents = students
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let studentData = prefs.objectForKey("TACurrentStudent") {
            let student = NSKeyedUnarchiver.unarchiveObjectWithData(studentData as! NSData) as! Student
            titleBar.topItem?.title = "Your Current Student is " + student.name
            TACurrentStudent = student
        }
        else {
            titleBar.topItem?.title = "Welcome to Lab TAs!"
        }
        syncQueue()
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
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("TAcustomcell")! as! TAQueueCustomCell
        cell.studentName.text = "\(indexPath.row + 1). " + self.students[indexPath.row].name
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
        
        self.students[indexPath.row].placeInQueue = indexPath.row + 1
        self.performSegueWithIdentifier("ToSpecificStudent", sender: self.students[indexPath.row])
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ToSpecificStudent") {
            let dest = segue.destinationViewController as! TAStudentInfoViewController
            dest.currentStudent = sender as! Student
            //dest.eventId = sender as! Int
            //dest.eventId = sender as! String
            
        }
        else if (segue.identifier == "ShowCurrentStudent") {
            let dest = segue.destinationViewController as! TAStudentInfoViewController
            dest.currentStudent = TACurrentStudent
            dest.isCurrentStudent = true
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
                        let thisStudent: Student = Student(name: student["Name"] as! String, helpMessage: student["Help Message"] as! String, course: student["Course"] as! String, netid: student["NetID"] as! String)
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
        
        /*let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let taEntity = NSEntityDescription.entityForName("LabTA", inManagedObjectContext: managedContext!)
        //DUMMY DATA
        //createDummyData()
        
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

    /// Helper function for if I use Core Data, creates
    /// a couple of entries for students
    func createDummyData() {
        //CREATE DUMMY DATA
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let student1: Student = Student(name: "Mitch Hamburger", helpMessage: "I don't know how to code", course: "COS 126", netid: "")
        student1.netID = "mh20"
         
        let student2: Student = Student(name: "Jason Hamburger", helpMessage: "I don't go to this school", course: "Arizona", netid: "")
        student2.netID = "jh45"
         
        let student3: Student = Student(name: "Rachel Hamburger", helpMessage: "What?", course: "COS 226", netid: "")
        student3.netID = "goldraerae"
         
        let dummyData = [student1, student2, student3]
         
        for tempStudent in dummyData {
        let inputStudentObj = NSManagedObject(entity: studentEntity!, insertIntoManagedObjectContext: managedContext)
        inputStudentObj.setValue(tempStudent.name, forKey: "name")
        inputStudentObj.setValue(tempStudent.helpMessage, forKey: "helpmessage")
        inputStudentObj.setValue(tempStudent.course, forKey: "course")
        inputStudentObj.setValue(tempStudent.netID, forKey: "netid")
         
        do {
        try inputStudentObj.managedObjectContext?.save()
        } catch {
        print("error on \(tempStudent.netID)")
        }
        }
    }
    
    /// Handles when a TA accepts a student. Queries the API
    /// and and removes the student from the visible queue
    @IBAction func acceptStudent(sender: UIButton) {
        
        let currentStudent: Student = students[0]
        
        //WILL PUT NSUSER TA NAME HERE
        let jsonObj = ["Helped Time": "",
                       "Attending TA": globalNetId,
                       "NetID": globalNetId]
        TACurrentStudent = currentStudent
        let prefs = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(currentStudent)
        prefs.setObject(encodedData, forKey: "TACurrentStudent")
        //prefs.setValue(currentStudent, forKey: "TACurrentStudent")
        
        titleBar.topItem?.title = "Your Current Student is " + TACurrentStudent.name
        
        //HTTP REQUEST
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v1/Queue/" + currentStudent.netID + "/Helped")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObj, options: .PrettyPrinted)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
        } catch {
            print("error")
        }
        
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
        
        students.removeFirst()
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        queueTable.reloadData()
        //END HTTP REQUEST
        

        
        /*
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let taEntity = NSEntityDescription.entityForName("LabTA", inManagedObjectContext: managedContext!)
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Configure Fetch Request
        fetchRequest.entity = studentEntity
        let predicate = NSPredicate(format: "%K == %@", "netid", students[0].netID)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            if (result.count > 0) {
                let studentObj: NSManagedObject = result[0] as! NSManagedObject
                
                managedContext?.deleteObject(studentObj)
                
                do {
                    try managedContext!.save()
                } catch {
                    print("error canceling \(students[0].netID)")
                }
                
                //HTTP REQUEST
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
                //END HTTP REQUEST
                
            }
        } catch {
            print("error with fetchrequest")
        }*/
        
        

        //HERE I'M GONNA HAVE TO DO THE MARK AS HELPED POST REQUEST
    }
    
    /// Handles when a TA rejects a student. Queries the API
    /// and and removes the student from the visible queue
    @IBAction func cancelStudent(sender: UIButton) {
        
        //HTTP REQUEST
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v1/Queue/" + students[0].netID + "/Canceled")!
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
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        //END HTTP REQUEST
        students.removeFirst()
        queueTable.beginUpdates()
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        queueTable.endUpdates()
        queueTable.reloadData()
        
        /*
        //CORE DATA CANCELSTUDENT
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let studentEntity = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedContext!)
        let taEntity = NSEntityDescription.entityForName("LabTA", inManagedObjectContext: managedContext!)
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Configure Fetch Request
        fetchRequest.entity = studentEntity
        let predicate = NSPredicate(format: "%K == %@", "netid", students[0].netID)
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext!.executeFetchRequest(fetchRequest)
            if (result.count > 0) {
                let studentObj: NSManagedObject = result[0] as! NSManagedObject
                
                managedContext?.deleteObject(studentObj)
                
                do {
                    try managedContext!.save()
                } catch {
                    print("error canceling \(students[0].netID)")
                }
                
                //HTTP REQUEST
                let url: NSURL = NSURL(string: "http://localhost:5000/LabQueue/v1/Queue/" + students[0].netID + "/Canceled")!
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
                    dispatch_semaphore_signal(semaphore)
                }
                task.resume()
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                //END HTTP REQUEST
                
            }
        } catch {
            print("error with fetchrequest")
        }
        */
        
        
    }
    
    /// Handles when a TA pushes the picutre of his/her current student.
    @IBAction func currenStudentPushed(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowCurrentStudent", sender: TACurrentStudent)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        students.removeFirst()
        queueTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        queueTable.reloadData()
        completionHandler(.NewData)
        // 1
        if (aps["content-available"] as? NSString)?.integerValue == 1 {
            
            }
        else  {
            completionHandler(.NoData)
        }
    }
}
