//
//  StudentHelpSessionViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/12/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
import CoreData

///  View Controller to display info about inidivudal
///  students that is available to LAb TA's.
///
///  Information available:
///
///  1. place in queue
///  2. student name
///  3. student email
///  4. course that student is in
///  5. help message
@IBDesignable class StudentHelpSessionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var studentPic: UIImageView!
    @IBOutlet weak var picBorder: UIView!
    @IBOutlet weak var studentInfoTable: UITableView!
    
    var ta: LabTA = LabTA()
    
    var image: UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs = NSUserDefaults.standardUserDefaults()
        ta.netID = prefs.objectForKey("MostRecentTA") as? String
        self.studentInfoTable.dataSource = self
        self.studentInfoTable.delegate = self
        let taInfo = self.getTAInfo(self.ta.netID!)
        //studentPic.image = image
        self.ta.name = taInfo["Name"] as? String
        self.ta.classYear = taInfo["Class Year"] as? Int
        //dispatch_async(dispatch_get_main_queue(), {
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.studentPic.layer.cornerRadius = self.studentPic.frame.size.width / 2
        self.studentPic.clipsToBounds = true
        self.studentPic.layer.borderWidth = 0.1
        self.studentPic.layer.borderColor = UIColor.clearColor().CGColor
        
        self.studentInfoTable.tableFooterView = UIView()
        self.studentInfoTable.rowHeight = UITableViewAutomaticDimension
        self.studentInfoTable.estimatedRowHeight = 200
        self.picBorder.layer.cornerRadius = self.picBorder.frame.size.width / 2
        self.picBorder.layer.borderWidth = 1
        self.picBorder.layer.borderColor = UIColor(netHex: 0xe1e1e1).CGColor
        self.toolBar.backgroundColor = UIColor(netHex:0x4183D7)
        self.title = "\(self.ta.name!) is helping you"
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        //})
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected \(indexPath.row)")
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "Name"
            cell.sectionContent.text = ta.name!
            return cell
        case 1:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "NetID"
            cell.sectionContent.text = ta.netID!
            return cell
        case 2:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "Class Year"
            cell.sectionContent.text = String(ta.classYear!)
            return cell
        default:
            print("somehow it got here")
        }
        return TAStudentInfoSingleLineCell()
    }
    
    func getTAInfo(netid: String) -> [String: AnyObject]{
        var studentPic = ""
        var taInfo: [String: AnyObject] = [:]
        let path = NSBundle.mainBundle().pathForResource("initial_data-2016-1", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        do {
            let jsonResult: NSArray = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            for item in jsonResult {
                if item["fields"]!!["net_id"] as! String == netid {
                    studentPic = item["fields"]!!["photo_link"] as! String
                    //self.ta.classYear = (item["fields"]!!["class_year"] as! Int)
                    //self.ta.name = item["fields"]!!["full_name"] as? String
                    taInfo = ["Class Year": (item["fields"]!!["class_year"] as! Int), "Name": (item["fields"]!!["full_name"] as? String)!]
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
                self.image = UIImage(data: data!)!
            }
        }
        task.resume()*/
        
        return taInfo
    }
    @IBAction func resolvedPushed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

