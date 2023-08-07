//
//  NHLocalizabler.swift
//  zhenro-iOS
//
//  Created by 骆亮 on 2022/1/5.
//  Copyright © 2022 NexHome. All rights reserved.
//

import UIKit

class NHLocalizabler: NSObject {}

/// 既定的几种模块，项目中需要创建以下制定名称的语言包。如需其他语言包，请通过方法扩展方式进行分类
public enum NHLocalizableModule: String {
    /// 家居
    case SmartHome = "SmartHome"
    /// 社区
    case Community = "Community"
    /// 通用
    case Localizable = "Localizable"
    /// 错误
    case Error = "Error"
}

/// 指定Bundle
//public var NHLocalizableInBundle: Bundle = Bundle.init(for: NHLocalizableHelper.classForCoder())
public var NHLocalizableInBundle: Bundle = Bundle.main



/// 国际化，通用，Localizable文件
/// - Parameters:
///   - forKey: forKey
///   - bundle: bundle
public func nh_localizedString(forKey:String, bundle: Bundle? = nil) -> String {
    nh_localizedString(forKey: forKey, table: NHLocalizableModule.Localizable.rawValue, bundle: bundle)
}
/// 国际化，通用，Localizable文件
/// - Parameter forKey: forKey
public func nh_localizedString(forKey:String) -> String {
    nh_localizedString(forKey: forKey, bundle: nil)
}



/// 国际化，通用，SmartHome文件
/// - Parameter forKey: forKey
///   - bundle: bundle
public func nh_localInSmartHome(forKey:String, bundle: Bundle? = nil) -> String {
    nh_localizedString(forKey: forKey, table: NHLocalizableModule.SmartHome.rawValue, bundle: bundle)
}
/// 国际化，通用，SmartHome文件
/// - Parameter forKey: forKey
public func nh_localInSmartHome(forKey:String) -> String {
    nh_localInSmartHome(forKey: forKey, bundle: nil)
}



/// 国际化，通用，Community文件
/// - Parameter forKey: forKey
///   - bundle: bundle
public func nh_localInCommunity(forKey:String, bundle: Bundle? = nil) -> String {
    nh_localizedString(forKey: forKey, table: NHLocalizableModule.Community.rawValue, bundle: bundle)
}
/// 国际化，通用，Community文件
/// - Parameter forKey: forKey
public func nh_localInCommunity(forKey:String) -> String {
    nh_localInCommunity(forKey: forKey, bundle: nil)
}



/// 国际化，通用，Error文件
/// - Parameter forKey: forKey
///   - bundle: bundle
public func nh_localInError(forKey:String, bundle: Bundle? = nil) -> String {
    nh_localizedString(forKey: forKey, table: NHLocalizableModule.Error.rawValue, bundle: bundle)
}
/// 国际化，通用，Error文件
/// - Parameter forKey: forKey
public func nh_localInError(forKey:String) -> String {
    nh_localInError(forKey: forKey, bundle: nil)
}



// MARK: - 指定文件，注意：本地化文件名称要一致
/// 国际化，需要指定文件名，注意：本地化文件名称要一致
/// - Parameters:
///   - forKey: forKey
///   - module: 指定文件
///   - bundle: bundle
public func nh_localizedString(forKey:String, in module: NHLocalizableModule, bundle: Bundle? = nil) -> String {
    nh_localizedString(forKey: forKey, table: module.rawValue, bundle: bundle)
}
/// 国际化，需要指定文件名，注意：本地化文件名称要一致
/// - Parameters:
///   - forKey: forKey
///   - module: 指定文件
public func nh_localizedString(forKey:String, in module: NHLocalizableModule) -> String {
    nh_localizedString(forKey: forKey, in: module, bundle: nil)
}



// MARK: - 国际化，通用方法
/// 国际化
/// - Parameters:
///   - forKey: forKey
///   - table: 文件名
public func nh_localizedString(forKey:String, table: String, bundle: Bundle? = nil) -> String {
    let b = bundle ?? NHLocalizableInBundle
    return b.localizedString(forKey: forKey, value: "", table: table)
}
/// 国际化
/// - Parameters:
///   - forKey: forKey
///   - table: 文件名
public func nh_localizedString(forKey:String, table: String) -> String {
    let b = NHLocalizableInBundle
    return b.localizedString(forKey: forKey, value: "", table: table)
}








