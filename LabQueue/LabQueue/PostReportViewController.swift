//
//  PostReportViewController.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/27/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class PostReportViewController: UIViewController {
    
    @IBOutlet weak var firstRowView: PostReportFirstRowView!
    
    @IBOutlet weak var secondRowView: PostReportSecondRowView!
    @IBOutlet weak var secondRowLabel: UILabel!
    
    @IBOutlet weak var thirdRowView: PostReportThirdRowView!
    @IBOutlet weak var thirdRowLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var postReport: [String : String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostReportViewController.firstTicked(_:)), name: firstRowSelect, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostReportViewController.secondTicked(_:)), name: secondRowSelect, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostReportViewController.thirdTicked(_:)), name: thirdRowSelect, object: nil)
        
        secondRowView.hidden = true
        secondRowLabel.hidden = true
        thirdRowView.hidden = true
        thirdRowLabel.hidden = true
        submitButton.hidden = true
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func firstTicked(notification: NSNotification) {
        let option = notification.userInfo!["val"] as! String
        if option == "Conceptual" && secondRowView.hidden == false {
            secondRowView.hidden = true
            secondRowLabel.hidden = true
            if let butt = secondRowView.radioButtonController?.selectedButton() {
                (butt as! SSRadioButton).toggleButon()
                //print(butt.titleLabel?.text)
            }
            
            thirdRowView.hidden = false
            thirdRowLabel.hidden = false
            
            hideButton()
        }
        else if option == "Code" && thirdRowView.hidden == false {
            secondRowView.hidden = false
            secondRowLabel.hidden = false
            
            thirdRowView.hidden = true
            thirdRowLabel.hidden = true
            if let butt = thirdRowView.radioButtonController?.selectedButton() {
                (butt as! SSRadioButton).toggleButon()
                //print(butt.titleLabel?.text)
            }
            
            hideButton()
            
        }
        else if option == "Conceptual" {
            thirdRowLabel.hidden = false
            thirdRowView.hidden = false
            
            hideButton()
        }
        else if option == "Code" {
            secondRowView.hidden = false
            secondRowLabel.hidden = false
            
            hideButton()
        }
        
    }
    func secondTicked(notification: NSNotification) {
        let option = notification.userInfo!["val"] as! String
        
        thirdRowLabel.hidden = false
        thirdRowView.hidden = false
        
        hideButton()
    }
    func thirdTicked(notification: NSNotification) {
        let option = notification.userInfo!["val"] as! String
        
        hideButton()
    }
    
    @IBAction func submitPressed(sender: UIButton) {
        if secondRowView.hidden != true {
            postReport = ["Question 1": (firstRowView.radioButtonController?.selectedButton()?.titleLabel?.text)!,
                          "Question 2": (secondRowView.radioButtonController?.selectedButton()?.titleLabel?.text)!,
                          "Question 3": (thirdRowView.radioButtonController?.selectedButton()?.titleLabel?.text)!]
        }
        else {
            postReport = ["Question 1": (firstRowView.radioButtonController?.selectedButton()?.titleLabel?.text)!,
                          "Question 3": (thirdRowView.radioButtonController?.selectedButton()?.titleLabel?.text)!]
        }
        
        print(postReport)
        let vc = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    func hideButton() {
        if thirdRowView.hidden == false && thirdRowView.radioButtonController?.selectedButton() != nil {
            submitButton.hidden = false
        }
        else {
            submitButton.hidden = true
        }
    }
}
