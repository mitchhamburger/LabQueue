//
//  TAHomeViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//


import UIKit
@IBDesignable

class TAHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var studentPicture: StudentPictureView!
    @IBOutlet weak var queueTable: UITableView!
    
    @IBOutlet weak var titleBar: UINavigationBar!
    var items = ["Dog", "Cat", "Cow", "Platypus"]
    var students = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentPicture.layer.cornerRadius = studentPicture.frame.size.width / 2;
        studentPicture.clipsToBounds = true
        studentPicture.layer.borderWidth = 2
        studentPicture.layer.borderColor = UIColor.blackColor().CGColor
        studentPicture.image = UIImage(named: "mitch pic.jpg")
        
        getQueueData("http://localhost:5000/LabQueue/v1/Queue")
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
        self.queueTable.layer.borderWidth = 2
        self.queueTable.layer.cornerRadius = 10
        self.queueTable.separatorColor = UIColor.blackColor()
        allStudents = students
        
        if (TACurrentStudent.name == "") {
            titleBar.topItem?.title = "Welcome to Lab TAs!"
        }
        else {
            titleBar.topItem?.title = "Your Current Student is " + TACurrentStudent.name
        }
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("TAcustomcell")! as! TAQueueCustomCell
        //cell.textLabel!.text = self.students[indexPath.row].name
        cell.studentName.text = "\(indexPath.row + 1). " + self.students[indexPath.row].name
        //cell.studentEmail.text = self.students[indexPath.row].netID + "@princeton.edu"
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
    }
    
    func getQueueData(urlString: String) {
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
                    
                    //let str = json["Queue"]![0]["Name"] as! String
                    
                    //print((json["Queue"]! as! NSArray).count)
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
    }

    
    @IBAction func acceptStudent(sender: UIButton) {
        let currentStudent: Student = students[0]
        TACurrentStudent = currentStudent
        titleBar.topItem?.title = "Your Current Student is " + TACurrentStudent.name
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
            if error == nil && data != nil {
                do {
                    // Convert NSData to Dictionary where keys are of type String, and values are of any type
                    /*let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
                    
                    //let str = json["Queue"]![0]["Name"] as! String
                    
                    //print((json["Queue"]! as! NSArray).count)
                    var count = 0
                    for student in (json["Queue"]! as! NSArray) {
                        let thisStudent: Student = Student(name: student["Name"] as! String, helpMessage: student["Help Message"] as! String, course: student["Course"] as! String)
                        thisStudent.netID = student["NetID"] as! String
                        self.students.append(thisStudent)
                        count += 1
                    }*/
                    
                } catch {
                    // Something went wrong
                }
            }
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        students.removeFirst()
        queueTable.reloadData()
        
        
        
        //HERE I'M GONNA HAVE TO DO THE MARK AS HELPED POST REQUEST
    }
    
    
    @IBAction func cancelStudent(sender: UIButton) {
        let currentStudent: Student = students[0]
        let url: NSURL = NSURL(string: "http://localhost:5000/LabQueue/v1/Queue/" + currentStudent.netID + "/Canceled")!
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
        students.removeFirst()
        queueTable.reloadData()
    }
    
    
    @IBAction func nextStudentPushed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("StudentViewController")
        self.showViewController(vc as! UIViewController, sender: vc)


    }
}
