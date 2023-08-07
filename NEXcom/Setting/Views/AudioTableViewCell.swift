//
//  AudioTableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/12/6.
//

import UIKit

class AudioTableViewCell: UITableViewCell {

    @IBOutlet weak var l_up: UILabel!
    @IBOutlet weak var v_touch: UIView!
    @IBOutlet weak var l_type: UILabel!
    @IBOutlet weak var bt_switch: UIButton!
    public var audioBlock:((_ text:String?)->Void)?
    var listRowValue: [String:Bool] {
        if UserDefaults.standard.dictionary(forKey: "audioValue") == nil {
            return [ "pcma":true, "g722":true, "pcmu":true ]
        } else {
            
            return UserDefaults.standard.dictionary(forKey: "audioValue") as? [String:Bool] ?? [ "pcma":true, "g722":true, "pcmu":true]
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
       
        bt_switch.addTarget(self, action: #selector(self.stateChange), for: .touchUpInside)
        self.bt_switch.setImage(UIImage.init(named: "switch_off"), for: .normal)
        self.bt_switch.setImage(UIImage.init(named: "switch_on"), for: .selected)
        // Configure the view for the selected state
    }
    @objc func stateChange(){
        self.audioBlock?(self.l_type.text)
        
    }
    
}
