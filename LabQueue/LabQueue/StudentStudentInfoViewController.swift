//
//  StudentStudentInfoViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/13/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

///  View Controller to display info about inidivudal
///  students that is available to other students.
///
///  Information available:
///
///  1. place in queue
///  2. student name
///  3. student email
///  4. course that student is in
@IBDesignable class StudentStudentInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var currentStudent: Student = Student(name: "", helpMessage: "", course: "", netid: "", requestID: 0)
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var studentPic: UIImageView!
    @IBOutlet weak var picBorder: UIView!
    @IBOutlet weak var studentInfoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentInfoTable.dataSource = self
        self.studentInfoTable.delegate = self
        UISetup()
    }
    
    func UISetup() {
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
        //self.navigationController?.title = "More info about \(currentStudent.name)"
        self.title = "More info about \(currentStudent.name)"
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let toolBarBorder = UIView(frame: CGRect(x: 0, y: self.view.frame.height - toolBar.frame.height, width: self.view.frame.width, height: 5))
        toolBarBorder.layer.backgroundColor = UIColor(netHex: 0x3B7CD1).CGColor
        toolBarBorder.layer.cornerRadius = 2
        self.view.addSubview(toolBarBorder)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}








