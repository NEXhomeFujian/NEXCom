//
//  NHApplication.swift
//  zhenro-iOS
//
//  Created by 骆亮 on 2021/11/10.
//  Copyright © 2021 NexHome. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import MobileCoreServices
import MessageUI

// MARK: - 助手
public class NHApplication: NSObject {
    static var shared: NHApplication = NHApplication()
    
    public enum Style: String {
        /// 应用名称
        case displayName = "CFBundleDisplayName"
        /// 版本号：1.0.1
        case shortVersion = "CFBundleShortVersionString"
        /// 版本号：2111081
        case version = "CFBundleVersion"
        /// 包名
        case identifier = "CFBundleIdentifier"
        /// and so on
    }
    
    public enum Authorization: Int {
        /// 相册权限
        case photo
        /// 相机权限
        case camera
        /// 定位权限
        case location
    }
    
    /// 获取图片回调
    public var imageBlock:((UIImage?, [UIImagePickerController.InfoKey : Any]) -> Void)?
    
    /// 发送短信的回调
    public var sendMessageBlock: ((MessageComposeResult) -> Void)?
}


// MARK: - 应用的当前控制器
extension UIApplication {
    
    /// 获取当前控制器
    /// - Returns: 控制器
    public func nh_currentViewController() -> UIViewController {
        let ctrl = UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
        return self.findBestViewController(ctrl)
    }
    
    private func findBestViewController(_ ctrl: UIViewController) -> UIViewController {
        if ctrl.presentedViewController != nil {
            return self.findBestViewController(ctrl.presentedViewController!)
        } else if let svCtrl: UISplitViewController = ctrl as? UISplitViewController {
            if svCtrl.viewControllers.count > 0 {
                return self.findBestViewController(svCtrl.viewControllers.last!)
            }
            return svCtrl
        } else if let navCtrl: UINavigationController = ctrl as? UINavigationController {
            if navCtrl.viewControllers.count > 0 {
                return self.findBestViewController(navCtrl.topViewController!)
            }
            return navCtrl
        } else if let tabCtrl: UITabBarController = ctrl as? UITabBarController {
            if let selectedCtrl = tabCtrl.selectedViewController {
                return self.findBestViewController(selectedCtrl)
            } else if tabCtrl.viewControllers?.count ?? 0 > 0 {
                return self.findBestViewController(tabCtrl.viewControllers![0])
            }
            return tabCtrl
        } else {
            return ctrl
        }
    }
    
}


// MARK: - 应用信息
extension UIApplication {
    
    /// 应用所有信息
    public var nh_info: [String: Any]? {
        return Bundle.main.infoDictionary
    }
    
    /// 应用名称
    public func nh_name() -> String? {
        let value:String? = self.nh_info(.displayName) as? String
        guard let val = value else { return self.nh_info?["CFBundleName"] as? String }
        return val
    }
    
    /// 应用版本信息：1.0.1
    public func nh_shortVersion() -> String? {
        let value:String? = self.nh_info(.shortVersion) as? String
        return value
    }
    
    /// 应用版本信息：2111081
    public func nh_version() -> String? {
        let value:String? = self.nh_info(.version) as? String
        return value
    }
    
    /// 应用包名
    public func nh_bundleIdentifier() -> String? {
        let value:String? = self.nh_info(.identifier) as? String
        return value
    }
    
    /// 获取应用信息
    /// - Parameter style: 内置类型
    /// - Returns: 查找结果
    public func nh_info(_ style: NHApplication.Style) -> Any? {
        let value = self.nh_info?[style.rawValue]
        return value
    }
    
}


// MARK: - 私有权限
extension UIApplication {
    
    public enum AuthorizationStatus : Int {
        /// 未决定，未触发
        case notDetermined = 0
        /// 拒绝
        case denied = 1
        /// 允许
        case authorized = 2
        /// 未开启服务
        case servicesUnabled = 100
    }
    
