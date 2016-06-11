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
        titleBar.topItem?.title = "Your Next Student is Mitch"
        allStudents = students
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel!.text = self.students[indexPath.row].name
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("you tapped \(indexPath.row)")
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

    
    @IBAction func nextStudentPushed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("StudentViewController")
        self.showViewController(vc as! UIViewController, sender: vc)


    }
}
