//
//  TAReferenceViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/28/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

extension UIView {
    func rotate(toValue: CGFloat, duration: CFTimeInterval = 0.2, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = duration
        rotateAnimation.removedOnCompletion = false
        rotateAnimation.fillMode = kCAFillModeForwards
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}

class TAReferenceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct Section {
        var name: String!
        var items: [String]!
        var collapsed: Bool!
        
        init(name: String, items: [String], collapsed: Bool = true) {
            self.name = name
            self.items = items
            self.collapsed = collapsed
        }
    }
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    var sections = [Section]()
    
    @IBOutlet weak var referenceTable: UITableView!
    
    var json: AnyObject?
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem()
        barButton.title = ""
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
        
        toolBar.backgroundColor = UIColor(netHex:0x4183D7)
        let toolBarBorder = UIView(frame: CGRect(x: 0, y: self.view.frame.height - toolBar.frame.height, width: self.view.frame.width, height: 5))
        toolBarBorder.layer.backgroundColor = UIColor(netHex: 0x3B7CD1).CGColor
        toolBarBorder.layer.cornerRadius = 2
        self.view.addSubview(toolBarBorder)

        
        let path = NSBundle.mainBundle().pathForResource("AssignmentReference", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        //var json: AnyObject? = nil
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
        } catch {
            print("error getting json")
        }
        
        for course in json!["courses"] as! NSArray {
            var items = [String]()
            for assignment in course["assignments"] as! NSArray {
                items.append(assignment["name"] as! String)
            }
            sections.append(Section(name: course["name"] as! String, items: items))
        }
        
        
        referenceTable.dataSource = self
        referenceTable.delegate = self
        self.referenceTable.tableFooterView = UIView()

    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sections[section].collapsed!) ? 0 : sections[section].items.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = referenceTable.dequeueReusableCellWithIdentifier("header") as! TAReferenceCell
        
        header.toggleButton.tag = section
        header.titleLabel.text = sections[section].name
        header.toggleButton.rotate(sections[section].collapsed! ? 0.0 : CGFloat(M_PI_2))
        header.toggleButton.addTarget(self, action: #selector(TAReferenceViewController.toggleCollapse), forControlEvents: .TouchUpInside)
        
        return header.contentView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = referenceTable.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        
        return cell
    }
    
    //
    // MARK: - Event Handlers
    //
    func toggleCollapse(sender: UIButton) {
        let section = sender.tag
        let collapsed = sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = !collapsed
        
        // Reload section
        referenceTable.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAssignmentInfo" {
            let vc = segue.destinationViewController as! TAReferenceAssignmentInfoViewController
            vc.assignmentInfo = sender
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("you selected this section: \(indexPath.section) and this row: \(indexPath.row)")
        self.performSegueWithIdentifier("ShowAssignmentInfo", sender: (json as! [String: AnyObject])["courses"]![indexPath.section]["assignments"]!![indexPath.row])
        
    }
}
