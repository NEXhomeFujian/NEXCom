//
//  PowerViewController.swift
//  NEXcom
//
//  Created by csh on 2022/11/9.
//

import UIKit
import NHFoundation
import AVFoundation
class PowerViewController: UIViewController {

    @IBOutlet weak var con_power: NSLayoutConstraint!
    @IBOutlet weak var ima_go: UIImageView!
    @IBOutlet weak var l_go: UILabel!
    @IBOutlet weak var l_mic: UILabel!
    @IBOutlet weak var l_notice: UILabel!
    @IBOutlet weak var b_notice: UIButton!
    @IBOutlet weak var b_mic: UIButton!
    @IBOutlet weak var v_mic: UIView!
    @IBOutlet weak var v_notice: UIView!
    
    @IBOutlet weak var l_camera_go: UILabel!
    @IBOutlet weak var l_go_camera: UILabel!
    @IBOutlet weak var l_camera: UILabel!
    @IBOutlet weak var v_camera: UIView!
    @IBOutlet weak var b_camera: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .groupTableViewBackground
        v_mic.layer.backgroundColor = UIColor.white.cgColor
        v_mic.layer.cornerRadius = 4
        v_notice.layer.cornerRadius = 4
//        let w = UIScreen.main.bounds.width - 40
//        let h = v_mic.bounds.height
//        v_mic.nh_addShadow(CGSize(width: w, height: h),UIColor.red, 1, 1)
        setShadow(view: v_mic, sColor: UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.1), offset: CGSize(width: 0, height: 1), opacity: 1, radius: 1)
        v_mic.layer.masksToBounds = false
        setShadow(view: v_camera, sColor: UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.1), offset: CGSize(width: 0, height: 1), opacity: 1, radius: 1)
        v_camera.layer.masksToBounds = false
        
        setShadow(view: v_notice, sColor: UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.1), offset: CGSize(width: 0, height: 1), opacity: 1, radius: 1)
        v_notice.layer.masksToBounds = false
        self.title = nh_localizedString(forKey: "permissions")
        
        self.b_mic.addTarget(self, action: #selector(self.set), for: .touchUpInside)
        self.b_notice.addTarget(self, action: #selector(self.set), for: .touchUpInside)
        self.b_camera.addTarget(self, action: #selector(self.set), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(notice), name: UIApplication.didBecomeActiveNotification, object: nil)
       
    }
  
    @objc func notice(){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                {
                    if #available(iOS 10 , *)
                   {
                       UNUserNotificationCenter.current().getNotificationSettings { settings in
                           DispatchQueue.main.async {
                               if settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined {
                                   self.l_notice.text = nh_localizedString(forKey: "go_open")
                                   self.l_go.isHidden = false
                                   self.ima_go.isHidden = false
                                   self.con_power.constant = 20
                               } else{
                                   self.l_notice.text = nh_localizedString(forKey: "allowed")
                                   self.l_go.isHidden = true
                                   self.ima_go.isHidden = true
                                   self.con_power.constant = 0
                               }
                           }
                       }
        
                   } else {
                       let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
                               if isNotificationEnabled == true{
                                   print("enabled notification setting")
                               }else{
                                   print("setting has been disabled")
                               }
        
                   }
                }

    }
    override func viewWillAppear(_ animated: Bool) {
        if IsOpenMic() {
            self.l_mic.text = nh_localizedString(forKey: "allowed")
        } else {
            self.l_mic.text = nh_localizedString(forKey: "go_open")
        }
        if IsCloseCamera() {
            self.l_camera_go.text = nh_localizedString(forKey: "go_open")
        } else {
            self.l_camera_go.text = nh_localizedString(forKey: "allowed")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            if #available(iOS 10 , *)
           {
               UNUserNotificationCenter.current().getNotificationSettings { settings in
                   DispatchQueue.main.async {
                       if settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined {
                           self.l_go.isHidden = false
                           self.ima_go.isHidden = false
                           self.l_notice.text = nh_localizedString(forKey: "go_open")
                           self.con_power.constant = 20
                       } else{
                           self.l_go.isHidden = true
                           self.ima_go.isHidden = true
                           self.l_notice.text = nh_localizedString(forKey: "allowed")
                           self.con_power.constant = 0
                       }
                   }
               }

           } else {
               let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
                       if isNotificationEnabled == true{
                           print("enabled notification setting")
                       }else{
                           print("setting has been disabled")
                       }

           }
        }
        
    }
    @objc func set(){
        let settingURL = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(settingURL!){
                    UIApplication.shared.openURL(settingURL!)
                }
    }
    //是否开启麦克风
        func IsOpenMic() -> Bool{
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
            return  authStatus == .authorized
        }
   
    
}
