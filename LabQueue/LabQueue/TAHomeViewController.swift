//
//  TAHomeViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
@IBDesignable

class TAHomeViewController: UIViewController {
    
    @IBOutlet weak var queueTable: UITableView!
    
    @IBOutlet weak var titleBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleBar.topItem?.title = "Your Next Student is Mitch"
    }
    
    @IBAction func nextStudentPushed(sender: UIButton) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("StudentViewController")
        self.showViewController(vc as! UIViewController, sender: vc)


    }
}
