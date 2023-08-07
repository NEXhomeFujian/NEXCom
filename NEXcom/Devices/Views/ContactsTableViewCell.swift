//
//  ContactsTableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/10/9.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var l_name: UILabel!
    @IBOutlet weak var ima_type: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
