//
//  VideoTableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/12/8.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var l_set: UILabel!
    @IBOutlet weak var b_more: UIButton!
    @IBOutlet weak var b_set: UIButton!
    @IBOutlet weak var l_type: UILabel!
    public var videoBlock:((_ text:String?)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        b_set.addTarget(self, action: #selector(self.stateChange), for: .touchUpInside)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        // Configure the view for the selected state
    }
    @objc func stateChange(){
        print("nnnnn1")
        self.videoBlock?(self.l_set.text)
        
    }
}
