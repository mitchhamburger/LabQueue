//
//  TAStudentInfoSingleLineCell.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 7/11/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

/// Custom Cell Class for queue in TA studentinfo interface.
///
/// Attributes:
/// * sectionContent: content in a given cell
/// * sectionHeader: header of a given cell
class TAStudentInfoSingleLineCell: UITableViewCell {
    
    @IBOutlet weak var sectionContent: UILabel!
    
    @IBOutlet weak var sectionHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}