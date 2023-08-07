//
//  SIPSet1TableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/9/20.
//

import UIKit

class SIPSet1TableViewCell: UITableViewCell {

    @IBOutlet weak var lb_dispaly: UILabel!
    @IBOutlet weak var tf_content: UITextField!
    
    /// 输入文本回调
    public var valueBlock:((_ text:String?)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tf_content.addTarget(self, action: #selector(self.tfEditingChanged), for: .editingChanged)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func tfEditingChanged() {
        let value = self.tf_content.text
        self.valueBlock?(value)
    }
    
    
    
}
