//
//  NHFont.swift
//  NHFoundation
//
//  Created by 骆亮 on 2022/3/17.
//

import UIKit

// MARK: - 字体
extension UIFont {
    
    /// 转 regular  HeiTC-W4
    /// - Returns: UIFont
    public func nh_regular() -> UIFont? {
        .init(name: "PingFangSC-Regular", size: self.pointSize)
    }
    
    /// 转 medium HeiTC-W6
    /// - Returns: UIFont
    public func nh_medium() -> UIFont? {
        .init(name: "PingFangSC-Medium", size: self.pointSize)
    }
    
    /// 转 semibold HeiTC-W8
    /// - Returns: UIFont
    public func nh_semibold() -> UIFont? {
        .init(name: "PingFangSC-Semibold", size: self.pointSize)
    }
    
    /// 转 bold 和 nh_semibold 一致
    /// - Returns: UIFont
    public func nh_bold() -> UIFont? {
        .init(name: "PingFangSC-Semibold", size: self.pointSize)
    }
    
}

// MARK: - App的字体标准，项目中可通过扩展方式新增更多样式
@objc public protocol NHAppFontsInterface {
    /// 当前字体标准信息，key - value
    func info() -> [String: UIFont]
}
public class NHAppFonts: NSObject {
    /// n - regular
    public func customFont(of size: CGFloat) -> UIFont? {
        return UIFont.systemFont(ofSize: size).nh_regular()
    }
    public override init() {}
}
// MARK: - App颜色
extension UIFont {
    struct AppFontAssociatedKey {
        static var appFont: String = "AppFontAssociatedKey"
    }
    /// app字体标准，区别于系统字体
    public static var app: NHAppFonts? {
        get {
            if let old = objc_getAssociatedObject(self, &AppFontAssociatedKey.appFont) as? NHAppFonts {
                return old
            }
            let new = NHAppFonts()
            objc_setAssociatedObject(self, &AppFontAssociatedKey.appFont, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return new
        }
        set {
            objc_setAssociatedObject(self, &AppFontAssociatedKey.appFont, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
