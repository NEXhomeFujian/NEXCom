//
//  DisconnectViewController.swift
//  NEXcom
//
//  Created by csh on 2022/12/9.
//

import UIKit
import NHFoundation
import CloudPushSDK
class DisconnectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tb_main: UITableView!
    @IBOutlet weak var b_save: UIButton!
    
    var list:[Bool] = [false,false,false]
    var listText:[String] = [
        nh_localizedString(forKey: "disconnectText1"),
        nh_localizedString(forKey: "disconnectText2"),
        nh_localizedString(forKey: "disconnectText3")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .groupTableViewBackground
        self.tb_main.backgroundColor = .groupTableViewBackground
        self.title = nh_localizedString(forKey: "Disconnect")
        self.tb_main.register(.init(nibName: "DisconnectTableViewCell", bundle: nil), forCellReuseIdentifier: "DisconnectTableViewCell")
        self.b_save.backgroundColor = UIColor(hexString: "ffcccccc")
        self.b_save.isUserInteractionEnabled = false
        tb_main.dataSource = self
        tb_main.delegate = self
        tb_main.tableFooterView = UIView()
        self.b_save.addTarget(self, action: #selector(self.saveValue), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    func unbinding(_ exitBlock : (()-> Void)? = nil){
        let s1 = "sipnum="
        let s2 = "&timestamp="
        let s3 = "&password="
        let sip = NHVoipManager.it.mAccount?.username!
        let timestamp = Date().milliStamp
       
        let pwd =  NHVoipManager.it.mAccount?.password!
        let str = s1+sip!+s2+timestamp+s3+pwd!
        let device_id = CloudPushSDK.getDeviceId()

        let newStr = str.sha256.uppercased()
        NHVoipRequest.it.unBindDevice(SIPNUM: sip!, SIGN: newStr, device_id: device_id!, TIMESTAMP: String(timestamp), resultBlock: exitBlock)
//        NHVoipRequest.it.unBindDevice(SIPNUM: sip!, SIGN: newStr, device_id: device_id!, TIMESTAMP: String(timestamp)) {
//            exitBlock?()}
        
        
    }
    @objc func saveValue() {
        var myinformation : [String:String] = UserDefaults.standard.dictionary(forKey: "myinfo") as? [String:String] ?? [:]
        var contacts = (UserDefaults.standard.array(forKey: "message") as? [[String: Any]]) ?? []
        
        
        var callInfo = UserDefaults.standard.array(forKey: "callInfo")
        let logined = false
        if list[0] == true {
            self.unbinding()
            NotificationCenter.default.post(name: .init(rawValue: "DisconnectNotice"), object: nil)
            UserDefaults.standard.setValue(list, forKey: "loginState")
            UserDefaults.standard.synchronize()
            NHVoipManager.it.unregister()
            self.navigationController?.popViewController(animated: true)
        } else if list[1] == true {
            self.unbinding()
            myinformation = [:]
            UserDefaults.standard.setValue(list, forKey: "loginState")
            UserDefaults.standard.setValue(myinformation, forKey: "myinfo")
            UserDefaults.standard.synchronize()
            NHVoipManager.it.unregister()
            self.navigationController?.popViewController(animated: true)
        } else {
            //
            self.unbinding { [weak self] () in
                guard let `self` = self else { return }
                myinformation = [:]
                callInfo?.removeAll()
                contacts.removeAll()
                UserDefaults.standard.setValue(contacts, forKey: "message")
                UserDefaults.standard.setValue(self.list, forKey: "loginState")
                UserDefaults.standard.setValue(callInfo, forKey: "callInfo")
                UserDefaults.standard.setValue(false, forKey: "protocol")
                UserDefaults.standard.setValue(logined, forKey: "logined")
                UserDefaults.standard.setValue(myinformation, forKey: "myinfo")
                UserDefaults.standard.synchronize()
                NHVoipManager.it.unregister()
                exit(1)

            }
            
            
        }
       
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        52
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DisconnectTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DisconnectTableViewCell", for: indexPath) as! DisconnectTableViewCell
        cell.v_out.layer.borderWidth = 1
        cell.v_in.layer.borderWidth = 1
        cell.v_out.backgroundColor = UIColor.white
        cell.l_text.text = listText[indexPath.row]
        if indexPath.row == 2{
            cell.separatorInset = .init(top: 0, left: 1000, bottom: 0, right: 0)
        }
        if list[indexPath.row] == false {
            cell.v_out.layer.borderColor = UIColor(hexString: "cccccc").cgColor
            cell.v_in.backgroundColor = UIColor.white
            cell.v_in.layer.borderColor = UIColor.white.cgColor
           
        } else {
            cell.v_out.layer.borderColor = UIColor(hexString: "2864aa").cgColor
            cell.v_in.backgroundColor = UIColor(hexString: "2864aa")
            cell.v_in.layer.borderColor = UIColor(hexString: "2864aa").cgColor
            self.b_save.backgroundColor = UIColor(hexString: "2864aa")
            self.b_save.isUserInteractionEnabled = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        for index in 0...2{
            if index == indexPath.row {
                list[index] = true
            } else {
                list[index] = false
            }
        }
        tb_main.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
