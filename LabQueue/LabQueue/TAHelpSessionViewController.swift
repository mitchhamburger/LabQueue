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
@IBDesignable class TAHelpSessionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var picBorder: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var studentInfoTable: UITableView!
    @IBOutlet weak var studentPic: UIImageView!
    
    var currentStudent: Student = Student(name: "", helpMessage: "", course: "", netid: "", requestID: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentInfoTable.dataSource = self
        self.studentInfoTable.delegate = self
        UISetup()
    }
    
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected \(indexPath.row)")
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "Name"
            cell.sectionContent.text = currentStudent.name
            return cell
        case 1:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "Course"
            cell.sectionContent.text = currentStudent.course
            return cell
        case 2:
            let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell")! as! TAStudentInfoSingleLineCell
            cell.sectionHeader.text = "NetID"
            cell.sectionContent.text = currentStudent.netID
            return cell
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
    
    func getStudentPic(netid: String) {
        
        let url: NSURL = NSURL(string: "https://tigerbook-sandbox.herokuapp.com/images/\(netid)")!
        
        let headers = getWSSEHeaders()
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL, headers: headers).responseImage { (result) -> Void in
            self.studentPic.image = result.result.value
        }
    }
    
    @IBAction func canceledPushed(sender: UIButton) {
        //HTTP REQUEST
        Alamofire.request(.GET, "\(hostName)/LabQueue/v2/\(globalNetId)/Requests/\(currentStudent.requestID)/Canceled")
        //END HTTP REQUEST
        //self.navigationController?.popViewControllerAnimated(true)
        self.performSegueWithIdentifier("ToCanceledReport", sender: nil)
    }
    
    @IBAction func resolvedPushed(sender: UIButton) {
        //self.navigationController?.popViewControllerAnimated(true)
        self.performSegueWithIdentifier("ToPostReport", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

