//
//  TempStudentQueueCell.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/8/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//
import UIKit

/// Custom Cell Class for queue in student interface.
///
/// Keeps each student's name as UILabel
class TempStudentQueueCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    var studentID: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}