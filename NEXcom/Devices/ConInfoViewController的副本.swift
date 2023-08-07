//
//  ConInfoViewController.swift
//  NEXcom
//
//  Created by csh on 2022/9/27.
//

import UIKit

class ConInfoViewController: UIViewController {

    @IBOutlet weak var b_edit: UIButton!
    @IBOutlet weak var v_down: UIView!
    @IBOutlet weak var btn_monitor: UIButton!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var btn_call_user: UIButton!
    @IBOutlet weak var btn_call_indoor: UIButton!
    @IBOutlet weak var ima_head: UIImageView!
    @IBOutlet weak var l_type: UILabel!
    @IBOutlet weak var l_open: UILabel!
    @IBOutlet weak var l_sip: UILabel!
    @IBOutlet weak var l_name: UILabel!
    var address = ""
    var name = ""
    var imageType = UIImage.init(named: "card_user")
    var type = ""
    var coming = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.v_down.backgroundColor = .groupTableViewBackground
        self.btn_call_indoor.addTarget(self, action: #selector(self.callOut), for: .touchUpInside)
        self.btn_back.addTarget(self, action: #selector(self.backDevices), for: .touchUpInside)
        self.btn_monitor.addTarget(self, action: #selector(self.callOut2), for: .touchUpInside)
        self.btn_call_user.addTarget(self, action: #selector(self.callOut), for: .touchUpInside)
        self.b_edit.addTarget(self, action: #selector(self.editInfo), for: .touchUpInside)
        btn_monitor.layer.cornerRadius = 4
        btn_call_indoor.layer.cornerRadius = 4
        btn_call_user.layer.cornerRadius = 4
        l_name.text = name
        l_sip.text = address
        ima_head.image = imageType
       
        if type == "card_OutdoorMachine" {
            l_open.isHidden = false
            l_type.text = "门口机"
            btn_call_user.isHidden = true
        } else if type == "card_IndoorMachine" {
            l_open.isHidden = true
            btn_call_user.isHidden = false
            btn_call_indoor.isHidden = true
            l_type.text = "室内机"
            btn_monitor.isHidden = true
        } else if type == "card_telephone" {
            l_open.isHidden = true
            btn_call_user.isHidden = false
            btn_call_indoor.isHidden = true
            btn_monitor.isHidden = true
            l_type.text = "SIP话机"
        } else  {
            l_open.isHidden = true
            btn_call_user.isHidden = false
            btn_call_indoor.isHidden = true
            btn_monitor.isHidden = true
        }
    }
    
    @objc func callOut(){
        NHVoipManager.it.isMicrophoneEnabled = true
        let callCtrl = CallOnViewController()
        callCtrl.address = self.address
        callCtrl.coming = false
        callCtrl.name = self.name
      
        callCtrl.type = self.imageType!
        callCtrl.callType = self.type
        callCtrl.modalPresentationStyle = .custom
        self.present(callCtrl, animated: true, completion: nil)
    }
    @objc func editInfo(){
       
        let ctrl = EditContactsViewController()
//        self.navigationController
        ctrl.modalPresentationStyle = .custom
        self.present(ctrl, animated: true, completion: nil)
    }
    @objc func callOut2(){
        NHVoipManager.it.isMicrophoneEnabled = false
        let callCtrl = CallOnViewController()
        callCtrl.address = self.address
        callCtrl.coming = false
        callCtrl.name = self.name
      
        callCtrl.type = self.imageType!
        callCtrl.callType = self.type
        callCtrl.modalPresentationStyle = .custom
        self.present(callCtrl, animated: true, completion: nil)
    }
//    @objc func monitorCall(){
//
//        let callCtrl = CallOnViewController()
//        callCtrl.address = self.address
////        callCtrl.coming = false
//        callCtrl.coming = true
//        callCtrl.name = self.name
//        callCtrl.modalPresentationStyle = .custom
//        self.present(callCtrl, animated: true, completion: nil)
//    }
    @objc func backDevices(){
        self.dismiss(animated: true)
    }


   

}
