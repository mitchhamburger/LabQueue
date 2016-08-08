//
//  TAPostReportQuestionCell.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 8/2/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class TAPostReportQuestionCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: TopAlignedLabel!
    
    var radioController: SSRadioButtonsController = SSRadioButtonsController()
    
    var optionCount: Int {
        get{
            if question.isEmpty != true {
                return ((question["options"] as! NSArray).count)
            }
            else {
                return 0
            }
        }
    }
    
    var question: [String: AnyObject] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setup() -> [SSRadioButton] {
        var allButtons: [SSRadioButton] = [SSRadioButton]()
        for i in 0...optionCount - 1 {
            let button = SSRadioButton(frame: CGRect(x: 157, y: 19 + 39 * i, width: 163, height: 31))
            button.circleRadius = 7
            button.circleColor = UIColor(netHex: 0x3B7CD1)
            
            let attributes = [NSStrokeColorAttributeName: UIColor.darkGrayColor(),
                NSForegroundColorAttributeName: UIColor.darkGrayColor(),
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!
            ]
            let attrString = NSAttributedString(string: (question["options"] as! [String])[i], attributes: attributes)
            button.setAttributedTitle(attrString, forState: UIControlState.Normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.superview?.translatesAutoresizingMaskIntoConstraints = false
            

            self.addSubview(button)
            
            if i == 0 {
                let right = NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: button.superview!, attribute: .TrailingMargin, multiplier: 1, constant: 0)
                NSLayoutConstraint.activateConstraints([right])
                let left = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: questionLabel, attribute: .Trailing, multiplier: 1, constant: 17)
                NSLayoutConstraint.activateConstraints([left])
                let top = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: button.superview!, attribute: .TopMargin, multiplier: 1, constant: 8)
                NSLayoutConstraint.activateConstraints([top])
            }
            else {
                let right = NSLayoutConstraint(item: button.superview!, attribute: .TrailingMargin, relatedBy: .Equal, toItem: button, attribute: .Trailing, multiplier: 1, constant: 0)
                NSLayoutConstraint.activateConstraints([right])
                let top = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: allButtons[i - 1], attribute: .Bottom, multiplier: 1, constant: 0)
                NSLayoutConstraint.activateConstraints([top])
                let width = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: allButtons[0], attribute: .Width, multiplier: 1, constant: 0)
                NSLayoutConstraint.activateConstraints([width])
            }
            allButtons.append(button)
            
        }
        return allButtons
    }
}
