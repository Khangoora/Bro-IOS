//
//  firstTableViewCell.swift
//  Bro
//
//  Copyright (c) 2015 Jaskirat Khangoora. All rights reserved.
//

import UIKit

class firstTableViewCell: UITableViewCell
{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        var myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = UIColor.clearColor()
        self.selectedBackgroundView = myCustomSelectionColorView
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
}