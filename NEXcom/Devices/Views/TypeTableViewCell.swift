//
//  TypeTableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/9/19.
//

import UIKit

class TypeTableViewCell: UITableViewCell {

    @IBOutlet weak var im_type: UIImageView!
    @IBOutlet weak var lb_type: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
