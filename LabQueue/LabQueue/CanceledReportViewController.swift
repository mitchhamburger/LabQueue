//
//  CanceledReportViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/21/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class CanceledReportViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    @IBAction func ASelected(sender: UIButton) {
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    @IBAction func BSelected(sender: UIButton) {
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    @IBAction func CSelected(sender: UIButton) {
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
}
