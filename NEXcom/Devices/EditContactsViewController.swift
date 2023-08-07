//
//  AddContactsViewController.swift
//  NEXcom
//
//  Created by csh on 2022/9/19.
//

import UIKit
import SnapKit
import SwiftUI
import NHFoundation

class EditContactsViewController: UIViewController {
    
    public var device: Device?
    
    @IBOutlet var v_delete: UIView!
    @IBOutlet weak var b_cancel: UIButton!
    @IBOutlet weak var b_delete: UIButton!
    @IBOutlet weak var ft_type: UITextField!
    @IBOutlet weak var v_main: UITableView!
    @IBOutlet weak var tf_code: UITextField!
    @IBOutlet weak var v_code: UIView!
    @IBOutlet weak var v_open: UIView!
    @IBOutlet weak var tf_sip: UITextField!
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var v_head: UIView!
    @IBOutlet weak var v_tip: UIImageView!
    @IBOutlet weak var v_alert: UIView!
    @IBOutlet weak var im_type: UIImageView!
    @IBOutlet weak var btn_save: UIButton!
    @IBOutlet var v_ano: UIView!
    @IBOutlet weak var btn_more: UIButton!
    @IBOutlet weak var bt_switch: UIButton!
    var str = "sip:"
    var i = 0

    var list: [DeviceType] {
        [
            .card_OutdoorMachine,
            .card_IndoorMachine,
            .card_telephone
        ]
    }
    var type = DeviceType.card_telephone
    var alert = 0
    public var mySavedBlock : (()->Void)?
    public var myInfoBlock : ((_ dev: Device?)->Void)?
    var countTimer = Timer()
    
    /// 当前设备
//    private var currentDevice: [String: String?]? {
//        let constacts : [[String: Any?]] = (UserDefaults.standard.array(forKey: "message") as? [[String: Any]] ?? [])
//        return constacts.first { $0["sipnumber"] as! String == self.sipAddress }
//    }
    private var sipAddress: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI() {
        self.title = nh_localizedString(forKey: "edit_contact")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: nh_localizedString(forKey: "delete"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.deleteInfo))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.nh_hex(0x2864aa)
        self.view.backgroundColor = UIColor.app?.background
        
