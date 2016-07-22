//
//  PostReportHomeViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/20/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

@IBDesignable class PostReportHomeViewController: UIViewController {
    var report: [String : String?] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    
    @IBAction func ASelected(sender: UIButton) {
        self.performSegueWithIdentifier("ASelected", sender: nil)
    }
    @IBAction func BSelected(sender: UIButton) {
        self.performSegueWithIdentifier("BSelected", sender: nil)
    }
}
