//
//  AppDelegate.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/23.
//

import UIKit
import linphonesw
import CloudPushSDK
import UserNotifications
import Alamofire
import NHFoundation
import AVFAudio

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let CallStateChangedNotice = "CallStateChangedNotice"

    var isForceLandscape:Bool = false
    var isForcePortrait:Bool = false
    var isForceAllDerictions:Bool = false //支持所有方向
    var constacts: [ [String : Any]] {
        (UserDefaults.standard.array(forKey: "message") as? [[String: Any]]) ?? []
    }
    var falseType = false
    var callInfo : [[String: Any?]] = (UserDefaults.standard.array(forKey: "callInfo") as? [[String: Any]] ?? [])
    var comingTime: String = ""
    var connectedTime: String = ""
    var releasedTime: String = ""
    var durTime: String = ""
    var outTime: String = ""
    var isOut = false
    var isComing = false
    var isConnected = false
    var firstAdd = 0
    var jum = false
    var wrongComing = false
    var wrongClose = false
    var callType = false
    /// 设置屏幕支持的方向
        func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            if isForceAllDerictions == true {
                return .all
            } else if isForceLandscape == true {
                return .landscape
            } else if isForcePortrait == true {
                return .portrait
            }
            return .portrait
        }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 设置语言
        self.setLanguage()
        // 初始化阿里推送、注册APNS服务
        self.initCloudPush()
        self.registerAPNS(application)
        // 上报
        CloudPushSDK.sendNotificationAck(launchOptions)
        
        // 配置云对讲
        self.setupVoip()
        
        // 检测状态
        self.checkoutLoginState()
        
        /// 设置setion头部空白问题
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0.0
        }
