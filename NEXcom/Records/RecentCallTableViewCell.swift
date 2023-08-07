//
//  RecentCallTableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/9/22.
//

import UIKit

class RecentCallTableViewCell: UITableViewCell {

    var clickBlock:(()->Void)?
    
    @IBOutlet weak var b_detail: UIButton!
    
    @IBOutlet weak var b_detail_new: UIButton!
    @IBOutlet weak var ima_type: UIImageView!
    @IBOutlet weak var ima_callType: UIImageView!
    @IBOutlet weak var l_callTime: UILabel!
    @IBOutlet weak var l_type: UILabel!
    @IBOutlet weak var l_name: UILabel!
    var code = ""
    var isLock = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.b_detail_new.addTarget(self, action: #selector(self.clickAction), for: .touchUpInside)
    }
    
    @objc func clickAction() {
        self.clickBlock?()
    }
    
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