        self.v_main.register(.init(nibName: "TypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TypeTableViewCell")
        v_main.dataSource = self
        v_main.delegate = self
        
//        self.tf_sip.text = isSameServe(isSameStr: self.device?.sipAddress ?? "")
        self.tf_sip.text = getString(str: self.device?.sipAddress ?? "")
        self.tf_name.text = self.device?.name
        if self.device?.type != .card_user {
            self.ft_type.text = self.device?.type.name
        }
        
             
        // Do any additional setup after loading the view.
        self.b_cancel.addTarget(self, action: #selector(self.deleteCancel), for:  .touchUpInside)
        self.b_delete.addTarget(self, action: #selector(self.deleteSure), for: .touchUpInside)
        self.btn_more.addTarget(self, action: #selector(EditContactsViewController.addPage), for: .touchUpInside)
        self.btn_back.addTarget(self, action: #selector(EditContactsViewController.backPage), for: .touchUpInside)
        self.btn_save.layer.cornerRadius = 4
        self.v_head.layer.cornerRadius = 8
        btn_save.addTarget(self, action: #selector(saveMessage), for: .touchUpInside)
        self.im_type.image = self.device?.icon
        self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
        self.ft_type.addTarget(self, action: #selector(self.checkSave), for: .editingChanged)
        self.tf_sip.addTarget(self, action: #selector(self.checkSave), for: .editingChanged)
        self.tf_name.addTarget(self, action: #selector(self.checkSave), for: .editingChanged)
        self.tf_code.addTarget(self, action: #selector(self.checkSave), for: .editingChanged)
        self.btn_save.isUserInteractionEnabled = false
        self.v_tip.layer.cornerRadius = 8
        self.v_alert.layer.cornerRadius = 4
        
        self.bt_switch.setImage(UIImage.init(named: "switch_off"), for: .normal)
        self.bt_switch.setImage(UIImage.init(named: "switch_on"), for: .selected)
        
        // 室外机，显示远程开锁相关
        if self.device?.type == .card_OutdoorMachine {
            self.v_open.isHidden = false
            self.v_code.isHidden = self.bt_switch.isSelected == false
            // 检测 lock 是否开启
            if self.device?.isLock ?? false {
                self.v_code.isHidden = false
                self.bt_switch.isSelected = true
          
            } else {
                self.v_code.isHidden = true
                self.bt_switch.isSelected = false
            }
            // 填充数据
            if let dev = self.device, let code: String = dev.openCode {
                self.tf_code.text = code
               
            }
        }
        if self.device?.type == .card_user {
            self.tf_name.text = ""
            self.title = nh_localizedString(forKey: "add_contact")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.deleteNone))
        }
        // 预存 sipAddress
        self.sipAddress = self.device?.sipAddress
    
    }
    @objc func deleteNone(){
        
    }
    
    // MARK: - Private Method / Button Actions
    func getString(str: String) -> String{
        var num = ""
        let s = str.dropFirst(4)
        for char in s {
            if char == "@" {
                break
            }
            num.append(char)
        }
        return num
    }
    
    @IBAction func codeChange(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.v_code.isHidden = (sender.isSelected == false)
        self.checkSave()
    }
    @objc func checkSave(){
        if let sip = self.tf_sip.text, sip.count > 0,
           let name = self.tf_name.text, name.count > 0,
           let type = self.ft_type.text, type.count > 0
        {
            if self.bt_switch.isSelected == true {
                if let code = self.tf_code.text, code.count > 0 {
                    self.btn_save.backgroundColor = UIColor(hexString: "2864aa")
                    self.btn_save.isUserInteractionEnabled = true
                } else {
                    self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
                    self.btn_save.isUserInteractionEnabled = false
                }
            } else {
                self.btn_save.backgroundColor = UIColor(hexString: "2864aa")
                self.btn_save.isUserInteractionEnabled = true
            }
            
        } else {
            //
            self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
            self.btn_save.isUserInteractionEnabled = false
        }
    }
    @objc func deleteSure(){
        var constacts = UserDefaults.standard.array(forKey: "message") as? [[String: Any]]
//        var str = "sip:"
        let sip = self.device?.sipAddress ?? ""
//        if sip.contains("@") && sip.contains(":"){
//            str =  sip
//        } else if sip.contains("@") {
//            str = str + sip
//        } else {
//            str = str + sip + "@" + (NHVoipManager.it.mAccount?.domain)! + ":" + (NHVoipManager.it.mAccount?.port)!
//        }
        for index in 0 ..< (constacts?.count ?? 0){
            if constacts?[index]["sipnumber"] as? String  == sip {
                constacts?.remove(at: index)
                break
            }
        }
        UserDefaults.standard.setValue(constacts, forKey: "message")
        UserDefaults.standard.synchronize()
        var ctrl: UIViewController? = nil
        for itemCtrl in self.navigationController?.viewControllers ?? [] {
            if itemCtrl.classForCoder == DevicesViewCtrl.classForCoder() {
                ctrl = itemCtrl
                break
            }
        }
        self.v_delete.removeFromSuperview()
        if ctrl != nil {
            self.navigationController?.popToViewController(ctrl!, animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: false)
            if let appDelegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate,
               let rootCtrl: NHTabBarCtrl = appDelegate.window?.rootViewController as? NHTabBarCtrl
            {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    rootCtrl.selectedIndex = 1
                }
            }
        }
    }
    @objc func deleteCancel(){
        self.v_delete.removeFromSuperview()
    }
    @objc func deleteInfo(){
        if let app = UIApplication.shared.keyWindow {
            app.addSubview(v_delete)
        } else {
            self.view.addSubview(v_delete)
        }
        
//         if let appDelegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate,
//            let rootCtrl: NHTabBarCtrl = appDelegate.window?.rootViewController as? NHTabBarCtrl
//         {
//             rootCtrl.view.addSubview(v_delete)
//         }
       
        self.v_delete.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
//    @objc func isSameServe(isSameStr: String) -> String{
//        return isSameStr
//    }
    @objc func saveMessage(){
        str = "sip:"
        let sip: String? = self.device?.sipAddress ?? ""
        if (sip?.contains("@") ?? false) && (sip?.contains(":") ?? false) {
            str =  sip ?? ""
        } else if sip?.contains("@") ?? false {
            str = str + (sip ?? "")
        } else {
            str = str + (sip ?? "") + "@" + (NHVoipManager.it.mAccount?.domain)! + ":" + (NHVoipManager.it.mAccount?.port)!
        }
        var  constacts : [[String: Any]] = (UserDefaults.standard.array(forKey: "message") as? [[String: Any]] ?? [])

//        for index in 0 ..< (constacts.count ){
//            if constacts[index]["sipnumber"] == sip {
//                constacts.remove(at: index)
//                UserDefaults.standard.setValue(constacts, forKey: "message")
//                UserDefaults.standard.synchronize()
//                break
//            }
//        }
        // 删除
        constacts.removeAll { item in
            let address: String? = item["sipnumber"] as? String
            return address == self.sipAddress
        }
        str = "sip:"
        if self.tf_sip.text!.contains("@") {
            str = str + self.tf_sip.text!
        } else {
            str = str + self.tf_sip.text! + "@" + (NHVoipManager.it.mAccount?.domain)! + ":" + (NHVoipManager.it.mAccount?.port)!
        }
        for index in 0 ..< (constacts.count){
            if constacts[index]["sipnumber"] as? String == str {
                alert = 1
                break
            }
        }
        if alert == 0 {
            // 修改上个页面传入的数据
            self.device?.name = self.tf_name.text
            self.device?.sipAddress = str
            self.device?.openCode = self.tf_code.text ?? ""
            self.device?.isLock = self.bt_switch.isSelected
            self.device?.type = type
            // 修改本地数据
            let name = self.device?.name
            let sip:String = self.device?.sipAddress ?? ""
            
            let cmd: String = self.device?.openCode ?? ""
            let lock: Bool = self.device?.isLock ?? false
            constacts.append([
                "name": name as Any,
                "sipnumber": sip,
                "devtype": type.rawValue as Any,
                "lock": lock,
                "cmd": cmd
            ])
            
            UserDefaults.standard.setValue(constacts, forKey: "message")
            UserDefaults.standard.synchronize()
            self.mySavedBlock?()
            self.myInfoBlock?(self.device)
            self.btn_save.backgroundColor = UIColor(hexString: "#144D8E")
            self.navigationController?.popViewController(animated: true)
            
//            var ctrl : UIViewController? = nil
//            for itemCtrl in self.navigationController?.viewControllers ?? []{
//                if itemCtrl.classForCoder == ConInfoViewController.classForCoder() {
//                    ctrl = itemCtrl
//                    break
//                }
//            }
//            if ctrl != nil {
//
//                self.navigationController?.popToViewController(ctrl!, animated: true)
//
//            } else {
//                self.navigationController?.popToRootViewController(animated: false)
//                if let appDelegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate,
//                   let rootCtrl: NHTabBarCtrl = appDelegate.window?.rootViewController as? NHTabBarCtrl
//                {
//                    DispatchQueue.main.asyncAfter(deadline: .now()) {
//                        rootCtrl.selectedIndex = 1
//                    }
//                }
//            }
        } else {
            self.v_alert.isHidden =  false
             countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countTime), userInfo: nil, repeats: true)
        }
        alert = 0
    }
    @objc func countTime(){
        v_alert.isHidden = true
        countTimer.invalidate()
    }
    @objc func backPage(){
        self.v_ano.removeFromSuperview()
    }
    
    @objc func addPage(){
        self.view.addSubview(self.v_ano)
       
//        if let appDelegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate,
//           let rootCtrl: NHTabBarCtrl = appDelegate.window?.rootViewController as? NHTabBarCtrl
//        {
//            rootCtrl.add
//        }
//        let app = UIApplication.shared.delegate as? AppDelegate
//        let navgationController = UINavigationController(rootViewController: (app?.window?.rootViewController)!);
//        navgationController.view.addSubview(v_ano)
//        app?.window?.rootViewController?.view.addSubview(v_ano)
//        let topViewC = self.navigationController?.topViewController;
//        topViewC?.view.addSubview(v_ano)
        let app = UIApplication.topNavigation()
        app?.view.addSubview(v_ano)
        self.v_ano.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.endEditing(true)
    }
}


// MARK: - TableView 代理实现
extension EditContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TypeTableViewCell", for: indexPath) as! TypeTableViewCell
        cell.lb_type.text = self.list[indexPath.row].name
        cell.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        if indexPath.row + 1 == 3 {
            cell.separatorInset = .init(top: 0, left: 1000, bottom: 0, right: 0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        self.device?.type = self.list[indexPath.row]
//        if self.device?.type == .card_OutdoorMachine {
//            self.v_open.isHidden = false
//            self.v_code.isHidden = self.bt_switch.isSelected == false
//        } else {
//            self.v_open.isHidden = true
//            self.v_code.isHidden = true
//        }
//
//        self.ft_type.text = list[indexPath.row].name
//        self.im_type.image = self.device?.icon
//        self.device?.type = self.list[indexPath.row]
        if self.list[indexPath.row] == .card_OutdoorMachine {
            self.v_open.isHidden = false
            self.v_code.isHidden = self.bt_switch.isSelected == false
        } else {
            self.v_open.isHidden = true
            self.v_code.isHidden = true
        }

        
        self.ft_type.text = list[indexPath.row].name
        self.im_type.image = UIImage.init(named: list[indexPath.row].rawValue)
        self.type = list[indexPath.row]
//        self.im_type.image =
        self.checkSave()
        backPage()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 55 }
}
