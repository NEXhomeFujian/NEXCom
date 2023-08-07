//
//  SetTableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/9/16.
//

import UIKit

class SetTableViewCell: UITableViewCell {

    @IBOutlet weak var v_separator: UIView!
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var imv_icon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
