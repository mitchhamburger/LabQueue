//
//  TAQueueCustomCell.swift
//  LabQueue
//
//  Created by Mitch Hamburger on 6/11/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit

class TAQueueCustomCell: UITableViewCell {
    
    //@IBOutlet weak var studentEmail: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}