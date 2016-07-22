//
//  PostReportA1ViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/20/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

@IBDesignable class PostReportA1ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! PostReportA2ViewController
        dest.report["Question 2"] = sender as? String
    }
    @IBAction func ASelected(sender: UIButton) {
        self.performSegueWithIdentifier("PresentA2", sender: "Syntax")
    }
    @IBAction func BSelected(sender: UIButton) {
        self.performSegueWithIdentifier("PresentA2", sender: "Algorithm")
    }
    @IBAction func CSelected(sender: UIButton) {
        self.performSegueWithIdentifier("PresentA2", sender: "Neither")
    }
}