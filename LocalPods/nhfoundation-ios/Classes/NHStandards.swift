//
//  NHStandards.swift
//  NHDemo
//
//  Created by 骆亮 on 2022/3/18.
//

/*
 该标准化中的 xib 属性需要配合【NHAppColors】和【NHAppFonts】食用
 代码快捷使用方式则非必需
 */

import UIKit
import Foundation

// MARK: - 标准类型，用于代码快捷设置样式
public enum NHStandardsType {
    /// 字体
    case Font(UIFont?)
    /// 文本颜色
    case Color(UIColor?)
    /// 占位符字体
    case PFont(UIFont?)
    /// 占位符颜色
    case PColor(UIColor?)
}


public extension UIColor {
    /// 通过字符获取到对应颜色
    static func nh_init(with string: String) -> UIColor? {
        guard let app: NHAppColorsInterface = UIColor.app as? NHAppColorsInterface else {
            print("⚠️：请在 NHAppColors 中通过 extension 实现协议 NHAppColorsInterface ")
            return nil
        }
        return app.info()[string]
    }
}


public extension UIFont {
    /// 通过字符获取到对应字体
    static func nh_init(with string: String) -> UIFont? {
        guard let app: NHAppFontsInterface = UIFont.app as? NHAppFontsInterface else {
            print("⚠️：请在 NHAppFonts 中通过 extension 实现协议 NHAppFontsInterface ")
            return nil
        }
        return app.info()[string]
    }
    /// 转换对应样式
    func nh_to(_ string: String) -> UIFont? {
        var font_new: UIFont?
        switch string {
        case "regular":
            font_new = self.nh_regular()
            break
        case "medium":
            font_new = self.nh_medium()
            break
        case "bold":
            font_new = self.nh_semibold()
            break
        default:
            break
        }
        return font_new
    }
}


// MARK: - UIView - xib属性
public extension UIView {
    @IBInspectable var nhBGColor: String {
        get { return "" }
        set { self.backgroundColor = .nh_init(with: newValue) }
    }
}


// MARK: - UILabel - xib属性
public extension UILabel {
    /// 自定义字体
    @IBInspectable var nhFont: String {
        get { return "" }
        set { self.font = .nh_init(with: newValue) }
    }
    /// 自定义样式
    @IBInspectable var nhFontStyle: String {
        get { return "" }
        set { self.font = self.font.nh_to(newValue) }
    }
    /// 自定义颜色
    @IBInspectable var nhTextColor: String {
        get { return "" }
        set { self.textColor = .nh_init(with: newValue) }
    }
    /// 代码类快捷设置
    func nh_style(_ styles:NHStandardsType...) {
        for style in styles {
            switch style {
            case let .Font(font):
                self.font = font
            case let .Color(color):
                self.textColor = color
            default:
                break
            }
        }
    }
}


// MARK: - UIButton - xib属性
public extension UIButton {
    /// 自定义字体
    @IBInspectable var nhFont: String {
        get { return "" }
        set { self.titleLabel?.font = .nh_init(with: newValue)}
    }
    /// 自定义样式
    @IBInspectable var nhFontStyle: String {
        get { return "" }
        set { self.titleLabel?.font = self.titleLabel?.font.nh_to(newValue) }
    }
    /// 自定义颜色
    @IBInspectable var nhTextColor: String {
        get { return "" }
        set { self.setTitleColor(.nh_init(with: newValue), for: .normal) }
    }
    /// 代码类快捷设置
    func nh_style(_ styles:NHStandardsType...) {
        for style in styles {
            switch style {
            case let .Font(font):
                self.titleLabel?.font = font
            case let .Color(color):
                self.setTitleColor(color, for: .normal)
            default:
                break
            }
        }
    }
}


