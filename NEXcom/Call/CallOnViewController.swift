//
//  CallOnViewController.swift
//  NEXcom
//
//  Created by csh on 2022/9/23.
//
import AVFoundation
import UIKit
import SnapKit
import linphonesw
import NHFoundation
class CallOnViewController: UIViewController {
    
    public var device: Device?

    @IBOutlet var v_purview: UIView!
    
    @IBOutlet var v_mic_ano: UIView!
    @IBOutlet weak var b_ignore: UIButton!
    
    @IBOutlet weak var v_pre: UIView!
    @IBOutlet weak var v_tip: UIView!
    @IBOutlet weak var b_toggle: UIButton!
    @IBOutlet weak var v_our: UIView!
    @IBOutlet weak var l_topTip: UILabel!
    @IBOutlet weak var l_rightTip: UILabel!
    @IBOutlet weak var b_mic_ignore: UIButton!
    @IBOutlet weak var b_mic_set: UIButton!
    @IBOutlet weak var v_left: UIView!
    @IBOutlet weak var v_right: UIView!
    @IBOutlet weak var b_setting: UIButton!
    @IBOutlet weak var btn_open: UIButton!
    @IBOutlet weak var l_wait_you_speak: UILabel!
    @IBOutlet weak var b_coming_accept: UIButton!
    @IBOutlet weak var b_hangup_coming: UIButton!
    @IBOutlet weak var v_hangup_center: UIView!
    @IBOutlet weak var l_wait_you: UILabel!
    @IBOutlet weak var v_becall_accept: UIView!
    @IBOutlet weak var v_becall_hangup: UIView!
    @IBOutlet weak var btn_speak: UIButton!
    @IBOutlet weak var btn_mic: UIButton!
    @IBOutlet weak var l_wait: UILabel!
    @IBOutlet weak var l_time: UILabel!
    @IBOutlet weak var v_speak: UIView!
    @IBOutlet weak var v_open: UIView!
    @IBOutlet weak var v_mic: UIView!
    @IBOutlet weak var l_point: UILabel!
    @IBOutlet weak var l_speak: UILabel!
    @IBOutlet weak var l_mic: UILabel!
    @IBOutlet weak var v_sip_name: UIView!
    @IBOutlet weak var im_type: UIImageView!
    @IBOutlet weak var lb_wait: UILabel!
    @IBOutlet weak var lb_sip: UILabel!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var btn_hangup: UIButton!
    var firstComing = true
    var monitorCall = false
    var strNowTime: String = ""
    var time = 0
    var mic: Bool = true
    var speak: Bool = false
    var coming: Bool = true
    var count = 0
    var count1  = 0
    let callOutCtrl = CallOutViewController()
    var testify = false
    var isVideo =  false
    var constacts: [ [String : Any]] {
        (UserDefaults.standard.array(forKey: "message") as? [[String: Any]]) ?? []
    }

   lazy var  camera = NHCamera.init(with: self)

