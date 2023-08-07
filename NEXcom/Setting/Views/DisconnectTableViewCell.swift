//
//  DisconnectTableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/12/9.
//

import UIKit

class DisconnectTableViewCell: UITableViewCell {
    @IBOutlet weak var v_out: UIView!
    
    @IBOutlet weak var l_text: UILabel!
    @IBOutlet weak var v_in: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
