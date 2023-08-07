//
//  SIPSet2TableViewCell.swift
//  NEXcom
//
//  Created by csh on 2022/9/20.
//

import UIKit

class SIPSet2TableViewCell: UITableViewCell {
    @IBOutlet weak var v_udp: UIView!
    
    @IBOutlet weak var l_tcp: UILabel!
    @IBOutlet weak var l_udp: UILabel!
    @IBOutlet weak var b_udp: UIButton!
    @IBOutlet weak var v_in_udp: UIView!
    @IBOutlet weak var v_out_udp: UIView!
    
    @IBOutlet weak var l_tls: UILabel!
    @IBOutlet weak var b_tls: UIButton!
    @IBOutlet weak var v_tls_in: UIView!
    @IBOutlet weak var v_tls_out: UIView!
    @IBOutlet weak var b_tcp: UIButton!
    @IBOutlet weak var v_tcp_in: UIView!
    @IBOutlet weak var v_tcp_out: UIView!
    @IBOutlet weak var lb_dispaly: UILabel!
    @IBOutlet weak var con_udp: NSLayoutConstraint!
    public var myTransBlock:((_ text:Int?)->Void)?
    var transValue = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func valueTrans(transValue: Int){
        if transValue == 0 {
            changeTrans()
        } else if transValue == 1 {
            changeTcp()
        } else {
            changeTls()
        }
    }
    
     @objc  func changeTrans(){
        initTrans(vout: v_out_udp, vin: v_in_udp, index: 1, lb: l_udp)
        initTrans(vout: v_tcp_out, vin: v_tcp_in, index: 0, lb: l_tcp)
        initTrans(vout: v_tls_out  , vin: v_tls_in  , index: 0, lb: l_tls)
         self.myTransBlock?(0)
    }
    @objc func changeTcp(){
        initTrans(vout: v_out_udp, vin: v_in_udp, index: 0, lb: l_udp)
        initTrans(vout: v_tcp_out, vin: v_tcp_in, index: 1, lb: l_tcp)
        initTrans(vout: v_tls_out  , vin: v_tls_in  , index: 0, lb: l_tls)
        self.myTransBlock?(1)
    }
    @objc func changeTls(){
        initTrans(vout: v_out_udp, vin: v_in_udp, index: 0, lb: l_udp)
        initTrans(vout: v_tcp_out, vin: v_tcp_in, index: 0, lb: l_tcp)
        initTrans(vout: v_tls_out  , vin: v_tls_in  , index: 1, lb: l_tls)
        self.myTransBlock?(2)
    }

    func initTrans(vout:UIView,vin:UIView,index: Int,lb: UILabel){
        vout.layer.cornerRadius = 6
        vin.layer.cornerRadius = 3
        vout.layer.borderWidth = 1
        vin.layer.borderWidth = 1
        vout.backgroundColor = UIColor.white
        if index == 0 {
            vout.layer.borderColor = UIColor(hexString: "cccccc").cgColor
            vin.backgroundColor = UIColor.white
            vin.layer.borderColor = UIColor.white.cgColor
            lb.textColor = UIColor(hexString: "333333")
        } else {
            vout.layer.borderColor = UIColor(hexString: "2864aa").cgColor
            vin.backgroundColor = UIColor(hexString: "2864aa")
            vin.layer.borderColor = UIColor(hexString: "2864aa").cgColor
            lb.textColor = UIColor(hexString: "2864aa")
        }
    }
    
}
