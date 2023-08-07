//
//  InfoCallTableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/10/17.
//

import UIKit

class InfoCallTableViewCell: UITableViewCell {

    @IBOutlet weak var l_duration: UILabel!
    @IBOutlet weak var l_callTime: UILabel!
    @IBOutlet weak var l_callType: UILabel!
    @IBOutlet weak var ima_coming: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