    /// 检测相关隐私权限
    /// - Parameter p: 内置权限类型
    /// - Returns: 结果，返回 nil 表示还用户未决定，需触发权限
    public func nh_checkAuthorization(_ p: NHApplication.Authorization) -> AuthorizationStatus {
        switch p {
        case .photo:
            let auth = PHPhotoLibrary.authorizationStatus()
            if auth == .denied || auth == .restricted {
                return .denied
            } else if auth == .notDetermined {
                return .notDetermined
            }
            return .authorized
        case .camera:
            let auth = AVCaptureDevice.authorizationStatus(for: .video)
            if auth == .denied || auth == .restricted {
                return .denied
            } else if auth == .notDetermined {
                return .notDetermined
            }
            return .authorized
        case .location:
            if CLLocationManager.locationServicesEnabled() == false {
                return .servicesUnabled
            } else { // 用户手机开启定位服务
                var auth: CLAuthorizationStatus = .notDetermined
                if #available(iOS 14.0, *) {
                    auth = CLLocationManager().authorizationStatus
                } else {
                    auth = CLLocationManager.authorizationStatus()
                }
                if auth == .denied || auth == .restricted {
                    return .denied
                } else if auth == .notDetermined {
                    return .notDetermined
                }
                return .authorized
            }
        }
    }
    
    /// 获取相关隐私权限
    /// - Parameters:
    ///   - p: 内置权限类型
    ///   - handler: 处理回调
    public func nh_requestAuthorization(_ p: NHApplication.Authorization,_ handler: (@escaping (Bool) -> Void)) {
        switch p {
        case .photo:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async { // 回主线程
                    handler(status == .authorized)
                }
            }
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { status in
                DispatchQueue.main.async { // 回主线程
                    handler(status)
                }
            }
        case .location:
            print("请使用 CLLocationManager 的 request 方式获取对应权限\n 获取定位信息请使用 NHLocationManager")
            break
        }
    }
    
    /// 拍照
    /// - Parameters:
    ///   - handler: 是否有权限回调
    ///   - image: 图片结果
    public func nh_takePicture(_ handler:((Bool) -> Void)?, image:((UIImage?, [UIImagePickerController.InfoKey : Any]) -> Void)?) {
        let auth = self.nh_checkAuthorization(.camera)
        if auth == .notDetermined {
            // 用户没有决定
            self.nh_requestAuthorization(.camera) { value in
                if value { // 有权限了
                    self.nh_takePicture(handler, image: image)
                } else {
                    handler?(false)
                }
            }
            return
        }
        guard auth == .authorized else { // 必须有权限
            handler?(false)
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == false {
            print("模拟器中无法打开照相机,请在真机中使用")
            return
        }
        NHApplication.shared.imageBlock = image
        let imagePickerCtrl:UIImagePickerController = UIImagePickerController.init()
        imagePickerCtrl.sourceType = UIImagePickerController.SourceType.camera
        imagePickerCtrl.delegate = NHApplication.shared
        imagePickerCtrl.cameraDevice = UIImagePickerController.CameraDevice.front
        imagePickerCtrl.mediaTypes = [kUTTypeImage as String]
        imagePickerCtrl.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.nh_currentViewController().present(imagePickerCtrl, animated: true, completion: nil)
        }
    }
    
    
    /// 选取一张图片
    /// - Parameters:
    ///   - handler: 是否有权限回调
    ///   - image: 图片结果
    public func nh_pickPicture(_ handler:((Bool) -> Void)?, image:((UIImage?, [UIImagePickerController.InfoKey : Any]) -> Void)?) {
        let auth = self.nh_checkAuthorization(.photo)
        if auth == .notDetermined {
            // 用户没有决定
            self.nh_requestAuthorization(.photo) { value in
                if value { // 有权限了
                    self.nh_pickPicture(handler, image: image)
                } else {
                    handler?(false)
                }
            }
            return
        }
        guard auth == .authorized else { // 必须有权限
            handler?(false)
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == false {
            print("无法打开相册")
            return
        }
        NHApplication.shared.imageBlock = image
        let imagePickerCtrl:UIImagePickerController = UIImagePickerController.init()
        imagePickerCtrl.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePickerCtrl.delegate = NHApplication.shared
        imagePickerCtrl.mediaTypes = [kUTTypeImage as String]
        imagePickerCtrl.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.nh_currentViewController().present(imagePickerCtrl, animated: true, completion: nil)
        }
    }
    
    /// 保存一张图片
    /// - Parameters:
    ///   - image: 需要保存的图片
    ///   - handler: 是否有权限回调
    ///   - result: 保存结果
    public func nh_saveImage(_ image: UIImage ,_ handler:((Bool) -> Void)?, result:((Bool, Error?) -> Void)?) {
        let auth = self.nh_checkAuthorization(.photo)
        if auth == .notDetermined {
            // 用户没有决定
            self.nh_requestAuthorization(.photo) { value in
                if value { // 有权限了
                    self.nh_saveImage(image, handler, result: result)
                } else {
                    handler?(false)
                }
            }
            return
        }
        guard auth == .authorized else { // 必须有权限
            handler?(false)
            return
        }
        image.nh_saveToPhotoLibrary(result)
    }
    
}

