//
//  CallOutViewController.swift
//  NEXcom
//
//  Created by csh on 2022/9/20.
//

import UIKit
import linphonesw
import AVFoundation
import NHFoundation
class CallOutViewController: UIViewController {
    
    public var device: Device?
    
    @IBOutlet weak var v_pre: UIView!
    @IBOutlet weak var b_go_voice: UIButton!
    @IBOutlet weak var l_topTip: UILabel!
    @IBOutlet weak var l_rightTip: UILabel!
    @IBOutlet weak var b_ignore: UIButton!
    @IBOutlet weak var go_edit: UIButton!
    @IBOutlet var v_ano: UIView!
    @IBOutlet weak var b_toggleCamare: UIButton!
    @IBOutlet weak var v_our: UIView!
    @IBOutlet weak var v_tip: UIView!
    @IBOutlet weak var btn_mic: UIButton!
    @IBOutlet weak var l_speak: UILabel!
    @IBOutlet weak var l_mic: UILabel!
    @IBOutlet weak var lb_sip: UILabel!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_time: UILabel!
    @IBOutlet weak var style: UIView!
    @IBOutlet weak var btn_open: UIButton!
    @IBOutlet weak var btn_speak: UIButton!
    @IBOutlet weak var btn_hangup: UIButton!
    @IBOutlet weak var v_main: UIView!
    var constacts: [ [String : Any]] {
        (UserDefaults.standard.array(forKey: "message") as? [[String: Any]]) ?? []
    }
    var speak: Bool = true
    var video: Bool = false
    var mic: Bool = true {
        didSet {
            NHVoipManager.it.isMicrophoneEnabled = self.mic
        }
    }
    var camera: Bool = true
    var coming: Bool = false
    var time = 0
    var name = ""
    var monitorCall = false
    var cmd = ""
    //通话计时：
    lazy var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countTime), userInfo: nil, repeats: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 清除/释放定时器
        self.timer.invalidate()
    }
    
    ///  设置UI
    func setupUI() {
        // 背景渐变：
        let gradientLayer =  CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        let fromColor = UIColor(hexString: "#02244c").cgColor
        let toColor = UIColor(hexString: "#2b414c").cgColor
            gradientLayer.colors=[fromColor,toColor]
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.locations = [0,1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        // 按钮功能：
        btn_hangup.addTarget(self, action: #selector(CallOutViewController.hangup), for: .touchUpInside)
        b_go_voice.addTarget(self, action: #selector(CallOutViewController.closeCame), for: .touchUpInside)
        b_toggleCamare.addTarget(self, action: #selector(CallOutViewController.toggleCamare), for: .touchUpInside)
        btn_mic.addTarget(self, action: #selector(CallOutViewController.micAction), for: .touchUpInside)
        btn_speak.addTarget(self, action: #selector(CallOutViewController.speakAction), for: .touchUpInside)
        btn_open.addTarget(self, action: #selector(CallOutViewController.openTheDoor), for: .touchUpInside)
        self.go_edit.addTarget(self, action: #selector(self.setting), for: .touchUpInside)
        self.b_ignore.addTarget(self, action: #selector(self.ignore), for: .touchUpInside)
        // 开锁渐变：
        style.layer.cornerRadius = 24
        style.alpha = 1
        //Gradient 0 fill for 矩形
        let gradientLayer0 = CAGradientLayer()
        gradientLayer0.cornerRadius = 24
        gradientLayer0.frame = style.bounds
        gradientLayer0.colors = [
            UIColor(red: 81.0 / 255.0, green: 157.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0).cgColor,
            UIColor(red: 40.0 / 255.0, green: 100.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0).cgColor]
        gradientLayer0.locations = [0, 1]
        gradientLayer0.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer0.endPoint = CGPoint(x: 1, y: 1)
        style.layer.addSublayer(gradientLayer0)
        style.addSubview(self.btn_open)
        btn_open.layer.cornerRadius = 24

        //通话计时：
        self.timer.fireDate = Date()


        // 麦克风状态
        self.mic = NHVoipManager.it.isMicrophoneEnabled
        if(self.mic == true){
            btn_mic.setImage(.init(named: "microphone_open"), for: .normal)
            l_mic.text = nh_localizedString(forKey: "l_mic_on")
        } else {
            btn_mic.setImage(.init(named: "microphone_close"), for: .normal)
            l_mic.text = nh_localizedString(forKey: "l_mic_off")
        }
        
        
        // 扬声器状态
        self.speak = NHVoipManager.it.isSpeakerEnabled
        if(self.speak == true){
            btn_speak.setImage(.init(named: "loudspeaker_open"), for: .normal)
            l_speak.text = nh_localizedString(forKey: "l_speak_on")
        } else {
            btn_speak.setImage(.init(named: "loudspeaker_close"), for: .normal)
            l_speak.text =  nh_localizedString(forKey: "l_speak_off")
        }
        self.lb_sip.text = NHVoipManager.it.currentCall?.remoteAddressString
        ///首次请求相机权限
//        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
//        if authStatus == .notDetermined {
//            AVCaptureDevice.requestAccess(for: .video) { (res) in
//                //此处可以判断权限状态来做出相应的操作，如改变按钮状态
//                if res{
//                    DispatchQueue.main.async {
//
//                    }
//                }else{
//
//                    DispatchQueue.main.async {
//
//                        self.dismiss(animated: true, completion: nil)
//                        NHVoipManager.it.terminateCall()
//                    }
//                }
//            }
//        }
    }
    
    
    /// 开门
    @objc func openTheDoor(){
        /*
           1. 拿通话设备 中的 code
           2. 拿通话对象，传入执行code
         */
        
        NHVoipManager.it.currentCall?.performAction(self.device?.openCode ?? "" , method: .DTMF_RFC_4733)
        self.v_tip.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.v_tip.isHidden = true
        }

    }
    
    /// 倒计时
    @objc func countTime(){
        self.lb_time.text = timeSample(count: self.time)
        time = time + 1
//        if time == 180 {
//            NHVoipManager.it.terminateCall()
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    @objc func toggleCamare(){
        NHVoipManager.it.toggleCamera()
     
    }
    
    /// 设置麦克风
    @objc func micAction() {
        if self.monitorCall == true || IsCloseAudioSession() == true {
            let permissionStatus = AVAudioSession.sharedInstance().recordPermission
           if permissionStatus == AVAudioSession.RecordPermission.undetermined {
               AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                   if granted {
                      
                   } else {
//                       self.hangup()
                   }
               }
           } else {
               if IsCloseMic() {
                   self.view.addSubview(v_ano)
                   self.v_ano.snp.remakeConstraints { make in
                       make.edges.equalToSuperview()
                   }
                   l_rightTip.text = nh_localizedString(forKey: "mic_open_tip")
                   l_topTip.text = nh_localizedString(forKey: "mic_tip")
               } else {
                   self.mic = !self.mic
                   NHVoipManager.it.isMicrophoneEnabled = self.mic
                   if(self.mic == true){
                       btn_mic.setImage(.init(named: "microphone_open"), for: .normal)
                       l_mic.text = nh_localizedString(forKey: "l_mic_on")
                   } else {
                       btn_mic.setImage(.init(named: "microphone_close"), for: .normal)
                       l_mic.text = nh_localizedString(forKey: "l_mic_off")
                   }
               }
           }
        } else {
            self.mic = !self.mic
            NHVoipManager.it.isMicrophoneEnabled = self.mic
            if(self.mic == true){
                btn_mic.setImage(.init(named: "microphone_open"), for: .normal)
                l_mic.text = nh_localizedString(forKey: "l_mic_on")
            } else {
                btn_mic.setImage(.init(named: "microphone_close"), for: .normal)
                l_mic.text = nh_localizedString(forKey: "l_mic_off")
            }

        }
        
       
    }
  
    ///  扬声器
    @objc func speakAction() {
        self.speak = !self.speak
        NHVoipManager.it.isSpeakerEnabled = self.speak
        if(self.speak == true){
            btn_speak.setImage(.init(named: "loudspeaker_open"), for: .normal)
            l_speak.text = nh_localizedString(forKey: "l_speak_on")
        } else {
            btn_speak.setImage(.init(named: "loudspeaker_close"), for: .normal)
            l_speak.text = nh_localizedString(forKey: "l_speak_off")
        }
    }
    
    /// 时间显示
    @objc func timeSample(count: Int)->String{
        let second = count%60
        let minute = count / 60
        return String.init(format: "%02ld:%02ld", minute, second)
        
    }
    @objc func ignore() {
//        hangup()
        self.v_ano.removeFromSuperview()
    }
    /// 开启，关闭摄像头
    @objc func closeCame() {

//        if NHVoipManager.it.isCameraEnabled {
//            print("qq000cccc")
//        } else {
//            print("qq000dddd")
//        }
        
        NHVoipManager.it.toggleVideo()
        self.camera = NHVoipManager.it.isCameraEnabled
        if(self.camera == true){
            b_toggleCamare.isHidden = false
            b_go_voice.setImage(.init(named: "video_on"), for: .normal)
           
            
        } else {
            b_go_voice.setImage(.init(named: "video_off"), for: .normal)
            b_toggleCamare.isHidden = true
        }
    }
    /// 挂断
    @objc func hangup(){
        self.dismiss(animated: true, completion: nil)
        NHVoipManager.it.terminateCall()
        
    }
    @objc func setting() {
        let settingURL = URL(string: UIApplication.openSettingsURLString)
        if UIApplication.shared.canOpenURL(settingURL!){
            UIApplication.shared.openURL(settingURL!)
        }
        NHVoipManager.it.terminateCall()
    }
    /// 呼叫 来电
    func outCall() {

        // 设置摄像头开启
        if NHVoipManager.it.isCameraEnabled == false {
            toggleCamare()
        }
        
        if self.device?.isLock == true && self.device?.type == .card_OutdoorMachine{
            style.isHidden = false
        } else{
            style.isHidden = true
        }
        if self.coming {
            NHVoipManager.it.acceptCall(self.v_main,v_our: self.v_our)

//            self.closeCame()l
            var name = ""
            var devType = DeviceType.card_user
            self.v_our.isHidden = false
            var icon = UIImage.init(named: devType.rawValue)
            
            var lock = false
            var jum = false
            for i in 0 ..< constacts.count{
                if (constacts[i]["sipnumber"] as? String ?? "" == NHVoipManager.it.currentCall?.remoteAddressString ){
                    name = constacts[i]["name"] as? String ?? ""
                    devType = DeviceType.init(rawValue: constacts[i]["devtype"] as! String ) ?? .card_user
//                    icon = UIImage.init(named: devType.rawValue )!
                    cmd = constacts[i]["cmd"] as? String ?? ""
                    lock = constacts[i]["lock"] as? Bool ?? false
                    jum = true
                    self.device?.openCode = cmd
                    break
                }
            }
           
            self.lb_sip.text = getString(str: NHVoipManager.it.currentCall?.remoteAddressString ?? "")
           
            self.lb_name.text = self.device?.name
            style.isHidden = true
            if jum == true {
                self.lb_name.text = name
                if devType == .card_OutdoorMachine {
                    if lock == true {
                        style.isHidden = false
                    }
                    
                } else {
                    style.isHidden = true
                }
            } else {
                self.lb_name.text = NHVoipManager.it.currentCall?.remoteAccount?.displayName ?? NHVoipManager.it.currentCall?.remoteAddressString
                
            }
        } else {
            
            if monitorCall ==  false {

                
                NHVoipManager.it.outgoingCall(with: .init(remoteAddress: self.device?.sipAddress ?? "", videoView: self.v_main, displayName: NHVoipManager.it.mAccount?.displayName ?? "", camareView: v_our))
//                toggleCamare()
                self.v_our.isHidden = false

            } else {
                NHVoipManager.it.monitorCall(with: .init(remoteAddress: self.device?.sipAddress ?? "", videoView: self.v_main, displayName: NHVoipManager.it.mAccount?.displayName ?? "", camareView: nil))
                
                self.v_our.isHidden = true
                self.b_toggleCamare.isHidden = true
                self.b_go_voice.isHidden = true
            }
           
            
//            self.view.bringSubviewToFront(v_our)
//            self.toggleCamare()
            self.lb_sip.text = getString(str: self.device?.sipAddress ?? "")
            self.lb_name.text = self.device?.name
            if self.device?.name == "" {
                self.lb_name.text = self.lb_sip.text
            }
//            if self.device?.sipAddress == "" {
//                self.lb_name.text = NHVoipManager.it.currentCall?.remoteAccount?.displayName
//                if NHVoipManager.it.currentCall?.remoteAccount?.displayName == "" {
//                    self.lb_name.text = NHVoipManager.it.currentCall?.remoteAccount?.username
//                } else {
//                    self.lb_name.text = NHVoipManager.it.currentCall?.remoteAccount?.displayName
//                }
//            }
        }
    }
    
    /// 获取sip格式
    func getString(str: String ) -> String{
        var num = ""
        let s = str.dropFirst(4)
        for char in s {
            if char == "@" {
                break
            }
            num.append(char)
        }
        let StrNum = nh_localizedString(forKey: "l_sip") + ": "
        num = StrNum + num
      return num
    }

}
extension CallOutViewController: NHCameraDelegete {
    /// 呈现到某视图上
    func cameraOnPreview(_ camera: NHCamera) -> UIView {
        return self.v_pre
    }
    /// 得到图片
    func camera(_ camera: NHCamera, capture image: UIImage?, originalImage: UIImage?) {
        
    }
}
