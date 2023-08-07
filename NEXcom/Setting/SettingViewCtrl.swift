//
//  SettingViewCtrl.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/23.
//

import UIKit
import linphonesw
import SwiftUI
import CloudPushSDK
import SafariServices
import NHFoundation

class SettingViewCtrl: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var l_state: UILabel!
    @IBOutlet var v_tb_head: UIView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var v_state: UIView!
    @IBOutlet weak var l_unstate: UILabel!
    @IBOutlet weak var ima_head: UIImageView!
    @IBOutlet weak var v_info: UIView!
    @IBOutlet weak var l_name: UILabel!
    @IBOutlet weak var btn_head: UIButton!
    @IBOutlet weak var tb_main: UITableView!
    
    var myinformation : [String:String] {
        UserDefaults.standard.dictionary(forKey: "myinfo") as? [String:String] ?? [:]
    }
    
    var list: [String] {
        [
            nh_localizedString(forKey: "voiceSet"),
            nh_localizedString(forKey: "videoSet"),
            nh_localizedString(forKey: "agreement"),
            nh_localizedString(forKey: "permissions"),
            nh_localizedString(forKey: "about_us"),
            nh_localizedString(forKey: "Disconnect")
        ]
    }
    var list_img: [String] {
        [
            "AudioSet",
            "VideoSet",
            "Agreement",
            "Permissions",
            "about",
            "Disconnect"
        ]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.sipInfo()
        // 监听账号状态
        NotificationCenter.default.addObserver(self, selector: #selector(self.accountStateChanged(_:)), name: .init(rawValue: AccountStateChangedNoticeName), object: nil)
       
    }

    
    @objc func sipSetAction(){
        let sipCtrl = SIPSettingViewController()
        sipCtrl.hidesBottomBarWhenPushed = true
        sipCtrl.myInfoBlock = {
            self.v_state.backgroundColor = NHVoipManager.it.mAccount?.loginState == .Ok ? .green : .red
            self.lb_name.text = "SIP:" + (NHVoipManager.it.mAccount?.username ?? "")
            self.l_name.text = $0
            self.l_unstate.isHidden = true
            self.v_info.isHidden = false
            self.tb_main.reloadData()
        }
        self.navigationController?.pushViewController(sipCtrl, animated: true)
    }
    
    @objc func accountStateChanged(_ noti: Notification) {
        self.v_state.backgroundColor = NHVoipManager.it.mAccount?.loginState == .Ok ? .green : .red
        self.l_state.text =  NHVoipManager.it.mAccount?.loginState == .Ok ? nh_localizedString(forKey: "on_line") : nh_localizedString(forKey: "login_now")
           
            self.ima_head.image = UIImage.init(named: "card_user")
        if NHVoipManager.it.mAccount?.loginState == .Ok {
            self.l_unstate.isHidden = true
            self.v_info.isHidden = false
            ///记录当前登录状态 用于appdelegate判断
            let loginState:[Bool] = [false,false,false]
            UserDefaults.standard.setValue(loginState, forKey: "loginState")
            UserDefaults.standard.synchronize()
        } else {
            if myinformation == [:] {
                self.l_unstate.isHidden = false
                self.v_info.isHidden = true
            } else {
                self.l_unstate.isHidden = true
                self.v_info.isHidden = false
            }
            
        }
        self.tb_main.reloadData()
    }

    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "ffffff")
        btn_head.addTarget(self, action: #selector(SettingViewCtrl.sipSetAction) , for: .touchUpInside)        
        self.v_state.layer.cornerRadius = self.v_state.layer.bounds.height / 2.0
        self.v_state.layer.masksToBounds = true
        l_unstate.text = nh_localizedString(forKey: "no_login")
        if NHVoipManager.it.mAccount?.loginState == .Ok {
            self.l_unstate.isHidden = true
            self.v_info.isHidden = false
        } else {
            if myinformation == [:] {
               
                self.l_unstate.isHidden = false
                self.v_info.isHidden = true
            } else {
                self.l_unstate.isHidden = true
                self.v_info.isHidden = false
            }
            
        }
        self.tb_main.backgroundColor = .groupTableViewBackground
        self.tb_main.register(.init(nibName: "SetTableViewCell", bundle: nil), forCellReuseIdentifier: "SetTableViewCell")
//        self.tb_main.estimatedRowHeight = 0;
//        self.tb_main.estimatedSectionHeaderHeight = 0;
//        self.tb_main.estimatedSectionFooterHeight = 0;
        if #available(iOS 15.0, *) {
            tb_main.sectionHeaderTopPadding = 0;
        }
        self.tb_main.isScrollEnabled = false
        self.tb_main.tableHeaderView = self.v_tb_head
        self.tb_main.tableFooterView = UIView()
    }
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 1
        }else if section == 0 {
            return 2
        } else {
            return 3
        }
    }
    func sipInfo() {
        self.l_state.text =  NHVoipManager.it.mAccount?.loginState == .Ok ? nh_localizedString(forKey: "on_line") : nh_localizedString(forKey: "login_now")
        
        self.l_name.text = myinformation["displayName"]
        self.lb_name.text = "SIP:" + (myinformation["account"] ?? "")
      
       
        self.v_state.backgroundColor = NHVoipManager.it.mAccount?.loginState == .Ok ? .green : .red
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let num = indexPath.row+indexPath.section*2
        let cell:SetTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SetTableViewCell", for: indexPath) as! SetTableViewCell
        cell.imv_icon.image = .init(named: self.list_img[num])
        cell.lb_title.text = self.list[num]
        if indexPath.section == 2 {
            if NHVoipManager.it.mAccount?.loginState == .Ok {
                cell.imv_icon.image = .init(named: self.list_img[5])
                cell.lb_title.text = self.list[5]
                cell.separatorInset = .init(top: 0, left: 1000, bottom: 0, right: 0)
                cell.isHidden = false
            } else {
                
                cell.isHidden = true
            }
            
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.v_separator.isHidden = false
            }
        }
        if indexPath.section == 1 {
            if indexPath.row != 2 {
                cell.v_separator.isHidden = false
            }
        }

        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v_head = UIView()
        v_head.backgroundColor = .clear
        return v_head
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {  return 8 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 52 }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let ctrl = [AudioSettingViewCtrl(), VideoSettingViewCtrl()][indexPath.row]
            ctrl.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(ctrl, animated: true)
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
//                if let url = URL.init(string: getCurrentPrivacyUrlString()) {
//                    let ctrl = SFSafariViewController.init(url: url)
//                    self.navigationController?.present(ctrl, animated: true, completion: nil)
//                }
                let ctrl = PermissionViewController()               
                ctrl.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(ctrl, animated: true)
            } else if indexPath.row == 1 {
                let ctrl = PowerViewController()
                ctrl.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(ctrl, animated: true)
            } else {
                let ctrl = AboutViewController()
                ctrl.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(ctrl, animated: true)
            }
        } else {
            let ctrl = DisconnectViewController()
            ctrl.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(ctrl, animated: true)
        }
    }
   

}
