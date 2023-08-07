//
//  DevicesViewCtrl.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/23.
//

import UIKit
import NHFoundation
import CoreMedia

class DevicesViewCtrl: UIViewController {
    
    @IBOutlet weak var tb_main: UITableView!
    @IBOutlet weak var noContacts: UIView!
    
    var CallBlock: ((_ _name: String,_ _sip: String) -> Void)?
    
    var con: Bool {
        return UserDefaults.standard.bool(forKey: "test")
    }
    
    var list = [Device]()
    var total: [String:[Device]] = [:]
    var keys: [String] {
      var new_key = total.keys.sorted()
        if total.keys.contains(where:{$0 == "#"})  {
            new_key.append( new_key.removeFirst())
        }
        return new_key
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadNewData()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.reloadNewData()
    }
    
    /// 设置UI
    func setupUI() {
        self.title = nh_localizedString(forKey: "device")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(named: "friendadd"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(DevicesViewCtrl.nextPage))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.nh_hex(0x2864aa)
        
        self.view.backgroundColor = .white
        self.tb_main.register(.init(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactsTableViewCell")
        self.tb_main.delegate = self
        self.tb_main.dataSource = self
        self.tb_main.tableFooterView = UIView()
//        self.tb_main.backgroundColor = .groupTableViewBackground
        if #available(iOS 15.0, *) {

                    tb_main.sectionHeaderTopPadding = 0;

                }
    }
    
    /// 刷新数据
    func reloadNewData() {
        let constacts = UserDefaults.standard.array(forKey: "message") as? [[String: Any]]
        self.total = [:]
        for index in 0 ..< (constacts?.count ?? 0) {
            
            let data: [String: Any] = constacts![index]
            let devType: DeviceType? = DeviceType.init(rawValue: data["devtype"] as! String) ?? .card_user
            let icon = UIImage.init(named: devType?.rawValue ?? "")
            let name: String? = data["name"] as? String
            let sipnumber: String = data["sipnumber"] as? String ?? ""
            let cmd: String = data["cmd"] as? String ?? ""
            let lock: Bool = data["lock"] as? Bool ?? false
            let initial = name?.nh_firstLetter()
            
            let dev: Device = .init(icon: icon, name: name, sipAddress: sipnumber, type: devType, openCode: cmd, isLock: lock)
            var isWright = false
            for  key in total.keys {
                if(key == initial){
                    isWright = true
                    total[key]?.append(dev)
                    break
                }
            }
            if (isWright == false){
                total[initial!] = [dev]
            }
        }
        if self.total.count == 0 {
            self.tb_main.isHidden = true
            self.noContacts.isHidden = false
        } else {
            self.tb_main.isHidden = false
            self.noContacts.isHidden = true
        }
        self.tb_main.reloadData()
    }
    
    /// 新增联系人
    @objc func nextPage() {
        let viewController = AddContactsViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        viewController.mySavedBlock = {
            self.reloadNewData()
        }
    }
    
}



extension DevicesViewCtrl: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        62
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ContactsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        let subTotal = total[keys[indexPath.section]]![indexPath.row]
        cell.ima_type?.image = subTotal.icon
        cell.l_name?.text = subTotal.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        let lableSection = UILabel()
        lableSection.font = UIFont(name: "PingFangSC-Regular", size: 15)
        lableSection.text = keys[section]
        lableSection.textAlignment = .left
        lableSection.textColor = UIColor(hexString: "333333")
        view.addSubview(lableSection)
        lableSection.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
        let view_line_up = UIView()
        let view_line = UIView()
        view_line.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1)
        view_line_up.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1)
        if section != 0 {
            view.addSubview(view_line_up)
            view_line_up.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(20)
                make.right.top.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        view.addSubview(view_line)
        view_line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        return view
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys[section]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        keys.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let subTotal = total[keys[section]]
        return (subTotal?.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = total[keys[indexPath.section]]![indexPath.row]
        let callCtrl = ConInfoViewController()
        callCtrl.coming = false
        callCtrl.device = model
        callCtrl.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(callCtrl, animated: true)
    }
}


class Device: NSObject {
    var icon: UIImage? {
        get {
            return UIImage.init(named: self.type.rawValue)
        }
        set {
            
        }
    }
    var name: String?
    var sipAddress: String = ""
    var type: DeviceType = .card_user
    var openCode: String?
    /// isLock true 为有开锁功能
    var isLock: Bool = false
    
    //
    var sipAddressFull: String {
        // todo something
        return ""
    }
    
    init(icon: UIImage? = nil, name: String? = nil, sipAddress: String = "", type: DeviceType? = .card_user, openCode: String? = "",isLock: Bool = false) {
        self.name = name
        self.sipAddress = sipAddress
        self.type = type ?? .card_user
        self.openCode = openCode
        self.isLock = isLock
    }

}