//        if UIApplication.shared.applicationState == .background {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//                self.applicationWillResignActive(UIApplication.shared)
//            }
//        }
        
        return true
    }
    
    func setLanguage() {
        // 获取用户的语言偏好
//        let preferredLanguage = Locale.preferredLanguages.first ?? "en"// 根据用户的语言偏好设置应用程序的语言"
//        var languageCode = "en"
//        if preferredLanguage.hasPrefix("zh-Hans") {
//            languageCode = "zh-Hans"
//        } else if preferredLanguage.hasPrefix("zh-Hant") {
//            languageCode = "zh-Hant"
//        }
//
//        // 加载特定语言的本地化资源文件
//        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
//        let bundle = Bundle(path: path!)
        // 设置本地化资源文件
//        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
//        UserDefaults.standard.synchronize()
//        替换Bundle.main为自定义的MyBundle
//        NSLanguageManager.shared.language = .System
//        NSLanguageManager.saveLanguage(chooseLanguage: .System)
        object_setClass(Foundation.Bundle.main, NSBundle.self)
    }
    
    func checkoutLoginState() {
        let agree = UserDefaults.standard.bool(forKey: "protocol")
        if agree {
            let logined = UserDefaults.standard.bool(forKey: "logined")
            if logined {
                let loginState = UserDefaults.standard.array(forKey: "loginState") as? [Bool] ?? [false,false,false]
                if loginState[0] == false && loginState [1] == false && loginState[2] == false {
                    let  myinformation : [String:String] = UserDefaults.standard.dictionary(forKey: "myinfo") as? [String:String] ?? [:]
                    saveInfo(myinfo: myinformation)
                }
               
                self.pushMainPage()
            } else {
                self.pushLoginPage()
            }
            
        } else {
            self.pushProtocolPage()
        }
    }
    
    /// 配置云对讲
    func setupVoip() {
        NHVoipManager.it.setup()
        
        NHVoipManager.it.onCallStateChanged = { [self] call, state, message in
            print("---",state)
            if state == .Connected {
                NotificationCenter.default.post(name: .init(rawValue: "CallStateChangedNotice"), object: nil, userInfo: ["value" : state])
                self.isConnected = true
                self.connectedTime = self.getTime()
            } else if state == .IncomingReceived {
               
                print("-------来电，补充进入呼叫")
                if self.isOut == true {
                    NHVoipManager.it.terminate(call)
                    wrongComing = true
                    
                }else {
                    if self.wrongComing == false {
                        self.isComing = true
    //                    wrongComing = false
                        self.outTime = self.getTime()
                         let ctrl = CallOnViewController()
                        self.comingTime = self.getTime()
                        var constacts: [ [String : Any]] {
                            (UserDefaults.standard.array(forKey: "message") as? [[String: Any]]) ?? []
                        }
                        
                        ctrl.mic = true
                        ctrl.coming = true
                        ctrl.modalPresentationStyle = .custom
                        self.window?.rootViewController?.present(ctrl, animated: true, completion: nil)
                        wrongComing = true
                    } else {
                        
                        NHVoipManager.it.terminate(call)
                        wrongComing = false
    //                    NHVoipManager.it.terminateCall()
                    }
                }
                
                wrongComing = true
            } else if state == .End || state == .Released {
                if   NHVoipManager.it.currentCall?.remoteAddressString == call.remoteAddressString || NHVoipManager.it.currentCall?.remoteAddressString == nil  {
                    self.window?.rootViewController?.dismiss(animated: true)
                    wrongComing = false
                    
                    if self.isOut == true  {
                        if NHVoipCallType.it.callType != 2 { //监控不保存通话信息
                            if NHVoipCallType.it.callType == 0 {
                                callType = false
                            }else if NHVoipCallType.it.callType == 1 {
                                callType = true
                            }
                            if  self.isConnected == true {
                                addRecentInfo(name: call.remoteAccount?.username ?? "", sip: call.remoteAddressString ?? "", starTime: self.outTime, endTime: getTime(),connectedTime:self.connectedTime, callType: callType == true ? 1 : 0, resultType: 0)
                            } else {
                                addRecentInfo(name: call.remoteAccount?.username ?? "", sip: call.remoteAddressString ?? "", starTime: self.outTime, endTime: getTime(),connectedTime:self.connectedTime,  callType: callType == true ? 1 : 0, resultType: 1)
                            }
                        }
                       
                    } else if self.isComing == true {
                        if  self.isConnected == true {
                            addRecentInfo(name: call.remoteAccount?.displayName ?? call.remoteAccount?.username ?? "", sip:  call.remoteAddressString ?? "", starTime: self.outTime, endTime: getTime(),connectedTime:self.connectedTime,  callType: call.isVideoCall == true ? 1 : 0, resultType: 2)
                        } else {
                            addRecentInfo(name: call.remoteAccount?.displayName ?? call.remoteAccount?.username ?? "", sip: call.remoteAddressString ?? "", starTime: self.outTime, endTime: getTime(),connectedTime:self.connectedTime,  callType: call.isVideoCall == true ? 1 : 0, resultType: 3)
                        }
                    }
                    NotificationCenter.default.post(name: .init(rawValue: "CallReleasedNotice"), object: nil)
                    self.isOut = false
                    self.isComing = false
                    self.isConnected = false
                
                }

//                resultType - 0 呼出 接通
//                           - 1 呼出 未接
//                           - 2 来电 接通
//                           - 3 来电 未接
                
                print("------"+(call.remoteAccount?.username ?? "")+self.outTime)

                
            } else if state == .OutgoingInit {
                print("------")
                self.isOut = true
                self.outTime = self.getTime()
            }
        }
    }
    
    /// 初始化阿里推送
    func initCloudPush() {
        
        // todo
        var appKey = ""
        var appSecret = ""

        CloudPushSDK.asyncInit(appKey, appSecret: appSecret, callback: { res in
            if ((res?.success) != nil) {
                print("Push SDK init success, deviceId: \(String(describing: CloudPushSDK.getDeviceId())).")
            } else {
                if let anError = res?.error {
                    print("Push SDK init failed, error: \(anError)")
                }
            }
        })
    }
    func showWindowHome(windowType: String){
        if windowType == "loginOut" {
            let loginVC = LoginViewController()
            let loginNav = UINavigationController.init(rootViewController: loginVC)
            self.window?.rootViewController = loginNav
        }
    }
    /// 注册APNS服务
    func registerAPNS(_ application: UIApplication?) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { result, error in
                if result {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else if #available(iOS 8.0, *) {
            application?.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    types: [.sound, .alert, .badge],
                    categories: nil))
            application?.registerForRemoteNotifications()
        } else {
            
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CloudPushSDK.registerDevice(deviceToken, withCallback: { res in
            if ((res?.success) != nil) {
                print("Register deviceToken success.")
            } else {
                if let anError = res?.error {
                    print("Register deviceToken failed, error: \(anError)")
                }
            }
        })
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError \(error)")
    }
    
    func getTime() -> String {
        let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyyMMddHHmmss"
        let strNowTime = timeFormatter.string(from: date as Date) as String
        return strNowTime
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) { }
    /// callType 0 : 语音，1: 视频， 2：监控
    func addRecentInfo(name: String,sip: String,starTime: String,endTime: String,connectedTime: String,callType: Int, resultType: Int){
        print("iiiii" + String(NHVoipCallType.it.callType))
        callInfo = UserDefaults.standard.array(forKey: "callInfo") as? [[String: Any]] ?? []
        callInfo.append([
            "name": name,
            "sip": sip,
            "starTime": starTime,
            "endTime":endTime,
            "connectedTime":connectedTime,
            "callType":callType,
                "resultType":resultType
        ])
        UserDefaults.standard.setValue(callInfo, forKey: "callInfo")
        UserDefaults.standard.synchronize()
    }
    // 应用被杀死
