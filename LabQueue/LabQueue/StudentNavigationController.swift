//
//  StudentNavigationController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/13/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class StudentNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StudentHelpSession" {
            let dest = segue.destinationViewController as! StudentHelpSessionViewController
            dest.ta.netID = sender as? String
            dest.navigationItem.hidesBackButton = true
        }
    }
}
