//
//  PublicTool.swift
//  NEXcom
//
//  Created by 骆亮 on 2022/10/25.
//

import UIKit
import SwiftUI
import NHFoundation
import AVFoundation
import CloudPushSDK
/// 隐私政策
let PrivacyUrlString = "" // todo
/// 是否手动断开连接
public var isReconnect = false
func hexString(_ iterator:Array<UInt8>.Iterator) -> String{
    return iterator.map{
        String(format: "%02x", $0)
    }.joined().uppercased() //字符串转成大写
}
// todo
func getCurrentPrivacyUrlString() -> String{
    let preferredLang = Locale.preferredLanguages.first! as String
    if preferredLang.contains("Hans") {
        return ""
    } else if preferredLang.contains("Hant") {
        return ""
    } else {
        return ""
    }
   
}
func getCurrentLanguage() -> String{
    let preferredLang = Locale.preferredLanguages.first! as String
    if preferredLang.contains("Hans") {
        return "cn"
    } else if preferredLang.contains("Hant") {
        return "zh-tw"
    } else {
        return "en"
    }
}
//是否开启相机权限
    func IsCloseCamera() -> Bool{
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return   authStatus == .denied || authStatus == .notDetermined
    }
//是否开启麦克风
    func IsCloseMic() -> Bool{
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        return  authStatus == .denied || authStatus == .notDetermined
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
//打开相机权限
    func openCamera() {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { (res) in
                    //此处可以判断权限状态来做出相应的操作，如改变按钮状态
                    if res{
                        DispatchQueue.main.async {
                           
                        }
                    }else{
                        DispatchQueue.main.async {
                            
                        }
                    }
                }
            }
        }
//是否开启麦克风
    func IsCloseAudioSession() -> Bool{
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        return  authStatus == .denied || authStatus == .notDetermined
    }
    func unbinding(){
        let s1 = "sipnum="
        let s2 = "&timestamp="
        let s3 = "&password="
        let sip = NHVoipManager.it.mAccount?.username!
        let timestamp = Date().milliStamp
       
        let pwd =  NHVoipManager.it.mAccount?.password!
        let str = s1+sip!+s2+timestamp+s3+pwd!
        let device_id = CloudPushSDK.getDeviceId()

        let newStr = str.sha256.uppercased()
        NHVoipRequest.it.unBindDevice(SIPNUM: sip!, SIGN: newStr, device_id: device_id!, TIMESTAMP: String(timestamp), resultBlock: nil)
    }

func setShadow(view:UIView,sColor:UIColor,offset:CGSize,
                  opacity:Float,radius:CGFloat) {
       //设置阴影颜色
       view.layer.shadowColor = sColor.cgColor
       //设置透明度
       view.layer.shadowOpacity = opacity
       //设置阴影半径
       view.layer.shadowRadius = radius
       //设置阴影偏移量
       view.layer.shadowOffset = offset
   }
extension UIApplication {

    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }

    class func topNavigation(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UINavigationController? {

        if let nav = viewController as? UINavigationController {
            return nav
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return selected.navigationController
            }
        }
        return viewController?.navigationController
        
    }
}
/// 设备类型，rawValue即为图片icon
enum DeviceType: String {
    /// 门口机
    case card_OutdoorMachine
    /// 室内机
    case card_IndoorMachine
    /// SIP话机
    case card_telephone
    /// 普通用户
    case card_user
    
    /// 设备名称
    var name: String {
        switch self {
        case .card_OutdoorMachine:
            return nh_localizedString(forKey: "outdoor")
        case .card_IndoorMachine:
            return nh_localizedString(forKey: "indoor")
        case .card_telephone:
            return nh_localizedString(forKey: "phone")
        default:
            return nh_localizedString(forKey: "stranger")
        }
    }
}
