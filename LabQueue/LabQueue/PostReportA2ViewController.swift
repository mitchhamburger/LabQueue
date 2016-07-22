//
//  PostReportA2ViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/20/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

@IBDesignable class PostReportA2ViewController: UIViewController {
    var report: [String : String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    @IBAction func BSelected(sender: UIButton) {
        report["Question 1"] = "Code"
        report["Question 3"] = "No"
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
        print(report)
    }
    @IBAction func ASelected(sender: UIButton) {
        report["Question 1"] = "Code"
        report["Question 3"] = "Yes"
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
        print(report)
    }
}