// MARK: - 支持相册
extension NHApplication : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image:UIImage? = info[.originalImage] as? UIImage
        self.imageBlock?(image, info)
        UIApplication.shared.nh_currentViewController().dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - 打电话
extension UIApplication {
    
    /// 拨打电话，如 150****1608
    /// - Parameter phone: 电话
    /// - Returns: 是否拨打成功
    public func nh_call(_ phone:String) -> Bool {
        let phone_new = "telprompt://" + phone
        if let url = URL.init(string: phone_new), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
            return true
        }
        return false
    }
    
}


// MARK: - 发短信
extension UIApplication: MFMessageComposeViewControllerDelegate {
    
    /// 发送短信
    /// - Parameters:
    ///   - phones: 电话号码组
    ///   - body: 消息内容
    ///   - result: 结果回调
    public func nh_sendMessage(phones : Array<String>, body: String? = nil, result: ((_ result: MessageComposeResult) -> Void)?) {
        if MFMessageComposeViewController.canSendText() {
            let ctrl = MFMessageComposeViewController()
            ctrl.recipients = phones
            ctrl.body = body
            ctrl.messageComposeDelegate = self
            NHApplication.shared.sendMessageBlock = result
            ctrl.modalPresentationStyle = .fullScreen
            UIApplication.shared.nh_currentViewController().present(ctrl, animated: true, completion: nil)
        } else {
            print("该设备不支持短信功能")
        }
    }
    
    /// 消息发送完后回调
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            NHApplication.shared.sendMessageBlock?(result)
        }
    }
}


// MARK: - 系统分享
extension UIApplication {
    
    /// 系统分享
    /// - Parameters:
    ///   - excludedActivityTypes: 不需要的type，例如 message
    ///   - activityItems: 分享的内容数组，例如 String，UIImage，NSURL等等
    ///   - completedBlock: 分享结果回调
    public func nh_shareSystemWith(excludedActivityTypes: [UIActivity.ActivityType]? = nil, activityItems:(()->[Any]), completedBlock:((_ completed: Bool, _ error: Error?)->Void)? = nil) {
        let activityItems: [Any] = activityItems()
        let activityCtrl = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
        activityCtrl.excludedActivityTypes = excludedActivityTypes
        activityCtrl.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            completedBlock?(completed, error)
        }
        UIApplication.shared.nh_currentViewController().present(activityCtrl, animated: true, completion: nil)
    }
    
    /// 系统分享
    /// - Parameters:
    ///   - activityItems: 分享的内容数组，例如 String，UIImage，NSURL等等
    ///   - completedBlock: 分享结果回调
    public func nh_shareSystemWith(activityItems:(()->[Any]), completedBlock:((_ completed: Bool, _ error: Error?)->Void)? = nil) {
        self.nh_shareSystemWith(excludedActivityTypes: nil, activityItems: activityItems, completedBlock: completedBlock)
    }
    
    /// 系统分享
    /// - Parameters:
    ///   - excludedActivityTypes: 不需要的type，例如 message
    ///   - activityItems: 分享的内容数组，例如 String，UIImage，NSURL等等
    ///   - completedBlock: 分享结果回调
    public func nh_shareSystemWith(excludedActivityTypes: [UIActivity.ActivityType]? = nil, activityItems:[Any], completedBlock:((_ completed: Bool, _ error: Error?)->Void)? = nil) {
        self.nh_shareSystemWith(excludedActivityTypes: excludedActivityTypes, activityItems: {
            return activityItems
        }, completedBlock: completedBlock)
    }
    
    /// 系统分享
    /// - Parameters:
    ///   - activityItems: 分享的内容数组，例如 String，UIImage，NSURL等等
    ///   - completedBlock: 分享结果回调
    public func nh_shareSystemWith(activityItems:[Any], completedBlock:((_ completed: Bool, _ error: Error?)->Void)? = nil) {
        self.nh_shareSystemWith(excludedActivityTypes: nil, activityItems: activityItems, completedBlock: completedBlock)
    }
    
}
