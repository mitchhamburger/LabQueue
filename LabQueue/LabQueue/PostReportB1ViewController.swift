//
//  PostReportB1ViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/20/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

@IBDesignable class PostReportB1ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    @IBAction func ASelected(sender: UIButton) {
        let report = ["Question 1": "Conceptual",
                      "Question 2": "Yes"]
        print(report)
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    @IBAction func BSelected(sender: UIButton) {
        let report = ["Question 1": "Conceptual",
                      "Question 2": "No"]
        print(report)
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
}
