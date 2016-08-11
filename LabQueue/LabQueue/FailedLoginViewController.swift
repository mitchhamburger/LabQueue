//
//  FailedLoginViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 8/10/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
import SCLAlertView


class FailedLoginViewController: UIViewController {
    
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @IBAction func refreshTapped(sender: UIButton) {
        if verify(globalNetId) == "TA" {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(globalNetId, forKey: "UserNetID")
            registerForPushNotifications(UIApplication.sharedApplication())
            self.performSegueWithIdentifier("ShowTA", sender: nil)
        }
        else if verify(globalNetId) == "Student" {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(globalNetId, forKey: "UserNetID")
            registerForPushNotifications(UIApplication.sharedApplication())
            self.performSegueWithIdentifier("ShowStudent", sender: nil)
        }
        else {
            SCLAlertView().showInfo("Verification Failed", subTitle: "Check your internet connection and try again.")
        }
    }
}
