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
class AddContactsViewController: UIViewController {
    
    @IBOutlet weak var ft_type: UITextField!
    @IBOutlet weak var v_main: UITableView!
    @IBOutlet weak var v_tip: UIImageView!
    @IBOutlet weak var v_alert: UIView!
    @IBOutlet weak var tf_sip: UITextField!
    @IBOutlet weak var tf_code: UITextField!
    @IBOutlet weak var v_code: UIView!
    @IBOutlet weak var v_open: UIView!
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var v_head: UIView!
    @IBOutlet weak var v_type: UIView!
    @IBOutlet weak var im_type: UIImageView!
    @IBOutlet weak var btn_save: UIButton!
    @IBOutlet var v_ano: UIView!
    @IBOutlet weak var btn_more: UIButton!
    @IBOutlet weak var bt_switch: UIButton!
    
    var alert = 0
    var i = 0
    var list: [DeviceType] {
        [
            .card_OutdoorMachine,
            .card_IndoorMachine,
            .card_telephone
        ]
    }
    private var type: DeviceType = .card_user
    public var mySavedBlock : (()->Void)?
    var countTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI() {
        self.title = nh_localizedString(forKey: "add_contact")
        self.view.backgroundColor = .app?.background
        
        self.v_main.register(.init(nibName: "TypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TypeTableViewCell")
        v_main.dataSource = self
        v_main.delegate = self
        
        // Do any additional setup after loading the view.
        self.btn_more.addTarget(self, action: #selector(AddContactsViewController.addPage), for: .touchUpInside)
        self.btn_back.addTarget(self, action: #selector(AddContactsViewController.backPage), for: .touchUpInside)
        self.btn_save.layer.cornerRadius = 4
        self.v_head.layer.cornerRadius = 8
        btn_save.addTarget(self, action: #selector(saveMessage), for: .touchUpInside)
        self.ft_type.addTarget(self, action: #selector(self.checkSave), for: .valueChanged)
        self.tf_sip.addTarget(self, action: #selector(self.checkSave), for: .editingChanged)
        self.tf_name.addTarget(self, action: #selector(self.checkSave), for: .editingChanged)
        self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
        self.btn_save.isUserInteractionEnabled = false
        self.v_alert.layer.cornerRadius = 4
        self.v_tip.layer.cornerRadius = 8
        
        self.bt_switch.setImage(UIImage.init(named: "switch_off"), for: .normal)
        self.bt_switch.setImage(UIImage.init(named: "switch_on"), for: .selected)
    }
    
    // MARK: - Private Method / Button Actions
    @objc func countTime(){
        v_alert.isHidden = true
        countTimer.invalidate()
    }
    
    
    @IBAction func codeChange(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.v_code.isHidden = (sender.isSelected == false)
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
            self.btn_save.backgroundColor = UIColor(hexString: "ffcccccc")
            self.btn_save.isUserInteractionEnabled = false
        }
    }
    
    
    @objc func saveMessage(){
        let  constacts = UserDefaults.standard.array(forKey: "message") as? [[String: Any]]
        var str = "sip:"
        if self.tf_sip.text!.contains("@") {
            str = str + self.tf_sip.text!
        } else {
            let domain = (NHVoipManager.it.mAccount?.domain) ?? ""
            let port = (NHVoipManager.it.mAccount?.port) ?? ""
            str = str + self.tf_sip.text! + "@" + domain + ":" + port
        }
        for index in 0 ..< (constacts?.count ?? 0){
            if constacts?[index]["sipnumber"] as? String == str {
                alert = 1
            }
        }
        if alert == 0 {
            var contacts : [[String: Any]] = (UserDefaults.standard.array(forKey: "message") as? [[String: Any]] ?? [])
            let name = self.tf_name.text
            let sip = str
            let type = self.type.rawValue
            let cmd: String = self.tf_code.text ?? ""
            let lock: Bool = self.bt_switch.isSelected
            contacts.append([
                "name": name as Any,
                "sipnumber": sip,
                "devtype": type,
                "lock": lock,
                "cmd": cmd
            ])
            UserDefaults.standard.setValue(contacts, forKey: "message")
            UserDefaults.standard.synchronize()
            self.mySavedBlock?()
            self.navigationController?.popViewController(animated: true)
            self.btn_save.backgroundColor = UIColor(hexString: "#144D8E")
        } else {
            self.v_alert.isHidden =  false
             countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countTime), userInfo: nil, repeats: true)
        }
        alert = 0
    }

    @objc func backPage(){
        self.v_ano.removeFromSuperview()
    }
    
    @objc func addPage(){
        if let app = UIApplication.shared.keyWindow {
            app.addSubview(v_ano)
        } else {
            self.view.addSubview(v_ano)
        }
        self.v_ano.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.endEditing(true)
    }
}



// MARK: - TableView 代理实现
extension AddContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        self.type = self.list[indexPath.row]
        if self.type == .card_OutdoorMachine {
            self.v_open.isHidden = false
            self.v_code.isHidden = self.bt_switch.isSelected == false
        } else {
            self.v_open.isHidden = true
            self.v_code.isHidden = true
        }
        self.ft_type.text = list[indexPath.row].name
        self.checkSave()
        self.im_type.image = UIImage.init(named: self.type.rawValue)
        backPage()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 55 }
}