// MARK: - UITextField - xib属性
public extension UITextField {
    /// 自定义字体
    @IBInspectable var nhFont: String {
        get { return "" }
        set { self.font = .nh_init(with: newValue) }
    }
    /// 自定义样式
    @IBInspectable var nhFontStyle: String {
        get { return "" }
        set { self.font = self.font?.nh_to(newValue) }
    }
    /// 自定义颜色
    @IBInspectable var nhTextColor: String {
        get { return "" }
        set { self.textColor = .nh_init(with: newValue) }
    }
    /// 自定义颜色
    @IBInspectable var nhPlaceColor: String {
        get { return "" }
        set {
            var cr:UIColor = .nh_init(with: newValue) ?? UIColor.gray.withAlphaComponent(0.7)
            if cr == UIColor.white {
                cr = UIColor.gray.withAlphaComponent(0.7)
            }
            if let attr_old = self.attributedPlaceholder {
                let attr_new = NSMutableAttributedString.init(attributedString: attr_old)
                attr_new.addAttribute(NSAttributedString.Key.foregroundColor, value: cr, range: .init(location: 0, length: attr_new.length))
                self.attributedPlaceholder = attr_new
            } else {
                let attr_new = NSMutableAttributedString.init(string: self.placeholder ?? "")
                attr_new.addAttribute(NSAttributedString.Key.foregroundColor, value: cr, range: .init(location: 0, length: attr_new.length))
                self.attributedPlaceholder = attr_new
            }
        }
    }
    /// 自定义样式
    /// 一般情况下，占位符的字体大小和输入的内容字体大小保持一致
    @IBInspectable var nhPlaceStyle: String {
        get { return "" }
        set {
            if let attr_old = self.attributedPlaceholder {
                let attr_new = NSMutableAttributedString.init(attributedString: attr_old)
                let ft: UIFont? = self.font?.nh_to(newValue)
                attr_new.addAttribute(NSAttributedString.Key.font, value: ft ?? self.font!, range: .init(location: 0, length: attr_new.length))
                self.attributedPlaceholder = attr_new
            } else {
                let attr_new = NSMutableAttributedString.init(string: self.placeholder ?? "")
                let ft: UIFont? = self.font?.nh_to(newValue)
                attr_new.addAttribute(NSAttributedString.Key.font, value: ft ?? self.font!, range: .init(location: 0, length: attr_new.length))
                self.attributedPlaceholder = attr_new
            }
        }
    }
    /// 代码类快捷设置
    func nh_style(_ styles:NHStandardsType...) {
        for style in styles {
            switch style {
            case let .Font(font):
                self.font = font
            case let .Color(color):
                self.textColor = color
            case let .PColor(color):
                let cr:UIColor = color ?? UIColor.gray.withAlphaComponent(0.7)
                if let attr_old = self.attributedPlaceholder {
                    let attr_new = NSMutableAttributedString.init(attributedString: attr_old)
                    attr_new.addAttribute(NSAttributedString.Key.foregroundColor, value: cr, range: .init(location: 0, length: attr_new.length))
                    self.attributedPlaceholder = attr_new
                } else {
                    let attr_new = NSMutableAttributedString.init(string: self.placeholder ?? "")
                    attr_new.addAttribute(NSAttributedString.Key.foregroundColor, value: cr, range: .init(location: 0, length: attr_new.length))
                    self.attributedPlaceholder = attr_new
                }
            case let .PFont(font):
                if let attr_old = self.attributedPlaceholder {
                    let attr_new = NSMutableAttributedString.init(attributedString: attr_old)
                    let ft: UIFont? = font
                    attr_new.addAttribute(NSAttributedString.Key.font, value: ft ?? self.font!, range: .init(location: 0, length: attr_new.length))
                    self.attributedPlaceholder = attr_new
                } else {
                    let attr_new = NSMutableAttributedString.init(string: self.placeholder ?? "")
                    let ft: UIFont? = font
                    attr_new.addAttribute(NSAttributedString.Key.font, value: ft ?? self.font!, range: .init(location: 0, length: attr_new.length))
                    self.attributedPlaceholder = attr_new
                }
            }
        }
    }
}