// MARK: - UILabel - xib属性
public extension UILabel {
    struct LabelLocAssociatedKey {
        static var key: String = "LabelLockeyAssociatedKey"
        static var bag: String = "LabelLocBagAssociatedKey"
    }
    private var locBag: String? {
        get {
            if let old = objc_getAssociatedObject(self, &LabelLocAssociatedKey.bag) as? String { return old }
            objc_setAssociatedObject(self, &LabelLocAssociatedKey.bag, "Localizable", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return "Localizable"
        }
        set {
            objc_setAssociatedObject(self, &LabelLocAssociatedKey.bag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var locKey: String? {
        get {
            if let old = objc_getAssociatedObject(self, &LabelLocAssociatedKey.key) as? String { return old }
            objc_setAssociatedObject(self, &LabelLocAssociatedKey.key, "", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return ""
        }
        set {
            objc_setAssociatedObject(self, &LabelLocAssociatedKey.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 国际化 - 包名
    @IBInspectable var nhLocBag: String {
        get { return self.locBag ?? "Localizable" }
        set {
            self.locBag = newValue
            self.text = nh_localizedString(forKey: self.nhLocKey, table: newValue, bundle: nil)
        }
    }
    /// 国际化 - key名
    @IBInspectable var nhLocKey: String {
        get { return self.locKey ?? "" }
        set {
            self.locKey = newValue
            self.text = nh_localizedString(forKey: newValue, table: self.nhLocBag, bundle: nil)
        }
    }
}






// MARK: - UIButton - xib属性
public extension UIButton {
    struct ButtonLocAssociatedKey {
        static var key: String = "ButtonLockeyAssociatedKey"
        static var bag: String = "ButtonLocBagAssociatedKey"
    }
    private var locBag: String? {
        get {
            if let old = objc_getAssociatedObject(self, &ButtonLocAssociatedKey.bag) as? String { return old }
            objc_setAssociatedObject(self, &ButtonLocAssociatedKey.bag, "Localizable", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return "Localizable"
        }
        set {
            objc_setAssociatedObject(self, &ButtonLocAssociatedKey.bag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var locKey: String? {
        get {
            if let old = objc_getAssociatedObject(self, &ButtonLocAssociatedKey.key) as? String { return old }
            objc_setAssociatedObject(self, &ButtonLocAssociatedKey.key, "", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return ""
        }
        set {
            objc_setAssociatedObject(self, &ButtonLocAssociatedKey.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 国际化 - 包名
    @IBInspectable var nhLocBag: String {
        get { return self.locBag ?? "Localizable" }
        set {
            self.locBag = newValue
            let text = nh_localizedString(forKey: self.nhLocKey, table: newValue, bundle: nil)
            self.setTitle(text, for: .normal)
        }
    }
    /// 国际化 - key名
    @IBInspectable var nhLocKey: String {
        get { return self.locKey ?? "" }
        set {
            self.locKey = newValue
            let text = nh_localizedString(forKey: newValue, table: self.nhLocBag, bundle: nil)
            self.setTitle(text, for: .normal)
        }
    }
}









// MARK: - UITextField - xib属性
public extension UITextField {
    struct TextFieldLocAssociatedKey {
        static var key: String = "TextFieldLockeyAssociatedKey"
        static var bag: String = "TextFieldLocBagAssociatedKey"
    }
    private var locBag: String? {
        get {
            if let old = objc_getAssociatedObject(self, &TextFieldLocAssociatedKey.bag) as? String { return old }
            objc_setAssociatedObject(self, &TextFieldLocAssociatedKey.bag, "Localizable", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return "Localizable"
        }
        set {
            objc_setAssociatedObject(self, &TextFieldLocAssociatedKey.bag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var locKey: String? {
        get {
            if let old = objc_getAssociatedObject(self, &TextFieldLocAssociatedKey.key) as? String { return old }
            objc_setAssociatedObject(self, &TextFieldLocAssociatedKey.key, "", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return ""
        }
        set {
            objc_setAssociatedObject(self, &TextFieldLocAssociatedKey.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 国际化 - 包名
    @IBInspectable var nhLocBag: String {
        get { return self.locBag ?? "Localizable" }
        set {
            self.locBag = newValue
            let text = nh_localizedString(forKey: self.nhLocKey, table: newValue, bundle: nil)
            if let attr = self.attributedPlaceholder {
                let attrNew = NSMutableAttributedString.init(attributedString: attr)
                attrNew.replaceCharacters(in: .init(location: 0, length: attr.length), with: text)
                self.attributedPlaceholder = attrNew
            } else {
                self.placeholder = text
            }
        }
    }
    /// 国际化 - key名
    @IBInspectable var nhLocKey: String {
        get { return self.locKey ?? "" }
        set {
            self.locKey = newValue
            let text = nh_localizedString(forKey: newValue, table: self.nhLocBag, bundle: nil)
            if let attr = self.attributedPlaceholder {
                let attrNew = NSMutableAttributedString.init(attributedString: attr)
                attrNew.replaceCharacters(in: .init(location: 0, length: attr.length), with: text)
                self.attributedPlaceholder = attrNew
            } else {
                self.placeholder = text
            }
        }
    }
}



