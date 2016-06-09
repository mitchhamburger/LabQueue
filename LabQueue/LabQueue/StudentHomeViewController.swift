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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.queueTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.queueTable.dataSource = self
        self.queueTable.delegate = self
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.queueTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel!.text = self.items[indexPath.row]
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("you tapped \(indexPath.row)")
    }
    @IBAction func addNamePushed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("NewFormViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
}