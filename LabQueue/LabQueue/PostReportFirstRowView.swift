//
//  PostReportFirstRowView.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/27/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class PostReportFirstRowView: UIView, SSRadioButtonControllerDelegate {
    
    @IBOutlet weak var optionA: SSRadioButton?
    @IBOutlet weak var optionB: SSRadioButton?
    var radioButtonController: SSRadioButtonsController?
    //var parentVC: PostReportViewController?
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //parentVC = storyboard.instantiateViewControllerWithIdentifier("postreportviewcontroller") as? PostReportViewController
        //parentVC?.firstRowView = self
        radioButtonController = SSRadioButtonsController(buttons: optionA!, optionB!)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = false
        
    }
    func didSelectButton(aButton: UIButton?) {
        //parentVC?.firstTicked((aButton?.titleLabel?.text!)!)
        NSNotificationCenter.defaultCenter().postNotificationName(firstRowSelect, object: self, userInfo: ["val": (aButton?.titleLabel?.text!)!])
    }
}
