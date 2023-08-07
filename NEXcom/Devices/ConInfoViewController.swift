//
//  ConInfoViewController.swift
//  NEXcom
//
//  Created by csh on 2022/9/27.
//

import UIKit
import SnapKit
import AVFoundation
import NHFoundation
class ConInfoViewController: UIViewController {
    
    /// 设备信息
    public var device: Device?
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var l_callType: UILabel!
    @IBOutlet weak var tv_callStyle: UITableView!
    @IBOutlet var v_callStyle: UIView!
    @IBOutlet weak var v_type: UIView!
    @IBOutlet weak var v_tip: UIView!
    @IBOutlet weak var b_ignore: UIButton!
    @IBOutlet weak var go_edit: UIButton!
    @IBOutlet var v_ano: UIView!
    @IBOutlet weak var v_noContact: UIView!
    @IBOutlet weak var l_add: UILabel!
    @IBOutlet weak var v_add: UIView!
    @IBOutlet weak var v_more: UIView!
    @IBOutlet weak var v_head: UIView!
    @IBOutlet weak var tv_recent: UITableView!
    @IBOutlet weak var b_edit: UIButton!
    @IBOutlet weak var v_down: UIView!
    @IBOutlet weak var btn_monitor: UIButton!
    @IBOutlet weak var btn_call_user: UIButton!
    @IBOutlet weak var btn_call_indoor: UIButton!
    @IBOutlet weak var ima_head: UIImageView!
    @IBOutlet weak var l_type: UILabel!
    @IBOutlet weak var l_open: UILabel!
    @IBOutlet weak var l_sip: UILabel!
    @IBOutlet weak var l_name: UILabel!
    @IBOutlet weak var l_rightTip: UILabel!
    @IBOutlet weak var l_topTip: UILabel!
    let ima_down:UIImage = UIImage()
    let label: UILabel = UILabel()
    var coming = false
    var count = 5
    var firstCall = true
    var typeList: [String] {
        [
            nh_localizedString(forKey: "voiceCall"),
            nh_localizedString(forKey: "videoCall"),
            nh_localizedString(forKey: "cancel")
        ]
    }
//    private var currentDevice: [String: String?]? {
//        let constacts : [[String: Any?]] = (UserDefaults.standard.array(forKey: "message") as? [[String: Any]] ?? [])
//        return constacts.first { $0["sipnumber"] == self.address }
//    }
    
