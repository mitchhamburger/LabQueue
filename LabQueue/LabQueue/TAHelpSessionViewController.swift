//
//  TAHelpSessionViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/11/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage

///  Help Session View Controller for when a TA accepts a student
///
///  Information available:
///
///  1. student picture
///  2. student name
///  3. help request
///  4. course
///  5. netid
@IBDesignable class TAHelpSessionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var picBorder: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var studentInfoTable: UITableView!
    @IBOutlet weak var studentPic: UIImageView!
    
    //the student that the TA is helping
    var currentStudent: Student = Student(name: "", helpMessage: "", course: "", netid: "", requestID: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentInfoTable.dataSource = self
        self.studentInfoTable.delegate = self
        UISetup()
    }
    
    // set up User Interface
    func UISetup() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        getStudentPic(currentStudent.netID)
        studentPic.layer.cornerRadius = studentPic.frame.size.width / 2
        studentPic.clipsToBounds = true
        studentPic.layer.borderWidth = 0.1
        studentPic.layer.borderColor = UIColor.clearColor().CGColor
        
        self.studentInfoTable.tableFooterView = UIView()
        
        self.studentInfoTable.rowHeight = UITableViewAutomaticDimension
        self.studentInfoTable.estimatedRowHeight = 200
        picBorder.layer.cornerRadius = picBorder.frame.size.width / 2
        picBorder.layer.borderWidth = 1
        picBorder.layer.borderColor = UIColor(netHex: 0xe1e1e1).CGColor
        toolBar.backgroundColor = UIColor(netHex:0x4183D7)
        self.title = "You are currently helping \(currentStudent.name)"
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let toolBarBorder = UIView(frame: CGRect(x: 0, y: self.view.frame.height - toolBar.frame.height, width: self.view.frame.width, height: 5))
        toolBarBorder.layer.backgroundColor = UIColor(netHex: 0x3B7CD1).CGColor
        toolBarBorder.layer.cornerRadius = 2
        self.view.addSubview(toolBarBorder)
    }
    
    //number of cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    //what happens when you select a cell?
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected \(indexPath.row)")
    }
    
    //configure each cell in the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        
        //student name cell
        case 0:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "Name"
            cell.sectionContent.text = currentStudent.name
            return cell
            
        //student course cell
        case 1:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "Course"
            cell.sectionContent.text = currentStudent.course
            return cell
            
        //student netid cell
        case 2:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "NetID"
            cell.sectionContent.text = currentStudent.netID
            return cell
            
        //student help message cell
        case 3:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "Help Message"
            cell.sectionContent.text = currentStudent.helpMessage
            return cell
            
        default:
            print("somehow it got here")
        }
        return TAStudentInfoSingleLineCell()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPostReport" {
            let dest = segue.destinationViewController as! TAPostReportViewController
            dest.requestName = currentStudent.name
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
    /// get student's picture from NetID using TigerBook API
    func getStudentPic(netid: String) {
        
        let url: NSURL = NSURL(string: "https://tigerbook-sandbox.herokuapp.com/images/\(netid)")!
        
        let headers = getWSSEHeaders()
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL, headers: headers).responseImage { (result) -> Void in
            self.studentPic.image = result.result.value
        }
    }
    
    /// handles when the TA selects "Canceled"
    @IBAction func canceledPushed(sender: UIButton) {
        Alamofire.request(.GET, "\(hostName)/LabQueue/v2/\(globalNetId)/Requests/\(currentStudent.requestID)/Canceled")
        //self.navigationController?.popViewControllerAnimated(true)
        self.performSegueWithIdentifier("ToCanceledReport", sender: nil)
    }
    
    /// handles when the TA selects "Resolved"
    @IBAction func resolvedPushed(sender: UIButton) {
        self.performSegueWithIdentifier("ShowPostReport", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

