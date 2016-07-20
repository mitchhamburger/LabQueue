//
//  StudentHelpSessionViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/12/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
import Alamofire
import Cosmos


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
    
    @IBOutlet weak var ratingView: CosmosView!
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
        UISetup()
    }
    
    func UISetup() {
        getStudentPic(ta.netID!)
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
    
    func getStudentPic(netid: String) {
        
        let url: NSURL = NSURL(string: "https://tigerbook-sandbox.herokuapp.com/images/\(netid)")!
        
        let username = "mh20"
        let secret_key = "464f7aa98c61699a2c5682dd518d54e9"
        let temp = NSUUID().UUIDString
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let timestring = dateFormatter.stringFromDate(NSDate())
        let nonce = temp.stringByReplacingOccurrencesOfString("-", withString: "")
        let digest = sha256(nonce + timestring + secret_key)
        
        let headers: [String:String] = [
            "Authorization": "WSSE profile=\"UsernameToken\"",
            "X-WSSE": "UsernameToken Username=\"\(username)\", PasswordDigest=\"\(digest!)\", Nonce=\"\(nonce)\", Created=\"\(timestring)\""
        ]
        
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL, headers: headers).responseImage { (result) -> Void in
            self.studentPic.image = result.result.value
        }
    }
    
    @IBAction func resolvedPushed(sender: UIButton) {
        Alamofire.request(.GET, "\(hostName)/LabQueue/v2/\(ta.netID!)/TAs/\(ratingView.rating)/addRating")
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

