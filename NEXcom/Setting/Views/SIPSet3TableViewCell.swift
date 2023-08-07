//
//  SIPSet3TableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/9/20.
//

import UIKit

class SIPSet3TableViewCell: UITableViewCell {

    @IBOutlet weak var tf_content: UITextField!
    @IBOutlet weak var lb_dispaly: UILabel!
    public var valueServeBlock:((_ text:String?)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @objc func tfEditingChanged() {
        let value = self.tf_content.text
        self.valueServeBlock?(value)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.tf_content.addTarget(self, action: #selector(self.tfEditingChanged), for: .editingChanged)
        // Configure the view for the selected state
    }
    
}
