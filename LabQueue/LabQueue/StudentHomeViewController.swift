//
//  StudentHomeViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//


import UIKit
@IBDesignable

class StudentHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var queueTable: UITableView!
    var items = ["Dog", "Cat", "Cow", "Platypus"]
    var students = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getQueueData("http://localhost:5000/LabQueue/v1/Queue")
        print(students)
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
        //getQueueData("http://localhost:5000/LabQueue/v1/Queue")
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel!.text = self.students[indexPath.row]
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
                        self.students.append(student["Name"] as! String)
                        count += 1
                    }
                    
                } catch {
                    // Something went wrong
                }
            }
            print(self.students)
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }

    @IBAction func addNamePushed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("NewFormViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
}