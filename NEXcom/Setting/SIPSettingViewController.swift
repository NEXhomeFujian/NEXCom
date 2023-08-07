//
//  SIPSettingViewController.swift
//  NexPhone
//
//  Created by csh on 2022/9/14.
//

import UIKit
import SnapKit
import linphonesw
import NHFoundation
class SIPSettingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var btn_save: UIButton!

    @IBOutlet weak var v_main: UITableView!
    
    public var myInfoBlock:((_ name:String)->Void)?
    
    var list_tmp: [String] {
        [
            nh_localizedString(forKey: "displayName"),
            nh_localizedString(forKey: "sipaccount"),
            nh_localizedString(forKey: "sippasswd"),
            nh_localizedString(forKey: "sipserve"),
            nh_localizedString(forKey: "domain"),
            nh_localizedString(forKey: "transportType"),
            nh_localizedString(forKey: "privacy"),
            nh_localizedString(forKey: "expires")

        ]
    }
    var l_place: [String] {
       [ nh_localizedString(forKey: "please_disname"),
        nh_localizedString(forKey: "please_account"),
        nh_localizedString(forKey: "please_pwd"),
        nh_localizedString(forKey: "please_serve"),
        nh_localizedString(forKey: "please_port"),
        nh_localizedString(forKey: "transportType"),
        nh_localizedString(forKey: "please_privacy"),
        nh_localizedString(forKey: "please_expires")]
    }
    lazy var list: [[SIPSetItem]] = [
        [
            self.displayNameSet,
            self.accountSet,
            self.pwdSet,
            self.serveSet,
            self.domainSet
        ],
        [
            self.typeSet,
            self.proxySet,
            self.expiresSet
        ],
    ]
    
    lazy var displayNameSet = SIPSetItem.init(name: nh_localizedString(forKey: "displayName"), value: self.myinformation["displayName"], code: "displayName")
    lazy var accountSet = SIPSetItem.init(name: nh_localizedString(forKey: "sipaccount"), value: self.myinformation["account"], code: "account")
    lazy var pwdSet = SIPSetItem.init(name: nh_localizedString(forKey: "sippasswd"), value: self.myinformation["pwd"], code: "pwd")
    lazy var serveSet = SIPSetItem.init(name: nh_localizedString(forKey: "sipserve"), value: self.myinformation["serve"], code: "serve")
    lazy var domainSet = SIPSetItem.init(name: nh_localizedString(forKey: "port"), value: self.myinformation["port"], code: "port")
    lazy var typeSet = SIPSetItem.init(name: nh_localizedString(forKey: "transportType"), value: self.myinformation["trans"], code: "trans", type: 0)
    lazy var proxySet = SIPSetItem.init(name: nh_localizedString(forKey: "privacy"), value: self.myinformation["privacy"], code: "privacy")
    lazy var expiresSet =  SIPSetItem.init(name: nh_localizedString(forKey: "expires"), value: self.myinformation["regis"], code: "regis")
    var myinformation : [String:String] = UserDefaults.standard.dictionary(forKey: "myinfo") as? [String:String] ?? [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nh_localizedString(forKey: "aedit")
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "f9f9f9")
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .groupTableViewBackground
        self.v_main.register(.init(nibName: "SIPSet1TableViewCell", bundle: nil), forCellReuseIdentifier: "SIPSet1TableViewCell")
        self.v_main.register(.init(nibName: "SIPSet2TableViewCell", bundle: nil), forCellReuseIdentifier: "SIPSet2TableViewCell")
        self.v_main.register(.init(nibName: "SIPSet3TableViewCell", bundle: nil), forCellReuseIdentifier: "SIPSet3TableViewCell")
        v_main.dataSource = self
        v_main.delegate = self
        if #available(iOS 15.0, *) {
            v_main.sectionHeaderTopPadding = 0;
        }
        self.v_main.backgroundColor = .groupTableViewBackground
        self.v_main.tableFooterView = UIView()
        self.btn_save.layer.cornerRadius = 4
        self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
        self.btn_save.isUserInteractionEnabled = false
        // 监听是否手动断开连接
        print("dddd" + (isReconnect == true ? "1" : "0") )
        NotificationCenter.default.addObserver(self, selector: #selector(changeBtn), name: .init(rawValue: "DisconnectNotice"), object: nil)
    }

    @objc func changeBtn(){
        isReconnect = true
        self.btn_save.backgroundColor = UIColor(hexString: "2864aa")
        self.btn_save.isUserInteractionEnabled = true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = self.list[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            let cell:SIPSet1TableViewCell = tableView.dequeueReusableCell(withIdentifier: "SIPSet1TableViewCell", for: indexPath) as! SIPSet1TableViewCell
            if indexPath.row == 2 {
                cell.tf_content.isSecureTextEntry = true
            } else {
                cell.tf_content.isSecureTextEntry = false
            }
            if indexPath.row == 4 {
                cell.tf_content.keyboardType = .numberPad
            }
            cell.tf_content.placeholder =  l_place[indexPath.row]
            cell.lb_dispaly.text = set.name
            cell.tf_content.text = set.value
            set.value = cell.tf_content.text
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            
            if getCurrentLanguage() == "cn" || getCurrentLanguage() == "zh-tw"{
                cell.tf_content.snp.makeConstraints { make in
                    make.edges.left.equalToSuperview().offset(110)
                }
            }
            cell.valueBlock = { set.value = $0
                if let name =  self.list[indexPath.section][0].value,name.count > 0,
                   let account =  self.list[indexPath.section][1].value,account.count > 0,
                   let pwd =  self.list[indexPath.section][2].value,pwd.count > 0,
                   let serve =  self.list[indexPath.section][3].value,serve.count > 0,
                   let domain =  self.list[indexPath.section][4].value,domain.count > 0
                {
                    self.btn_save.backgroundColor = UIColor(hexString: "2864aa")
                    self.btn_save.isUserInteractionEnabled = true
                } else {
                    self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
                    self.btn_save.isUserInteractionEnabled = false
                }
            }
            cell.selectionStyle = .none
            return cell
        } else {
            if indexPath.row == 0 {
                let cell:SIPSet2TableViewCell = tableView.dequeueReusableCell(withIdentifier: "SIPSet2TableViewCell", for: indexPath) as! SIPSet2TableViewCell
                cell.changeTrans()
                cell.lb_dispaly.text = set.name
                if getCurrentLanguage() == "cn" || getCurrentLanguage() == "zh-tw" {
                    cell.con_udp.constant = 110
                }
                set.type = Int(set.value ?? "0") ?? 0
                cell.valueTrans(transValue: set.type ?? 0)
                cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
                cell.b_udp.addTarget(cell, action: #selector(cell.changeTrans), for: .touchUpInside)
                cell.b_tcp.addTarget(cell, action: #selector(cell.changeTcp), for: .touchUpInside)
                cell.b_tls.addTarget(cell, action: #selector(cell.changeTls), for: .touchUpInside)
                cell.myTransBlock = {
                    set.type = $0 ?? 0
                    if let name =  self.list[0][0].value,name.count > 0,
                       let account =  self.list[0][1].value,account.count > 0,
                       let pwd =  self.list[0][2].value,pwd.count > 0,
                       let serve =  self.list[0][3].value,serve.count > 0,
                       let domain =  self.list[0][4].value,domain.count > 0
                    {
                        self.btn_save.backgroundColor = UIColor(hexString: "2864aa")
                        self.btn_save.isUserInteractionEnabled = true
                    } else {
                        self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
                        self.btn_save.isUserInteractionEnabled = false
                    }
                }
                cell.selectionStyle = .none
                return cell
            } else {
                let cell:SIPSet3TableViewCell = tableView.dequeueReusableCell(withIdentifier: "SIPSet3TableViewCell", for: indexPath) as! SIPSet3TableViewCell
                cell.tf_content.placeholder =  l_place[indexPath.row + 5]
                cell.lb_dispaly.text = set.name
                if getCurrentLanguage() == "cn" || getCurrentLanguage() == "zh-tw" {
                    cell.tf_content.snp.makeConstraints { make in
                        make.edges.left.equalToSuperview().offset(110)
                    }
                }
                if indexPath.row == 2  {
                    if set.value == nil {
                        set.value = "1800"
                    }
                   
                        cell.tf_content.keyboardType = .numberPad
                    
                }
                cell.tf_content.text = set.value ?? ""
                set.value = cell.tf_content.text
                cell.valueServeBlock = { set.value = $0
                    if let name =  self.list[0][0].value,name.count > 0,
                       let account =  self.list[0][1].value,account.count > 0,
                       let pwd =  self.list[0][2].value,pwd.count > 0,
                       let serve =  self.list[0][3].value,serve.count > 0,
                       let domain =  self.list[0][4].value,domain.count > 0
                    {
                        self.btn_save.backgroundColor = UIColor(hexString: "2864aa")
                        self.btn_save.isUserInteractionEnabled = true
                    } else {
                        self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
                        self.btn_save.isUserInteractionEnabled = false
                    }
                }
                cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
                cell.selectionStyle = .none
                return cell
            }
        }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int { self.list.count }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        52
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return  0.01
        }
       return  8
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v_head = UIView()
        v_head.backgroundColor = .clear
        return v_head
    }


    @IBAction func saveBtnAction(_ sender: UIButton) {
        let displayName = self.displayNameSet.value ?? ""
        let account = self.accountSet.value ?? ""
        let pwd = self.pwdSet.value ?? ""
        let serve = self.serveSet.value ?? ""
        let domain = self.domainSet.value ?? ""
        let trans = self.typeSet.type ?? 0
        let privacy = self.proxySet.value ?? "0"
        let regis = self.expiresSet.value ?? "1800"
        myinformation = [
            "displayName": displayName,
            "account": account,
            "pwd": pwd,
            "serve": serve,
            "port": domain,
            "trans": String(trans),
            "privacy": privacy,
            "regis": regis
        ]
        UserDefaults.standard.setValue(myinformation, forKey: "myinfo")
        UserDefaults.standard.synchronize()
        if NHVoipManager.it.mAccount?.username != nil {
            NHVoipManager.it.unregister()
            unbinding()
        }
        NHVoipManager.it.loginWith(username: account, passwd: pwd, domain: serve, port: domain, displayName: displayName, transportType: TransportType(rawValue: trans) ?? .Tcp , privacy: UInt(privacy), expires: UInt(regis))
//        self.btn_save.backgroundColor = UIColor(hexString: "#144D8E")
        self.myInfoBlock?(displayName)
        ///解决断开连接 cell对账号在线状态判断时间
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
class SIPSetItem: NSObject {
    var name:String?
    var value: String?
    var code: String?
    var type: Int?
    init(name:String? = nil, value: String? = nil , code: String? = nil, type: Int? = 0) {
        self.name = name
        self.value = value
        self.code = code
        self.type = type ?? 0
    }
}
