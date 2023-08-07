//
//  NHTabBarCtrl.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/23.
//

import UIKit
import NHFoundation
import CloudPushSDK

class NHTabBarCtrl: UITabBarController {
    
    var items: [Page] {[
        Page(title: nh_localizedString(forKey: "recently"), icon: UIImage.init(named: "Recently")! , icon_s: UIImage.init(named: "Recently_s")!, page: RecordsViewCtrl()),
        Page(title: nh_localizedString(forKey: "device"), icon: UIImage.init(named: "phonebook")!, icon_s: UIImage.init(named: "phonebook_s")!, page: DevicesViewCtrl()),
        Page(title: nh_localizedString(forKey: "set"), icon: UIImage.init(named: "set")!, icon_s: UIImage.init(named: "set_s")!, page: SettingViewCtrl()),
    ]}
    

    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.setupUI()
        self.addObserve()
        // 检测一次
        self.accountStateChanged(nil)
    }

    func setupUI() {
        self.items.forEach { item in
            let navCtrl = NHNavigationCtrl.init(rootViewController: item.page)
            navCtrl.tabBarItem.title = item.title
            navCtrl.tabBarItem.image = item.icon
            navCtrl.tabBarItem.selectedImage = item.icon_s
            self.addChild(navCtrl)
            if item.page.classForCoder != SettingViewCtrl.classForCoder() {
                navCtrl.setBarBackgroundDefault()
            }
        }
        self.selectedIndex = 0
        // 设置选中/未选中的样式
//        UITabBarItem.appearance().setTitleTextAttributes([
//            .foregroundColor: UIColor.nh_hex(0x999999),
//        ], for: .normal)
//        
//        UITabBarItem.appearance().setTitleTextAttributes([
//            .foregroundColor: UIColor(hexString: "2864aa"),
//        ], for: .selected)
        self.tabBar.tintColor = UIColor(hexString: "2864aa")
        self.tabBar.backgroundColor = UIColor(hexString: "f8f8f8")
    }
    
    func addObserve() {
        // 监听账号状态
        NotificationCenter.default.addObserver(self, selector: #selector(self.accountStateChanged(_:)), name: .init(rawValue: AccountStateChangedNoticeName), object: nil)
    }
    
    @objc func accountStateChanged(_ noti: Notification?) {
        if NHVoipManager.it.mAccount?.loginState == .Ok {
            let s1 = "sipnum="
            let s2 = "&timestamp="
            let s3 = "&password="
            let sip = NHVoipManager.it.mAccount?.username!
            let timestamp = Date().milliStamp
           
            let pwd =  NHVoipManager.it.mAccount?.password!
            let str = s1+sip!+s2+timestamp+s3+pwd!
            let device_id = CloudPushSDK.getDeviceId()
            let newStr = str.sha256.uppercased()
            NHVoipRequest.it.bindDevice(SIPNUM: sip!, SIGN: newStr, device_id: device_id!, TIMESTAMP: String(timestamp))
        }
    }

}


struct Page {
    var title: String = ""
    var icon: UIImage = .init()
    var icon_s: UIImage = .init()
    var page: UIViewController
}
