//
//  TempStudentController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class TempStudentController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var timeLabel: UIView!
    
    @IBOutlet weak var queueTable: UITableView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queueTable.delegate = self
        queueTable.dataSource = self
        self.queueTable.rowHeight = 50
        toolBar.backgroundColor = UIColor(netHex:0x4183D7)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
        self.navigationController?.navigationBar.barTintColor = UIColor(netHex:0x4183D7)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected")
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("tempcustomcell")! as! TempStudentQueueCell
        //cell.name.text = "    \(indexPath.row). Mitch Hamburger"
        let normalText = "Mitch Hamburger"
        
        let boldText  = "     \(indexPath.row+1). "
        
        let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
        let boldString = NSMutableAttributedString(string:boldText, attributes:attrs)
        
        let attributedString = NSMutableAttributedString(attributedString: boldString)

        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.appendAttributedString(normalString)
        cell.name.attributedText = attributedString
        return cell
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}