    // 等待接通小点点：
    lazy var timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(self.changeTest), userInfo: nil, repeats: true)
    // 通话计时：
    lazy var countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countTime), userInfo: nil, repeats: true)
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
       
        // 接通通知：
         NotificationCenter.default.addObserver(self, selector: #selector(self.callConnected(_:)), name: .init(rawValue: "CallStateChangedNotice"), object: nil)
        self.callManage()

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 清除/释放定时器
        self.timer.invalidate()
        self.countTimer.invalidate()
    }
    func callManage(){
        lb_name.text = self.device?.name

        self.v_mic.isHidden = false
        self.v_speak.isHidden = false
        self.im_type.image = self.device?.icon
        // 主动呼叫
        if coming == false {
            if self.device?.type == .card_OutdoorMachine {
            } else {
                NHVoipManager.it.isMicrophoneEnabled = true
            }
            self.mic = NHVoipManager.it.isMicrophoneEnabled
            if(self.mic == true){
                btn_mic.setImage(.init(named: "microphone_open"), for: .normal)
                l_mic.text = nh_localizedString(forKey: "l_mic_on")
            } else {
                btn_mic.setImage(.init(named: "microphone_close"), for: .normal)
                l_mic.text = nh_localizedString(forKey: "l_mic_off")
            }
            self.speak = NHVoipManager.it.isSpeakerEnabled
            if(self.speak == true){
                btn_speak.setImage(.init(named: "loudspeaker_open"), for: .normal)
                l_speak.text = nh_localizedString(forKey: "l_speak_on")
            } else {
                btn_speak.setImage(.init(named: "loudspeaker_close"), for: .normal)
                l_speak.text = nh_localizedString(forKey: "l_speak_off")
            }
            // 语音呼叫
            if self.isVideo == false {
                callBYVoice()
            }else {
                self.addChild(callOutCtrl)
                self.view.addSubview(callOutCtrl.view)
                self.callOutCtrl.view.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                self.callOutCtrl.view.isHidden = true
                callOutCtrl.monitorCall = monitorCall
                callout()
            }
        // 来电
        } else {
            var name = NHVoipManager.it.currentCall?.remoteAccount?.displayName ?? ""
            var devType = DeviceType.card_user
            var icon = UIImage.init(named: devType.rawValue)
            var cmd = ""
            var lock = false
            var jum = false
            for i in 0 ..< constacts.count{
                if (constacts[i]["sipnumber"] as? String ?? "" == NHVoipManager.it.currentCall?.remoteAddressString ){
                    name = constacts[i]["name"] as? String ?? ""
                    devType = DeviceType.init(rawValue: constacts[i]["devtype"] as! String ) ?? .card_user
                    icon = UIImage.init(named: devType.rawValue )!
                    cmd = constacts[i]["cmd"] as? String ?? ""
                    lock = constacts[i]["lock"] as? Bool ?? false
                    jum = true
                    break
                }
            }
            
//            self.device?.sipAddress = (NHVoipManager.it.currentCall?.remoteAddressString)!
//            self.device?.name = name
//            self.device?.type = devType
//            self.device?.icon = icon
//            self.device?.openCode = cmd
//            self.device?.isLock = lock
             device = .init(icon: icon, name: name, sipAddress: (NHVoipManager.it.currentCall?.remoteAddressString)!, type: devType, openCode: cmd, isLock: lock)

            self.lb_name.text = name
            self.im_type.image = icon

            let address = (NHVoipManager.it.currentCall?.remoteAddressString)!
            lb_sip.text = getString(str: address)
//            l_wait.isHidden = true
            v_sip_name.isHidden = false
            self.v_mic.isHidden = true
            self.v_speak.isHidden = true
            self.v_hangup_center.isHidden = true
            self.v_becall_hangup.isHidden = false
            self.v_becall_accept.isHidden = false
//            v_open.isHidden = true
            self.addChild(callOutCtrl)
            
//            NHVoipManager.it.ringDuringIncomingEarlyMedia = true
//            NHVoipManager.it.nativeRingingEnabled = true
            
            // 视频来电
            if  NHVoipManager.it.currentCall!.isVideoCall {
                if IsCloseAudioSession()  {
                    let permissionStatus = AVAudioSession.sharedInstance().recordPermission
                           if permissionStatus == AVAudioSession.RecordPermission.undetermined {
                               
                               AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                                   if granted {

                                   } else {
                                      
//                                       DispatchQueue.main.async {
//
//                                           self.dismiss(animated: true, completion: nil)
//                                           NHVoipManager.it.terminateCall()
//                                       }
                                   }
                               }
                           } else{

                           }
                }

                let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
                if authStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(for: .video) { (res) in
                        //此处可以判断权限状态来做出相应的操作，如改变按钮状态
                        if res {
                            if AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .denied {
                                DispatchQueue.main.async {

                                    self.dismiss(animated: true, completion: nil)
                                    NHVoipManager.it.terminateCall()
                                }
                            }
                            
                        }else{

                            DispatchQueue.main.async {

                                self.dismiss(animated: true, completion: nil)
                                NHVoipManager.it.terminateCall()
                            }
                        }
                    }
                }else {
                
               
//                    openCamera()
//                    openAudioSession()
//
//
                    if !IsCloseCamera() && !IsCloseAudioSession() {

                    }else {
                        self.view.addSubview(v_mic_ano)
                        self.v_mic_ano.snp.remakeConstraints { make in
                            make.edges.equalToSuperview()
                        }
                        if IsCloseAudioSession() && IsCloseCamera() {
                            l_rightTip.text = nh_localizedString(forKey: "both_right")
                            l_topTip.text = nh_localizedString(forKey: "both_top_right")
                            v_mic_ano.isHidden = false
                        } else if IsCloseAudioSession() {
                            l_rightTip.text = nh_localizedString(forKey: "mic_open_tip")
                            l_topTip.text = nh_localizedString(forKey: "mic_tip")
                            v_mic_ano.isHidden = false
                        } else if IsCloseCamera() {
                            l_rightTip.text = nh_localizedString(forKey: "camera_open_tip")
                            l_topTip.text = nh_localizedString(forKey: "camera_tip")
                            v_mic_ano.isHidden = false
                        } else {

                        }
                    }
                
                   
            }
                               
                
                l_wait.text = nh_localizedString(forKey: "l_wait_video")
                
                
                callOutCtrl.device = device
                
                callOutCtrl.coming = true
                callOutCtrl.mic = true
                self.view.addSubview(callOutCtrl.view)
                self.callOutCtrl.view.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                self.callOutCtrl.view.isHidden = true
               
                camera.startRunning()
                
//                NHVoipManager.it.acceptEarlyCall(v_pre)

            // 语音来电
            } else {
                
                if IsCloseAudioSession()  {
                    let permissionStatus = AVAudioSession.sharedInstance().recordPermission
                           if permissionStatus == AVAudioSession.RecordPermission.undetermined {
                               AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                                   if granted {
                                      
                                   } else {
                                       DispatchQueue.main.async {

                                           self.dismiss(animated: true, completion: nil)
                                           NHVoipManager.it.terminateCall()
                                       }
                                   }
                               }
                           } else{
                               if IsCloseMic() {
                                   self.view.addSubview(v_mic_ano)
                                   self.v_mic_ano.snp.remakeConstraints { make in
                                       make.edges.equalToSuperview()
                                   }
                                   l_rightTip.text = nh_localizedString(forKey: "mic_open_tip")
                                   l_topTip.text = nh_localizedString(forKey: "mic_tip")
                               } else {
                                   
                               }
                           }
                }
