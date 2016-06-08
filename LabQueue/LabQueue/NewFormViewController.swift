//
//  NewFormViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
@IBDesignable

class NewFormViewController: UIViewController {

    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var problemField: UITextField!
    
    @IBOutlet weak var courseField: UITextField!
    
    
    @IBAction func submitForm(sender: UIButton) {
        /*submit POST request with name, problem, course, email, etc*/
        
        
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("StudentHomeViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
}
