//
//  NHVoipAccount.swift
//  NEXcom
//
//  Created by 骆亮 on 2022/9/16.
//

import UIKit
import linphonesw

let AccountStateChangedNoticeName = "AccountStateChangedNoticeName"

/// 用户信息
public class NHVoipAccount: NSObject {
    
    /// 用户名
    var username : String?
    /// 显示名
    var displayName : String?
    /// 密码
    var password : String?
    /// 服务域名
    var domain : String?
    /// 端口号
    var port : String?
    
    /// linphone的账号对象
    var coreAccount: Account?
    
    /// 账号状态
    var loginState: RegistrationState = .None {
        didSet {
            let notiName: Notification.Name = .init(rawValue: AccountStateChangedNoticeName)
            NotificationCenter.default.post(name: notiName, object: nil, userInfo: [ "value" : self.loginState ])
            if loginState == .Ok {
                print("hhhhhh")
            }
        }
    }
    
    init(username : String?, displayName : String?, password : String?, domain : String?, port : String?) {
        self.username = username
        self.displayName = displayName
        self.password = password
        self.domain = domain
        self.port = port
    }
    
}
