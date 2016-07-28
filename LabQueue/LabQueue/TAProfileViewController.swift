//
//  TAProfileViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/26/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
import Alamofire

class TAProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var picBorder: UIView!
    
    @IBOutlet weak var studentPic: UIImageView!
    
    @IBOutlet weak var studentInfoTable: UITableView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    var ta: LabTA = LabTA()
    var totalStudents = 0
    var favoriteCourse = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentInfoTable.dataSource = self
        self.studentInfoTable.delegate = self
        getTAStats(globalNetId)
        UISetup()
    }
    
    func UISetup() {
        getStudentPic(ta.netID)
        //self.navigationItem.setHidesBackButton(true, animated: false)
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
        self.title = "More info about \(self.ta.name)"
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let toolBarBorder = UIView(frame: CGRect(x: 0, y: self.view.frame.height - toolBar.frame.height, width: self.view.frame.width, height: 5))
        toolBarBorder.layer.backgroundColor = UIColor(netHex: 0x3B7CD1).CGColor
        toolBarBorder.layer.cornerRadius = 2
        self.view.addSubview(toolBarBorder)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("hi")
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.studentInfoTable.dequeueReusableCellWithIdentifier("singlelinecell") as! TAStudentInfoSingleLineCell
        
        switch indexPath.row {
            case 0:
                cell.sectionHeader.text = "Name"
                cell.sectionContent.text = ta.name
            case 1:
                cell.sectionHeader.text = "NetID"
                cell.sectionContent.text = ta.netID
            case 2:
                cell.sectionHeader.text = "Total Students Helped"
                cell.sectionContent.text = "\(self.totalStudents)"
            case 3:
                cell.sectionHeader.text = "Average Help Time"
                cell.sectionContent.text = "10 Minutes, 11 Seconds"
            case 4:
                cell.sectionHeader.text = "Favorite Course"
                cell.sectionContent.text = self.favoriteCourse
            default:
                print("somehow it got here")
        }
        
        return cell
    }
    
    func getStudentPic(netid: String) {
        
        let url: NSURL = NSURL(string: "https://tigerbook-sandbox.herokuapp.com/images/\(netid)")!
        
        let headers = getWSSEHeaders()
        
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL, headers: headers).responseImage { (result) -> Void in
            self.studentPic.image = result.result.value
        }
    }
    
    func getTAStats(netid: String) {
        let url: NSURL = NSURL(string: "\(hostName)/LabQueue/v2/\(ta.netID)/TAs/getStats")!
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL).responseJSON {
            (result) -> Void in
            let json = result.result.value
            self.favoriteCourse = json!["stats"]!!["Favorite Course"] as! String
            self.totalStudents = json!["stats"]!!["Total Students"] as! Int
            self.studentInfoTable.reloadData()
        }
    }
}
