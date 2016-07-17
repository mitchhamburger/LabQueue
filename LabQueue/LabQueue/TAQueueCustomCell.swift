//
//  TAQueueCustomCell.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/11/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

/// Custom Cell Class for queue in TA interface.
///
/// Attributes:
/// * studentName: name of student
/// * acceptButton: green checkmark to appear if student
/// is first in line
/// * rejectButton: red X to appear if student is first
/// in line
class TAQueueCustomCell: UITableViewCell {
    
    @IBOutlet weak var studentHelpMessage: TopAlignedLabel!
    @IBOutlet weak var studentCourse: CourseLabel!
    @IBOutlet weak var studentName: UILabel!
    //@IBOutlet weak var studentEmail: UILabel!
    var studentID: String = ""
    override func awakeFromNib() {
        studentCourse.layer.cornerRadius = 10
        studentCourse.backgroundColor = UIColor.lightGrayColor()
        studentCourse.clipsToBounds = true
        
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}