//    func applicationWillTerminate(_ application: UIApplication) {
//        NHVoipManager.it.stop()
//    }
    /// 解决iOS 15 tableview 头部空白
   
    // 保存用户信息
    func saveInfo(myinfo: Dictionary<String, String>){
        let displayName = myinfo["dispalyName"] ?? ""
        let account = myinfo["account"] ?? ""
        let pwd = myinfo["pwd"] ?? ""
        let serve = myinfo["serve"] ?? ""
        let port = myinfo["port"] ?? ""
        let trans = myinfo["trans"] ?? "0"
        let privacy = myinfo["privacy"] ?? "0"
        let regis = myinfo["regis"] ?? "1800"
        NHVoipManager.it.loginWith(username: account, passwd: pwd, domain: serve, port: port, displayName: displayName, transportType: TransportType(rawValue: Int(trans)!)! , privacy: UInt(privacy ), expires: UInt(regis))
    }
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        NHVoipManager.it.addDelegate()
//        NHVoipManager.it.start()
//        NHVoipManager.it.ensureRegistered()
//        NHVoipManager.it.enterForeground()
//        NHVoipManager.it.resumeCall()
//    }
    
//    func applicationWillResignActive(_ application: UIApplication) {
//        NHVoipManager.it.enterBackground()
//        NHVoipManager.it.stop()
//        NHVoipManager.it.removeDelegate()
//        NHVoipManager.it.resumeCall()
//    }

}


extension AppDelegate {
    
    // 跳转主页
    public func pushMainPage() {
        if let _ = self.window {
            self.window?.rootViewController = NHTabBarCtrl()
            return
        }
        print("    ")
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = NHTabBarCtrl()
        self.window?.makeKeyAndVisible()
    }
    // 跳转初始协议页面
    public func pushProtocolPage() {
        if let _ = self.window {
            self.window?.rootViewController = FirstViewController()
            print("")
            return
        }
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = FirstViewController()
        self.window?.makeKeyAndVisible()
    }
    // 跳转登录页面
    public func pushLoginPage() {
        if let _ = self.window {
            self.window?.rootViewController = LoginViewController()
            return
        }
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = LoginViewController()
        self.window?.makeKeyAndVisible()
    }
    
}
