//
//  TAReferenceAssignmentInfoViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/29/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class TAReferenceAssignmentInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var infoTable: UITableView!
    
    var assignmentInfo: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTable.dataSource = self
        infoTable.delegate = self
        infoTable.rowHeight = UITableViewAutomaticDimension
        infoTable.estimatedRowHeight = 140
        infoTable.tableFooterView = UIView()
        
        
        let barButton = UIBarButtonItem()
        barButton.title = ""
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = assignmentInfo!["info"]!!.count {
            return num
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = infoTable.dequeueReusableCellWithIdentifier("infocell") as! TAReferenceAssignmentInfoCell
        
        cell.shortLabel!.text = (((assignmentInfo!["info"] as! NSArray)[indexPath.row] as! [String: AnyObject])["short"] as! String)
        
        cell.longLabel!.text = (((assignmentInfo!["info"] as! NSArray)[indexPath.row] as! [String: AnyObject])["long"] as! String)

        return cell
    }
}

