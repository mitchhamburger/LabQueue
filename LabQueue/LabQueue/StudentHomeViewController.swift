//
//  StudentHomeViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//


import UIKit
@IBDesignable

class StudentHomeViewController: UIViewController {
    
    @IBOutlet weak var queueTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func addNamePushed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("NewFormViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
}