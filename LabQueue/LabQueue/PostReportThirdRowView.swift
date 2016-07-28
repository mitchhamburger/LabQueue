//
//  PostReportThirdRowView.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/27/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.


import UIKit

class PostReportThirdRowView: UIView, SSRadioButtonControllerDelegate {
    
    @IBOutlet weak var optionA: SSRadioButton?
    @IBOutlet weak var optionB: SSRadioButton?
    
    var parentVC: PostReportViewController?
    var radioButtonController: SSRadioButtonsController?
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        parentVC = storyboard.instantiateViewControllerWithIdentifier("postreportviewcontroller") as? PostReportViewController
        parentVC?.thirdRowView = self
        radioButtonController = SSRadioButtonsController(buttons: optionA!, optionB!)
        radioButtonController?.delegate = self
        radioButtonController?.shouldLetDeSelect = false
    }
    func didSelectButton(aButton: UIButton?) {
        NSNotificationCenter.defaultCenter().postNotificationName(thirdRowSelect, object: self, userInfo: ["val": (aButton?.titleLabel?.text!)!])
    }
}