//                v_open.isHidden = true
                l_wait.text = nh_localizedString(forKey: "l_wait_speak")
                b_coming_accept.addTarget(self, action: #selector(self.beCalledByVoice), for: .touchUpInside)
            }
        }
    }
    @objc func toggleView(){
        NHVoipManager.it.toggleView(_view: v_our)
        
    }
    @objc func ignore() {
        
        self.v_mic_ano.removeFromSuperview()
        hangup()
    }
    @objc func setting() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hangup()
        }
        
        let settingURL = URL(string: UIApplication.openSettingsURLString)
        if UIApplication.shared.canOpenURL(settingURL!){
            UIApplication.shared.openURL(settingURL!)
        }
    }

        
    func setUI() {
//        preferredStatusBarStyle
//        lb_name.text = name
        lb_sip.text = getString(str: self.device?.sipAddress ?? "")
        im_type.image = self.device?.icon
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.
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
        // 按钮事件：
//        b_toggle.addTarget(self, action: #selector(self.toggleView), for: .touchUpInside)
        b_mic_set.addTarget(self, action: #selector(self.setting), for: .touchUpInside)
        b_mic_ignore.addTarget(self, action: #selector(self.ignore), for: .touchUpInside)
        btn_hangup.addTarget(self, action: #selector(self.hangup), for: .touchUpInside)
        btn_mic.addTarget(self, action: #selector(self.micAction), for: .touchUpInside)
        btn_speak.addTarget(self, action: #selector(self.speakAction), for: .touchUpInside)
        b_hangup_coming.addTarget(self, action: #selector(self.hangup), for: .touchUpInside)
        b_coming_accept.addTarget(self, action: #selector(self.acceptIn), for: .touchUpInside)
        btn_open.addTarget(self, action: #selector(self.openTheDoor), for: .touchUpInside)
        // 开锁渐变：
        v_open.layer.cornerRadius = 24
        v_open.alpha = 1
        self.view.insertSubview(v_open, belowSubview:   self.btn_open)
        //Gradient 0 fill for 矩形
        let gradientLayer0 = CAGradientLayer()
        gradientLayer0.cornerRadius = 24
        gradientLayer0.frame = v_open.bounds
        gradientLayer0.colors = [
            UIColor(red: 81.0 / 255.0, green: 157.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0).cgColor,
            UIColor(red: 40.0 / 255.0, green: 100.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0).cgColor]
        gradientLayer0.locations = [0, 1]
        gradientLayer0.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer0.endPoint = CGPoint(x: 1, y: 1)
        v_open.layer.addSublayer(gradientLayer0)
        v_open.addSubview(self.btn_open)
        btn_open.layer.cornerRadius = 24
        
        self.timer.fireDate = Date()
        if(self.mic == true){
           
            l_mic.text = nh_localizedString(forKey: "l_mic_on")
        } else {
            
            l_mic.text = nh_localizedString(forKey: "l_mic_off")
        }
        if(self.speak == true){
           
            l_speak.text = nh_localizedString(forKey: "l_speak_on")
        } else {
            
            l_speak.text = nh_localizedString(forKey: "l_speak_off")
        }
    }
   
    //是否开启相机权限
        func IsOpenCamera() -> Bool{
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            return authStatus == .denied
        }
    //是否开启麦克风
        func IsOpenAudioSession() -> Bool{
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
            return authStatus == .denied
        }
    ///获取sip号显示格式
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
//    ///
//     @objc  func comingHangUp(){
//        self.dismiss(animated: true)
//    }
    @objc func beCalledByVoice(){
        time = 0
        l_point.isHidden = true
//        l_wait_you_speak.isHidden = true
        l_time.isHidden = false
        l_wait.isHidden = true
        self.v_mic.isHidden = false
        self.v_speak.isHidden = false
        self.v_hangup_center.isHidden = false
        self.v_becall_hangup.isHidden = true
        self.v_becall_accept.isHidden = true
//        self.v_open.isHidden = false
//            NHVoipManager.it.acceptCall(nil)
//        v_open.isHidden = false
        NHVoipManager.it.acceptCall(nil,v_our: nil)
    }
    func callout(){
//        CallOutCtrl.video = false
//        CallOutCtrl.mic = false
//        CallOutCtrl.address = self.address
//        CallOutCtrl.name = self.name
//        CallOutCtrl.openCode = self.openCode
        
        
        if self.monitorCall ==  false {
            camera.startRunning()
        }

        
        
        callOutCtrl.device = self.device

        callOutCtrl.outCall()
    }
    @objc func callBYVoice(){

        if self.device?.name == "" {
            self.lb_name.text = NHVoipManager.it.currentCall?.remoteAccount?.displayName
        }
        NHVoipManager.it.outgoingCall(with: .init(remoteAddress: self.device?.sipAddress ?? "", videoView: nil, displayName: self.device?.name))
        self.lb_sip.text = getString(str: self.device?.sipAddress ?? "")
        if self.device?.name == "" {
            if NHVoipManager.it.currentCall?.remoteAccount?.displayName == "" {
//                self.lb_name.text = NHVoipManager.it.currentCall?.remoteAccount?.username
            } else {
                self.lb_name.text = NHVoipManager.it.currentCall?.remoteAccount?.displayName
            }
        }
      
    }
    @objc func acceptIn(){
        callOutCtrl.coming = true
        self.callOutCtrl.view.isHidden = false
        callOutCtrl.time = 0
        callOutCtrl.outCall()
      
    }
    @objc func callConnected(_ state: NSNotification)
    {
       
        camera.stopRunning()
        
        callOutCtrl.time = 0
        self.countTimer.fireDate = Date()
        if self.device?.type == .card_OutdoorMachine  {
            if self.device?.isLock  == false {
                v_open.isHidden = true
            } else{
                v_open.isHidden = false
            }
        }
        if count1 == 0 {

            if  self.isVideo == false {
                time = 0
                l_time.isHidden = false
                l_wait.isHidden = true
//                v_open.isHidden = true
                l_point.isHidden = true
                v_mic.isHidden = false
                v_speak.isHidden = false
            } else {
                
                self.callOutCtrl.view.isHidden = false
                // 麦克风状态
                self.callOutCtrl.mic = NHVoipManager.it.isMicrophoneEnabled
                if(self.mic == true){
                    self.callOutCtrl.btn_mic.setImage(.init(named: "microphone_open"), for: .normal)
                    self.callOutCtrl.l_mic.text = nh_localizedString(forKey: "l_mic_on")
                } else {
                    self.callOutCtrl.btn_mic.setImage(.init(named: "microphone_close"), for: .normal)
                    self.callOutCtrl.l_mic.text = nh_localizedString(forKey: "l_mic_off")
                }
                
                // 扬声器状态
                self.callOutCtrl.speak = NHVoipManager.it.isSpeakerEnabled
                if(self.callOutCtrl.speak == true){
                    self.callOutCtrl.btn_speak.setImage(.init(named: "loudspeaker_open"), for: .normal)
                    self.callOutCtrl.l_speak.text = nh_localizedString(forKey: "l_speak_on")
                } else {
                    self.callOutCtrl.btn_speak.setImage(.init(named: "loudspeaker_close"), for: .normal)
                    self.callOutCtrl.l_speak.text =  nh_localizedString(forKey: "l_speak_off")
                }
//                callOutCtrl.lb_name.text = NHVoipManager.it.currentCall?.remoteAccount?.displayName
            }
           
            
        }
        count1 = count1 + 1
    }
    @objc func timeSample(count: Int)->String{
        let second = count%60
        let minute = count / 60
        return String.init(format: "%02ld:%02ld", minute, second)
        
    }
    @objc func countTime(){
        self.l_time.text = timeSample(count: self.time)
        time = time + 1

    }
    @objc func micAction() {
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
  
    /// 开门
    @objc func openTheDoor(){
        /*
           1. 拿通话设备 中的 code
           2. 拿通话对象，传入执行code
         */
        NHVoipManager.it.currentCall?.performAction(self.device?.openCode ?? "#", method: .DTMF_RFC_4733)
        self.v_tip.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.v_tip.isHidden = true
        }

    }
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
    @objc func changeTest(){
        if count%3 == 0 {
            self.lb_wait.text = ".."
            count =  count + 1
        } else if count%3 == 1 {
            self.lb_wait.text = "..."
            count =  count + 1
        } else  {
            self.lb_wait.text = "."
            count =  count + 1
        }
    }
    @objc func hangup(){
//        let ctrl = DevicesViewCtrl.init(nibName: "D", bundle: <#T##Bundle?#>)
        
        NHVoipManager.it.terminateCall()
//        NHVoipManager.it.terminate(<#T##call: Call##Call#>)
        self.dismiss(animated: true, completion: nil)
    }
 
}
extension CallOnViewController: NHCameraDelegete {
    /// 呈现到某视图上
    func cameraOnPreview(_ camera: NHCamera) -> UIView {
        return self.v_pre
    }
    /// 得到图片
    func camera(_ camera: NHCamera, capture image: UIImage?, originalImage: UIImage?) {
        
    }
}

