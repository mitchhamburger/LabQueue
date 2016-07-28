//
//  PostReportSecondRowView.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/27/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class PostReportSecondRowView: UIView, SSRadioButtonControllerDelegate {
    
    @IBOutlet weak var optionA: SSRadioButton?
    @IBOutlet weak var optionB: SSRadioButton?
    @IBOutlet weak var optionC: SSRadioButton?
    var radioButtonController: SSRadioButtonsController?
    var parentVC: PostReportViewController?
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        parentVC = storyboard.instantiateViewControllerWithIdentifier("postreportviewcontroller") as? PostReportViewController
        parentVC?.secondRowView = self
        radioButtonController = SSRadioButtonsController(buttons: optionA!, optionB!, optionC!)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = false
    }
    func didSelectButton(aButton: UIButton?) {
        NSNotificationCenter.defaultCenter().postNotificationName(secondRowSelect, object: self, userInfo: ["val": (aButton?.titleLabel?.text!)!])
    }

}
