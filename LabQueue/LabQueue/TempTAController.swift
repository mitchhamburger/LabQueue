//
//  TempTAController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class TempTAController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var queueTable: UITableView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queueTable.delegate = self
        queueTable.dataSource = self
        //self.queueTable.rowHeight = 50
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
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("customcell")! as! TempTACell
        cell.studentName.text = "\(indexPath.row + 1). Mitch Hamburger"
        cell.studentCourse.text = "Cos 126"
        cell.helpMessage.text = "I am having a lot of trouble figuring out XCode's for loop functionality? What's the deal? I also want to see how this text fits if it goes onto way more lines than it would usually. What's the deal?"
        cell.helpMessage.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        return cell
    }
}