    ///更多的UI
    lazy var v_more_c: UIView = {
        let v = UIView()
        let lb = UILabel()
        let imv = UIImageView()
        let point = UIView()
        let bt = UIButton()
        v.addSubview(point)
        v.addSubview(bt)
        point.addSubview(imv)
        point.addSubview(lb)
        imv.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.left.equalTo(lb.snp.right).offset(4)
        }
        lb.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        point.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.bottom.top.equalToSuperview()
        }
        bt.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        lb.text = nh_localizedString(forKey: "search")
        lb.font = UIFont(name: "PingFangSC-Regular", size: 12)
        lb.textColor = UIColor(hexString: "2864aa")
        imv.image = UIImage.init(named: "more_blue")
        v.backgroundColor = .white
        bt.addTarget(self, action: #selector(self.reload), for: .touchUpInside)
        return v
    }()
    var callInfo: [[String:Any?]] {
        let tmpList: [[String: Any?]] = (UserDefaults.standard.array(forKey: "callInfo") as? [[String: Any]] ?? []).reversed()
        return tmpList.filter {
            $0["sip"] as? String == self.device?.sipAddress
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadCall), name: .init(rawValue: "CallReleasedNotice"), object: nil)
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupUI()
//        self.reload()
//    }
    @objc func backPage(){
        self.v_callStyle.removeFromSuperview()
    }
    func setupUI() {
        self.l_callType.text = nh_localizedString(forKey: "callType")
        self.navigationController?.setBarBackgroundClear()
        self.btn_back.addTarget(self, action: #selector(self.backPage), for: .touchUpInside)
        self.go_edit.addTarget(self, action: #selector(self.setting), for: .touchUpInside)
        self.b_ignore.addTarget(self, action: #selector(self.ignore), for: .touchUpInside)
        self.v_down.backgroundColor = .app?.background
        self.btn_call_indoor.addTarget(self, action: #selector(self.callOut), for: .touchUpInside)
        self.btn_monitor.addTarget(self, action: #selector(self.callOutByMonitor), for: .touchUpInside)
        self.btn_call_user.addTarget(self, action: #selector(self.callOut), for: .touchUpInside)
        self.tv_recent.delegate = self
        self.tv_recent.dataSource = self
        self.b_edit.addTarget(self, action: #selector(self.editInfo), for: .touchUpInside)
        self.tv_callStyle.register(.init(nibName: "TypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TypeTableViewCell")
        self.tv_callStyle.delegate = self
        self.tv_callStyle.dataSource = self
        self.tv_callStyle.tableFooterView = UIView()
        btn_monitor.layer.cornerRadius = 4
        btn_call_indoor.layer.cornerRadius = 4
        btn_call_user.layer.cornerRadius = 4
        l_name.text = self.device?.name
        l_sip.text = self.getString(str: self.device?.sipAddress ?? "")
        ima_head.image = self.device?.icon
        v_add.layer.borderWidth = 1
        v_add.layer.borderColor = UIColor(hexString: "2864aa").cgColor
        
        v_add.alpha = 0.4
        l_type.text = self.device?.type.name
        if self.device?.type == .card_OutdoorMachine {
            l_type.isHidden = false
            v_type.isHidden = false
            l_open.isHidden = false
            if self.device?.isLock == true {
                l_open.text = nh_localizedString(forKey: "l_open_on")
            } else {
                l_open.text = nh_localizedString(forKey: "l_open_off")
            }
            v_add.isHidden = true
            btn_call_indoor.isHidden = false
            btn_monitor.isHidden = false
            btn_call_user.isHidden = true
        } else if self.device?.type == .card_IndoorMachine {
            l_type.isHidden = false
            v_type.isHidden = false
            v_add.isHidden = true
            l_open.isHidden = true
            l_open.text = nil
            btn_call_user.isHidden = false
            btn_call_indoor.isHidden = true
            btn_monitor.isHidden = true
        } else if self.device?.type == .card_telephone {
            l_type.isHidden = false
            v_type.isHidden = false
            v_add.isHidden = true
            l_open.isHidden = true
            l_open.text = nil
            btn_call_user.isHidden = false
            btn_call_indoor.isHidden = true
            btn_monitor.isHidden = true
        } else  {
            l_type.isHidden = true
            v_type.isHidden = true
            v_add.isHidden = false
            l_open.isHidden = true
            l_open.text = nil
            btn_call_user.isHidden = false
            btn_call_indoor.isHidden = true
            btn_monitor.isHidden = true
        }
        
        // 列表样式
        self.tv_recent.register(.init(nibName: "InfoCallTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoCallTableViewCell")
        self.tv_recent.backgroundColor = UIColor.app?.background
        if callInfo.count == 0 {
            tv_recent.isHidden = true
        } else {
            tv_recent.isHidden = false
        }
       
        if callInfo.count <= 5 {
            v_more_c.isHidden = true
            self.count = callInfo.count
        }
        self.tv_recent.tableFooterView = UIView()
        /// 解决iOS高版本 secion和cell之前的距离问题
        if #available(iOS 15.0, *) {

            tv_callStyle.sectionHeaderTopPadding = 0;

        }
    }
   
    // MARK: - Private Methond / Button Actions
    func getString(str: String ) -> String{
        var num = ""
        let s = str.dropFirst(4)
        for char in s {
            if char == "@" {
                break
            }
            num.append(char)
        }
        let StrNum = nh_localizedString(forKey: "l_sip")+": "
        num = StrNum + num
      return num
    }
    
    func judgeTime(timeString: String) -> String {
        let nowTime = Int(getTime().prefix(8)) ?? 0
        let calltime = Int(timeString.prefix(8)) ?? 0
        let diffTime = nowTime - calltime
        let minute = timeString.dropFirst(10).prefix(2)
        let second = timeString.dropFirst(8).prefix(2)
        if diffTime == 0 {
            return nh_localizedString(forKey: "today")+" \(second):\(minute)"
        } else if diffTime == 1 {
            return nh_localizedString(forKey: "yesterday")+" \(second):\(minute)"
        } else if diffTime < 7 {
            let week: String = getNowWeekday(differDay: diffTime)
            return "\(week) \(second):\(minute)"
        } else {
            let year = timeString.prefix(4)
            let month = timeString.dropFirst(4).prefix(2)
            let day = timeString.dropFirst(6).prefix(2)
            return "\(year)/\(month)/\(day) \(second):\(minute)"
        }
    }
    func getDuration(starTime: String,endTime: String) -> String{
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyyMMddHHmmss"
        let timeNumber = Int(timeFormatter.date(from: endTime)!.timeIntervalSince1970 - timeFormatter.date(from: starTime)!.timeIntervalSince1970)
        _ = Int(endTime) ?? 0 - (Int(starTime) ?? 0)
        if timeNumber < 60 {
            return "\(timeNumber) "+nh_localizedString(forKey: "second")
        } else if timeNumber == 60 {
            return "\(timeNumber / 60) "+nh_localizedString(forKey: "minute")
        } else {
            return "\(timeNumber / 60) "+nh_localizedString(forKey: "minute")+" \(timeNumber % 60) "+nh_localizedString(forKey: "second")
        }
    }
    func getTime() -> String {
        let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyyMMddHHmmss"
        let strNowTime = timeFormatter.string(from: date as Date) as String
        return strNowTime
    }
    func getNowWeekday(differDay: Int) -> String {
        let calendar:Calendar = Calendar(identifier: .gregorian)
        var comps:DateComponents = DateComponents()
        comps = calendar.dateComponents([.year,.month,.day,.weekday,.hour,.minute,.second], from: Date())
        let weekDay = (comps.weekday! - 1 + 7 - differDay) % 7
        let array = [nh_localizedString(forKey: "sunday"),nh_localizedString(forKey: "monday"),nh_localizedString(forKey: "tuesday"),nh_localizedString(forKey: "wednesday"),nh_localizedString(forKey: "thurday"),nh_localizedString(forKey: "friday"),nh_localizedString(forKey: "saturday")]
        return array[weekDay]
    }
//    //开启麦克风权限
//        func openAudioSession() {
//            let permissionStatus = AVAudioSession.sharedInstance().recordPermission
//                   if permissionStatus == AVAudioSession.RecordPermission.undetermined {
//                       AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
//                           if granted {
//                               NHVoipManager.it.isMicrophoneEnabled = true
//                               let callCtrl = CallOnViewController()
//                               callCtrl.device = self.device
//                               callCtrl.coming = false
//                               callCtrl.modalPresentationStyle = .custom
//                               self.present(callCtrl, animated: true, completion: nil)
//                           } else {
//                               print("00")
//                           }
//                       }
//                   } else{
//
//                   }
//        }
    @objc func ignore() {
        self.v_ano.removeFromSuperview()
    }
    @objc func setting() {
        let settingURL = URL(string: UIApplication.openSettingsURLString)
        if UIApplication.shared.canOpenURL(settingURL!){
            UIApplication.shared.openURL(settingURL!)
        }
    }
    @objc func callOut(){
        if let app = UIApplication.shared.keyWindow {
            app.addSubview(v_callStyle)
        } else {
            self.view.addSubview(v_callStyle)
        }
        self.v_callStyle.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
       
    }
    
    @objc func editInfo(){
        let ctrl = EditContactsViewController()
        ctrl.hidesBottomBarWhenPushed = true
        ctrl.device = self.device
        ctrl.type = self.device?.type ?? .card_user
        self.navigationController?.pushViewController(ctrl, animated: true)
        ctrl.myInfoBlock = { [weak self] (dev) in
            guard let `self` = self else { return }
            self.device = dev
            self.setupUI()
        }
    }
    
    @objc func callOutByMonitor(){
        if NHVoipManager.it.mAccount?.loginState == .Ok {
            NHVoipCallType.it.callType = 2
            NHVoipManager.it.isMicrophoneEnabled = false
            let callCtrl = CallOnViewController()
            callCtrl.coming = false
            callCtrl.modalPresentationStyle = .fullScreen
            callCtrl.device = self.device
            callCtrl.isVideo = true
            callCtrl.monitorCall = true
            self.present(callCtrl, animated: true, completion: nil)

        } else {
            self.v_tip.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.v_tip.isHidden = true
            }
        }
    }

    @objc func reloadCall(){
        
        if callInfo.count <= 5 && callInfo.count > 0 {
            v_noContact.isHidden = true
            tv_recent.isHidden = false
            v_more_c.isHidden = true
            self.count = callInfo.count
        }else if callInfo.count > 5{
            self.count = 5
            v_more_c.isHidden = false
        }
        
        self.tv_recent.reloadData()
    }
    @objc func reload(){
        
        if callInfo.count > 0 {
            v_noContact.isHidden = true
            tv_recent.isHidden = false
        }
        if callInfo.count - self.count <= 5 {
            v_more_c.isHidden = true
            self.count = callInfo.count
        } else {
            v_more_c.isHidden = false
            count = count + 5
        }
        self.tv_recent.reloadData()
    }
    
}


extension ConInfoViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 62 }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0 {
            let v = UIView()
            label.text = nh_localizedString(forKey: "recently")
            label.textAlignment = .left
            label.textColor = UIColor(hexString: "333333")
            label.font = UIFont(name: "PingFangSC-Regular", size: 16)
            v.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(20)
                make.top.bottom.equalToSuperview()
            }
            v.backgroundColor = UIColor.white
            return v
        } else {
            let v = UIView()
            v.backgroundColor = .groupTableViewBackground
            return v
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
           return  count
        } else {
            if section == 0 {
                return 2
            } else {
                return 1
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 0{
            return 1
        } else {
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let num = indexPath.row
            let cell: InfoCallTableViewCell = tableView.dequeueReusableCell(withIdentifier: "InfoCallTableViewCell", for: indexPath) as! InfoCallTableViewCell
            cell.l_callTime.text = judgeTime(timeString: callInfo[num]["starTime"] as! String)
            cell.selectionStyle = .none
            if callInfo[num]["resultType"] as! Int == 0 {
                cell.l_duration.text = self.getDuration(starTime: callInfo[num]["connectedTime"] as! String, endTime: callInfo[num]["endTime"] as! String)
                cell.l_duration.textColor = UIColor(hexString: "333333")
                cell.ima_coming.isHidden = true
                cell.l_callType.textColor = UIColor(hexString: "333333")
            } else if callInfo[num]["resultType"] as! Int ==  1 {
                cell.l_duration.text = nh_localizedString(forKey: "d_noAccept")
                cell.l_duration.textColor = UIColor(hexString: "ea2929")
                cell.ima_coming.isHidden = true
                cell.l_callType.textColor = UIColor(hexString: "ea2929")
            } else if callInfo[num]["resultType"] as! Int ==  2 {
                cell.l_duration.text = self.getDuration(starTime: callInfo[num]["connectedTime"] as! String, endTime: callInfo[num]["endTime"] as! String)
                cell.l_duration.textColor = UIColor(hexString: "333333")
                cell.ima_coming.isHidden = false
                cell.l_callType.textColor = UIColor(hexString: "333333")
            } else if callInfo[num]["resultType"] as! Int ==  3 {
                cell.l_duration.text = nh_localizedString(forKey: "d_noAccept")
                cell.l_duration.textColor = UIColor(hexString: "ea2929")
                cell.l_callType.textColor = UIColor(hexString: "ea2929")
                cell.ima_coming.isHidden = false
            }
            
            if callInfo[num]["callType"] as! Bool == true {
                cell.l_callType.text = "["+nh_localizedString(forKey: "videoCall")+"]"
            } else {
                cell.l_callType.text = "["+nh_localizedString(forKey: "voiceCall")+"]"
            }
            return cell
            
        }else {
            let cell:TypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TypeTableViewCell", for: indexPath) as! TypeTableViewCell
            cell.lb_type.text = self.typeList[indexPath.row]
            if indexPath.section == 0 {
                
                cell.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
                if indexPath.row  == 1 {
                    cell.separatorInset = .init(top: 0, left: 1000, bottom: 0, right: 0)
                    cell.im_type.image = UIImage.init(named: "shipin")
                }else {
                    cell.im_type.image = UIImage.init(named: "yuyin")
                }
                cell.im_type.isHidden = false
                
            }else{
                cell.lb_type.text = nh_localizedString(forKey: "cancel")
                cell.im_type.isHidden = true
            }
           
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == 0 {
           
        }else{
            if NHVoipManager.it.mAccount?.loginState == .Ok {
               NHVoipManager.it.isMicrophoneEnabled = true
               let callCtrl = CallOnViewController()
               callCtrl.device = self.device
        
                callCtrl.coming = false
                callCtrl.modalPresentationStyle = .fullScreen
                if let app = UIApplication.shared.keyWindow {
                    app.addSubview(v_ano)
                } else {
                    self.view.addSubview(v_ano)
                }
                self.v_ano.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                v_ano.isHidden = true
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        NHVoipCallType.it.callType = 0
                        callCtrl.isVideo = false
                        let permissionStatus = AVAudioSession.sharedInstance().recordPermission
                               if permissionStatus == AVAudioSession.RecordPermission.undetermined {
                                   AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                                       if granted {
                                           
                                           DispatchQueue.main.async {
                                               self.v_callStyle.removeFromSuperview()
                                               self.present(callCtrl, animated: true, completion: nil)
                                           }
                                          
                                       } else {
                                           print("00")
                                       }
                                   }
                               } else{
                                   if IsCloseMic() {
                                      
                                           l_rightTip.text = nh_localizedString(forKey: "mic_open_tip")
                                           l_topTip.text = nh_localizedString(forKey: "mic_tip")
                                           self.v_ano.isHidden = false
                                       } else{
                                           self.v_callStyle.removeFromSuperview()
                                           self.present(callCtrl, animated: true, completion: nil)
                                   }
                               }
                    }else if indexPath.row == 1{
                        NHVoipCallType.it.callType = 1
                        callCtrl.isVideo = true
                        
                       
                            openAudioSession()
                            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
                            if authStatus == .notDetermined {
                                AVCaptureDevice.requestAccess(for: .video) { (res) in
                                    //此处可以判断权限状态来做出相应的操作，如改变按钮状态
                                    if res{
                                        DispatchQueue.main.async {
                                            if !IsCloseMic() {
                                                self.v_callStyle.removeFromSuperview()
                                                self.present(callCtrl, animated: true, completion: nil)
                                            }
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            
                                        }
                                    }
                                }
                            }else {
                            if IsCloseAudioSession() && IsCloseCamera() {
                                l_rightTip.text = nh_localizedString(forKey: "both_right")
                                l_topTip.text = nh_localizedString(forKey: "both_top_right")
                                v_ano.isHidden = false
                            } else if IsCloseAudioSession() {
                                l_rightTip.text = nh_localizedString(forKey: "mic_open_tip")
                                l_topTip.text = nh_localizedString(forKey: "mic_tip")
                                v_ano.isHidden = false
                            } else if IsCloseCamera() {
                                l_rightTip.text = nh_localizedString(forKey: "camera_open_tip")
                                l_topTip.text = nh_localizedString(forKey: "camera_tip")
                                v_ano.isHidden = false
                            } else {
                                self.v_callStyle.removeFromSuperview()
                                self.present(callCtrl, animated: true, completion: nil)
                            }
                        }
                        

                    }
                } else {
                    self.v_callStyle.removeFromSuperview()
                }
               
               
           } else {
               self.v_tip.isHidden = false
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   self.v_tip.isHidden = true
               }
           }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.tag == 0 {
            return self.v_more_c
        }else {
            return UIView()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.tag == 0 {
            return 40
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1 {
            if section == 1 {
                return 8
            }else {
                return 0
            }
        }else {
            return 40
        }
        
    }
}
