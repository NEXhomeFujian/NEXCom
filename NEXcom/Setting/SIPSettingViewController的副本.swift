//
//  SIPSettingViewController.swift
//  NexPhone
//
//  Created by csh on 2022/9/14.
//

import UIKit
import SnapKit
import linphonesw
class SIPSettingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var btn_save: UIButton!

    @IBOutlet weak var v_main: UITableView!
    public var myInfoBlock:((_ name:String)->Void)?
    
    var list_tmp: [String] {
        [
            "显示名",
            "SIP账号",
            "SIP密码",
            "SIP服务器",
            "端口号",
            "传输设置",
            "代理服务器",
            "注册有效期"
            
        ]
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
    
    let displayNameSet = SIPSetItem.init(name: "显示名", value: "", code: "displayName")
    let accountSet = SIPSetItem.init(name: "SIP账号", value: "", code: "account")
    let pwdSet = SIPSetItem.init(name: "SIP密码号", value: "", code: "pwd")
    let serveSet = SIPSetItem.init(name: "SIP服务器", value: "", code: "serve")
    let domainSet = SIPSetItem.init(name: "端口号", value: "", code: "port")
    let typeSet = SIPSetItem.init(name: "传输设置", value: "", code: "trans", type: 0)
    let proxySet = SIPSetItem.init(name: "代理服务器", value: "", code: "privacy")
    let expiresSet =  SIPSetItem.init(name: "注册有效期", value: "", code: "regis")
    var  myinformation : [String:String] = UserDefaults.standard.dictionary(forKey: "myinfo") as? [String:String] ?? [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SIP配置"
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "f9f9f9")
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .groupTableViewBackground
        self.v_main.register(.init(nibName: "SIPSet1TableViewCell", bundle: nil), forCellReuseIdentifier: "SIPSet1TableViewCell")
        self.v_main.register(.init(nibName: "SIPSet2TableViewCell", bundle: nil), forCellReuseIdentifier: "SIPSet2TableViewCell")
        self.v_main.register(.init(nibName: "SIPSet3TableViewCell", bundle: nil), forCellReuseIdentifier: "SIPSet3TableViewCell")
        v_main.dataSource = self
        v_main.delegate = self
        self.v_main.backgroundColor = .groupTableViewBackground
        self.v_main.tableFooterView = UIView()
        self.btn_save.layer.cornerRadius = 4
        
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = self.list[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            let cell:SIPSet1TableViewCell = tableView.dequeueReusableCell(withIdentifier: "SIPSet1TableViewCell", for: indexPath) as! SIPSet1TableViewCell
            cell.lb_dispaly.text = set.name
            cell.tf_content.text = myinformation[set.code!] ?? ""
            set.value = cell.tf_content.text
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            cell.valueBlock = { set.value = $0 }
            return cell
        } else {
            if indexPath.row == 0 {
                let cell:SIPSet2TableViewCell = tableView.dequeueReusableCell(withIdentifier: "SIPSet2TableViewCell", for: indexPath) as! SIPSet2TableViewCell
                cell.lb_dispaly.text = set.name

                set.type = Int(myinformation["trans"]!) ?? 0
                cell.valueTrans(transValue: set.type)
                cell.changeTrans()
                cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
                cell.b_udp.addTarget(cell, action: #selector(cell.changeTrans), for: .touchUpInside)
                cell.b_tcp.addTarget(cell, action: #selector(cell.changeTcp), for: .touchUpInside)
                cell.b_tls.addTarget(cell, action: #selector(cell.changeTls), for: .touchUpInside)
                cell.myTransBlock = {
                    set.type = $0 ?? 0
                    
                }
                return cell
            } else {
                let cell:SIPSet3TableViewCell = tableView.dequeueReusableCell(withIdentifier: "SIPSet3TableViewCell", for: indexPath) as! SIPSet3TableViewCell
                cell.lb_dispaly.text = set.name
                cell.tf_content.text = myinformation[set.code!] ?? ""
                set.value = cell.tf_content.text
                cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
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
        NHVoipManager.it.loginWith(username: account, passwd: pwd, domain: serve, port: domain, displayName: displayName, transportType: TransportType(rawValue: trans)! , privacy: UInt(privacy ), expires: UInt(regis))
        self.btn_save.backgroundColor = UIColor(hexString: "#144D8E")
        
        self.myInfoBlock!(displayName)
        self.navigationController?.popViewController(animated: true)
        
//        print("displayName:\(displayName), account:\(account)")
        
        
    }
    
    
}
class SIPSetItem: NSObject {
    var name:String?
    var value: String?
    var code: String?
    var type: Int = 0
    init(name:String? = nil, value: String? = nil , code: String? = nil, type: Int = 0) {
        self.name = name
        self.value = value
        self.code = code
        self.type = type
    }
}
