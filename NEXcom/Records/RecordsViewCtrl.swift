//
//  RecordsViewCtrl.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/23.
//

import UIKit
import AVFoundation
import SnapKit
import NHFoundation

class RecordsViewCtrl: UIViewController {
    
    enum CallType {
        /// 全部来电
        case all
        /// 未接来电
        case unAccept
        /// 呼叫
        case out
    }
    public var device: Device?
    @IBOutlet weak var b_do: UIButton!
    
    @IBOutlet weak var l_topTip: UILabel!
    @IBOutlet weak var l_rightTip: UILabel!
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var l_callType: UILabel!
    @IBOutlet weak var tv_callStyle: UITableView!
    @IBOutlet var v_callStyle: UIView!
    @IBOutlet weak var v_tip: UIView!
    @IBOutlet weak var b_ignore: UIButton!
    @IBOutlet weak var b_out: UIButton!
    @IBOutlet weak var b_noaccept: UIButton!
    @IBOutlet weak var b_all: UIButton!
    @IBOutlet weak var v_segment: UIView!
    @IBOutlet weak var tb_main: UITableView!
    @IBOutlet weak var v_empty: UIView!
    
    @IBOutlet var v_ano: UIView!
    public var callTypeBlock : ((_ calltype: Int)->Void)?
    var selectNum = 0
    private var callType: CallType = .all
    var constacts: [ [String : Any]] {
        (UserDefaults.standard.array(forKey: "message") as? [[String: Any]]) ?? []
    }
    var typeList: [String] {
        [
            nh_localizedString(forKey: "voiceCall"),
            nh_localizedString(forKey: "videoCall"),
            nh_localizedString(forKey: "cancel")
        ]
    }
    ///  通话记录
    var callInfo: [[String: Any?]] {
        let tmpList: [[String: Any?]] = (UserDefaults.standard.array(forKey: "callInfo") as? [[String: Any]] ?? []).reversed()
        if self.callType == .all {
            return tmpList
        } else if self.callType == .unAccept {
            return tmpList.filter { $0["resultType"] as! Int == 3 }
        } else {
            return tmpList.filter { $0["resultType"] as! Int == 0 || $0["resultType"] as! Int == 1  }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reload()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: .init(rawValue: "CallReleasedNotice"), object: nil)
    }
    @objc func ignore() {
        self.v_ano.removeFromSuperview()
    }
    @objc func setting() {
        let settingURL = URL(string: UIApplication.openSettingsURLString)
        if UIApplication.shared.canOpenURL(settingURL!){
            UIApplication.shared.openURL(settingURL!)
        }
    }
    @objc func backPage(){
        self.v_callStyle.removeFromSuperview()
    }
    func setupUI() {
        self.l_callType.text = nh_localizedString(forKey: "callType")
        self.title = nh_localizedString(forKey: "recently")
        self.view.backgroundColor = .white
        self.b_do.addTarget(self, action: #selector(self.setting), for: .touchUpInside)
        self.b_ignore.addTarget(self, action: #selector(self.ignore), for: .touchUpInside)
        self.btn_back.addTarget(self, action: #selector(self.backPage), for: .touchUpInside)
        self.b_all.addTarget(self, action: #selector(self.changeAllInfo), for: .touchUpInside)
        self.b_out.addTarget(self, action: #selector(self.changeOutInfo), for: .touchUpInside)
        self.b_noaccept.addTarget(self, action: #selector(self.changeNoAcceptInfo), for: .touchUpInside)
        self.tb_main.register(.init(nibName: "RecentCallTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentCallTableViewCell")
        self.tv_callStyle.register(.init(nibName: "TypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TypeTableViewCell")
        self.tb_main.delegate = self
        self.tb_main.dataSource = self
        self.tv_callStyle.delegate = self
        self.tv_callStyle.dataSource = self
        self.tv_callStyle.tableFooterView = UIView()
        self.tb_main.tableFooterView = UIView()
        v_segment.layer.cornerRadius = 8
        b_all.layer.cornerRadius = 6
        b_out.layer.cornerRadius = 6
        b_noaccept.layer.cornerRadius = 6
    
        /// 解决iOS高版本 secion和cell之前的距离问题
        if #available(iOS 15.0, *) {
            tv_callStyle.sectionHeaderTopPadding = 0;
        }
      
    }
    
    /// 全部
    @objc func changeAllInfo(){
        self.b_all.backgroundColor = UIColor(hexString: "ffffff")
        self.b_out.backgroundColor = .clear
        self.b_noaccept.backgroundColor = .clear
        self.callType = .all
        self.reload()
//        self.tb_main.reloadData()
    }
    /// 未接
    @objc func changeNoAcceptInfo(){
        self.b_all.backgroundColor = .clear
        self.b_out.backgroundColor = .clear
        self.b_noaccept.backgroundColor = UIColor(hexString: "ffffff")
        self.callType = .unAccept
//        self.tb_main.reloadData()
        self.reload()
    }
    /// 呼出
    @objc func changeOutInfo(){
        self.b_all.backgroundColor = .clear
        self.b_out.backgroundColor = UIColor(hexString: "ffffff")
        self.b_noaccept.backgroundColor = .clear
        self.callType = .out
//        self.tb_main.reloadData()
        self.reload()
    }
    
    func judgeTime(timeString: String) -> String {
        let nowTime = Int(getTime().prefix(8)) ?? 0
        let calltime = Int(timeString.prefix(8)) ?? 0
        let diffTime = nowTime - calltime
        let minute = timeString.dropFirst(10).prefix(2)
        let second = timeString.dropFirst(8).prefix(2)
        if diffTime == 0 {
            return " \(second):\(minute)"
        } else if diffTime == 1 {
            return nh_localizedString(forKey: "yesterday")
        } else if diffTime < 7 {
            let week: String = getNowWeekday(differDay: diffTime)
            return "\(week)"
        } else {
            let year = timeString.prefix(4)
            let month = timeString.dropFirst(4).prefix(2)
            let day = timeString.dropFirst(6).prefix(2)
            return "\(year)/\(month)/\(day)"
        }
    }
    
    @objc func reload() {
        self.v_empty.isHidden = self.callInfo.count != 0
        self.tb_main.reloadData()
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
        //星期
        let array = [nh_localizedString(forKey: "sunday"),nh_localizedString(forKey: "monday"),nh_localizedString(forKey: "tuesday"),nh_localizedString(forKey: "wednesday"),nh_localizedString(forKey: "thurday"),nh_localizedString(forKey: "friday"),nh_localizedString(forKey: "saturday")]
        return array[weekDay]
    }
    //是否开启相机权限
        func IsCloseCamera() -> Bool{
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            return   authStatus == .denied
        }
    //是否开启麦克风
        func IsCloseAudioSession() -> Bool{
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
            return  authStatus == .denied
        }
    //开启麦克风权限
        func openAudioSession() {
            let permissionStatus = AVAudioSession.sharedInstance().recordPermission
                   if permissionStatus == AVAudioSession.RecordPermission.undetermined {
                       AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                           if granted {
                               print("0000")
                           } else {
                               print("00")
                           }
                       }
                   } else{
                      
                   }
        }

}



extension RecordsViewCtrl: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
           return  callInfo.count
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
            let v = UIView()
            v.backgroundColor = .groupTableViewBackground
            return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1 {
            if section == 1 {
                return 8
            }else {
                return 0
            }
        }
        else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let num = indexPath.row
            let address = callInfo[num]["sip"] as? String ?? ""
            let cell:RecentCallTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecentCallTableViewCell", for: indexPath) as! RecentCallTableViewCell
     
            var testify = false
            var type: DeviceType = .card_user
            for i in 0 ..< constacts.count{
                if constacts[i]["sipnumber"] as? String ?? "" == (callInfo[num]["sip"] as? String ?? "" ){
                    cell.l_name.text = constacts[i]["name"] as? String ?? ""
                    type = .init(rawValue: (constacts[i]["devtype"] as? String ?? "")) ?? .card_user
                    cell.ima_type.image = UIImage.init(named: type.rawValue )
                    cell.isLock = constacts[i]["lock"] as? Bool ?? false
                    cell.code = constacts[i]["cmd"] as? String ?? ""
                    testify = true
                    break
                }
            }
            if testify == false {
                cell.l_name.text =  callInfo[num]["name"] as? String
                cell.ima_type.image = UIImage.init(named: "card_user")
            }
            
            cell.l_callTime.text = judgeTime(timeString: callInfo[num]["starTime"] as? String ?? "")
            cell.selectionStyle = .none
            if callInfo[num]["resultType"] as! Int == 0 {
                cell.ima_callType.isHidden = true
                cell.l_name.textColor = UIColor(hexString: "333333")
            } else if callInfo[num]["resultType"] as! Int ==  1 {
                cell.ima_callType.isHidden = true
                cell.l_name.textColor = UIColor(hexString: "333333")
            } else if callInfo[num]["resultType"] as! Int ==  2 {
                cell.ima_callType.isHidden = false
                cell.l_name.textColor = UIColor(hexString: "333333")
            } else if callInfo[num]["resultType"] as! Int ==  3 {
                cell.l_name.textColor = UIColor(hexString: "ea2929")
                cell.ima_callType.isHidden = false
            }
            
            if callInfo[num]["callType"] as! Bool == true {
                cell.l_type.text = "[" + nh_localizedString(forKey: "videoCall")+"]"
            } else {
                cell.l_type.text = "["+nh_localizedString(forKey: "voiceCall")+"]"
            }
            
             cell.clickBlock = { [weak self] () in
                 // do something
                 let callCtrl = ConInfoViewController()
                 

                 self?.device = .init(icon: cell.ima_type.image, name: cell.l_name.text, sipAddress: address, type: type, openCode:  cell.code, isLock: cell.isLock)
                 callCtrl.coming = false
                
                 callCtrl.device = self?.device
                 callCtrl.hidesBottomBarWhenPushed = true
                 self?.navigationController?.pushViewController(callCtrl, animated: true)
             }
            return cell
        } else {
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
            selectNum = indexPath.row
            if let app = UIApplication.shared.keyWindow {
                app.addSubview(v_callStyle)
            } else {
                self.view.addSubview(v_callStyle)
            }
            self.v_callStyle.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
          
        }else {
            if indexPath.section == 1 {
                      backPage()
            }else {
                if NHVoipManager.it.mAccount?.loginState == .Ok {
                    NHVoipManager.it.isMicrophoneEnabled = true
                      let num = selectNum
                      var devType : DeviceType = .card_user
                      var testify = false
                      var icon: UIImage = .init(named: devType.rawValue)!
                      let sipnumber = callInfo[num]["sip"] as? String ?? ""
                      var cmd = ""
                      var name =  NHVoipManager.it.currentCall?.remoteAccount?.displayName ?? ""
                      var lock = false
                      for i in 0 ..< constacts.count{
                          if constacts[i]["sipnumber"] as? String ?? "" == (callInfo[num]["sip"] as! String ){
                              name = constacts[i]["name"] as? String ?? ""
                              devType = DeviceType.init(rawValue: constacts[i]["devtype"] as! String ) ?? .card_user
                              icon = UIImage.init(named: devType.rawValue )!
                              cmd = constacts[i]["cmd"] as? String ?? ""
                              lock = constacts[i]["lock"] as? Bool ?? false
                             testify = true
                              break
                          }
                      }
                   
                    device = .init(icon: icon, name: name, sipAddress: sipnumber, type: devType, openCode: cmd , isLock: lock)
                    
                      let callCtrl = CallOnViewController()
                      callCtrl.device = device
                      callCtrl.coming = false
                      callCtrl.modalPresentationStyle = .fullScreen
                      openAudioSession()
        
                      if let app = UIApplication.shared.keyWindow {
                          app.addSubview(v_ano)
                      } else {
                          self.view.addSubview(v_ano)
                      }
                      self.v_ano.snp.remakeConstraints { make in
                          make.edges.equalToSuperview()
                      }
                      v_ano.isHidden = true
                    if indexPath.row == 0 {
                        callCtrl.isVideo = false
                    }else if indexPath.row == 1{
                        callCtrl.isVideo = true
                    }else {
                        self.v_callStyle.removeFromSuperview()
                    }
                    
                    if indexPath.section == 0{
                        if indexPath.row == 0 {
                            NHVoipCallType.it.callType = 0
                            if IsCloseAudioSession() {
                                l_rightTip.text = nh_localizedString(forKey: "mic_open_tip")
                                l_topTip.text = nh_localizedString(forKey: "mic_tip")
                                v_ano.isHidden = false
                            } else {
                                self.callTypeBlock?(0)
                                self.v_callStyle.removeFromSuperview()
                                self.present(callCtrl, animated: true, completion: nil)
                            }
                        } else if indexPath.row == 1 {
                            NHVoipCallType.it.callType = 1
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
                                self.callTypeBlock?(1)
                                self.v_callStyle.removeFromSuperview()
                                self.present(callCtrl, animated: true, completion: nil)
                            }
                            
                        }
                    }
                  } else {
                      self.v_tip.isHidden = false
                      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                          self.v_tip.isHidden = true
                      }
                  }
            }
            
        }
        
       
    }
   
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: nh_localizedString(forKey: "delete")) { action, index in
            var Info = UserDefaults.standard.array(forKey: "callInfo") as? [[String: Any]] ?? []
            let starTime = self.callInfo[indexPath.row]["starTime"] as! String
            for indexRow in 0...Info.count - 1 {
                if Info[indexRow]["starTime"] as! String == starTime {
                    Info.remove(at: indexRow)
                    break
                }
            }
            UserDefaults.standard.setValue(Info, forKey: "callInfo")
            UserDefaults.standard.synchronize()
//            self.tb_main.reloadData()
            self.reload()
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 62 }
}
class Record: NSObject {
    var name: String?
    var sipAddress: String = ""
    var starTime: String = ""
    var endTime: String = ""
    var connectedTime: String = ""
    var callType: Bool?
    var resultType: Int = 0
    
    //
    var sipAddressFull: String {
        // todo something
        return ""
    }
  
    
    init(name: String? = nil, sipAddress: String? = nil, starTime: String = "", endTime: String? = "", connectedTime: String? = "",callType: Bool = false,resultType: Int = 0) {
        self.name = name
        self.sipAddress = sipAddress ?? ""
        self.starTime = starTime
        self.endTime = endTime ?? ""
        self.connectedTime = connectedTime ?? ""
        self.callType = callType
        self.resultType = resultType
    }

}
