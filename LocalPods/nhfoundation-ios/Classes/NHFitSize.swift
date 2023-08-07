//
//  NHFitSize.swift
//  NHFoundation_Example
//
//  Created by 骆亮 on 2021/11/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

@objc public enum SwiftyFitType: Int {
    /// Original Value
    case none = 0
    /// ~
    case flexible = 1
    /// ≈
    case force = 2
}

fileprivate let ScreenW = UIScreen.main.bounds.width

let uiScreenSize: CGSize = {
    return UIScreen.main.bounds.size
}()

let uiSizeScale: CGFloat = {
    return max(1, min(min(uiScreenSize.width, uiScreenSize.height) / 320, 4))
}()

let uiSizeLowScale: CGFloat = {
    switch UI_USER_INTERFACE_IDIOM() {
    case .phone:
        return uiScreenSize.width / 375.0
    default:
        return 1.4
    }
}()

@objc public final class SwiftyFitsize: NSObject {
    static let shared = SwiftyFitsize()
    private override init() { }
    
    @objc public class func sharedSwiftyFitsize() -> SwiftyFitsize {
        return SwiftyFitsize.shared
    }
    
    /// 默认参照宽度
    @objc public private(set) var referenceW: CGFloat = 375
    /// 默认 iPad 适配缩放倍数 (0 , 1]
    @objc public private(set) var iPadFitMultiple: CGFloat = 0.5
    
    /// 设置参照的相关参数
    ///
    /// - Parameters:
    ///   - width: 参照的宽度
    ///   - iPadFitMultiple: iPad 在适配后所得值的倍数 (0 , 1]
    @objc public static func reference(
        width: CGFloat,
        iPadFitMultiple: CGFloat
    ) {
        SwiftyFitsize.shared.referenceW = width
        SwiftyFitsize.shared.iPadFitMultiple =
            (iPadFitMultiple > 1 || iPadFitMultiple < 0) ? 1 : iPadFitMultiple
    }
    
    fileprivate func fitNumberSize(
        _ value: CGFloat,
        fitType: SwiftyFitType
    ) -> CGFloat {
        switch fitType {
        case .none: return value
        case .flexible:
            switch UI_USER_INTERFACE_IDIOM() {
            case .phone:
                let width = min(uiScreenSize.width, uiScreenSize.height)
                let scale = width / 375.0
                return max(1, scale)*value
            default:
                return 1.4*value
            }
            
        case .force:
            switch UI_USER_INTERFACE_IDIOM() {
            case .phone:
                let height = max(uiScreenSize.width, uiScreenSize.height)
                let scale = height / 667
                return max(1, scale)*value
            default:
                return referenceW*value
            }
        }
    }
    
    fileprivate func fitFontSize(
        _ font : UIFont,
        type: SwiftyFitType
    ) -> UIFont {
        switch type {
        case .flexible: return font~
        case .force: return font≈
        default: return font
        }
    }
}

// MARK:- SwiftyFitsize

/*
 * ~ : 当设备为iPad时，适配后的 value 会再乘上 iPadFitMultiple
 * ≈ : 强制适配，不论是iPhone还是iPad 都不会乘上 iPadFitMultiple
 */


// MARK: 重新符号 ~
postfix operator ~
public postfix func ~ (value: CGFloat) -> CGFloat {
    return SwiftyFitsize.shared.fitNumberSize(value, fitType: .flexible)
}
public postfix func ~ (font: UIFont) -> UIFont {
    return UIFont(name: font.fontName, size: font.pointSize~) ?? font
}
public postfix func ~ (value: Int) -> CGFloat {
    return CGFloat(value)~
}
public postfix func ~ (value: Float) -> CGFloat {
    return CGFloat(value)~
}
public postfix func ~ (value: CGPoint) -> CGPoint {
    return CGPoint(
        x: value.x~,
        y: value.y~
    )
}
public postfix func ~ (value: CGSize) -> CGSize {
    return CGSize(
        width: value.width~,
        height: value.height~
    )
}
public postfix func ~ (value: CGRect) -> CGRect {
    return CGRect(
        x: value.origin.x~,
        y: value.origin.y~,
        width: value.size.width~,
        height: value.size.height~
    )
}
public postfix func ~ (value: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(
        top: value.top~,
        left: value.left~,
        bottom: value.bottom~,
        right: value.right~
    )
}

// MARK: 重写符号 ≈
postfix operator ≈
public postfix func ≈ (value: CGFloat) -> CGFloat {
    return SwiftyFitsize.shared.fitNumberSize(value, fitType: .force)
}
public postfix func ≈ (font: UIFont) -> UIFont {
    return UIFont(name: font.fontName, size: font.pointSize≈) ?? font
}
public postfix func ≈ (value: Int) -> CGFloat {
    return CGFloat(value)≈
}
public postfix func ≈ (value: Float) -> CGFloat {
    return CGFloat(value)≈
}
public postfix func ≈ (value: CGPoint) -> CGPoint {
    return CGPoint(
        x: value.x≈,
        y: value.y≈
    )
}
public postfix func ≈ (value: CGSize) -> CGSize {
    return CGSize(
        width: value.width≈,
        height: value.height≈
    )
}
public postfix func ≈ (value: CGRect) -> CGRect {
    return CGRect(
        x: value.origin.x≈,
        y: value.origin.y≈,
        width: value.size.width≈,
        height: value.size.height≈
    )
}
public postfix func ≈ (value: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(
        top: value.top≈,
        left: value.left≈,
        bottom: value.bottom≈,
        right: value.right≈
    )
}

// MARK:- Xib/Storyboard 中添加适配参数
public extension NSLayoutConstraint {
    @IBInspectable var swiftyFitType: Int {
        get { return SwiftyFitType.none.rawValue }
        set {
            guard let type = SwiftyFitType(rawValue: newValue) else { return }
            constant =  SwiftyFitsize.shared.fitNumberSize(constant, fitType: type)
        }
    }
}
public extension UILabel {
    @IBInspectable var fontFitType: Int {
        get { return SwiftyFitType.none.rawValue }
        set {
            guard let type = SwiftyFitType(rawValue: newValue) else { return }
            guard let xfont = font else { return }
            self.font =  SwiftyFitsize.shared.fitFontSize(xfont, type: type)
            self.layoutIfNeeded()
        }
    }
}
public extension UITextView {
    @IBInspectable var fontFitType: Int {
        get { return SwiftyFitType.none.rawValue }
        set {
            guard let type = SwiftyFitType(rawValue: newValue) else { return }
            guard let xfont = font else { return }
            self.font =  SwiftyFitsize.shared.fitFontSize(xfont, type: type)
            self.layoutIfNeeded()
        }
    }
}
public extension UITextField {
    @IBInspectable var fontFitType: Int {
        get { return SwiftyFitType.none.rawValue }
        set {
            guard let type = SwiftyFitType(rawValue: newValue) else { return }
            guard let xfont = font else { return }
            self.font =  SwiftyFitsize.shared.fitFontSize(xfont, type: type)
            self.layoutIfNeeded()
        }
    }
}
public extension UIButton {
    @IBInspectable var fontFitType: Int {
        get { return SwiftyFitType.none.rawValue }
        set {
            guard let type = SwiftyFitType(rawValue: newValue) else { return }
            guard let xfont = titleLabel?.font else { return }
            self.titleLabel?.font =  SwiftyFitsize.shared.fitFontSize(xfont, type: type)
            self.layoutIfNeeded()
        }
    }
}


// MARK:- 适配OC环境
public extension UIFont {
    @objc var sn: UIFont { return self~ }
    @objc var snz: UIFont { return self≈ }
}
public extension SwiftyFitsize {
    @objc func sn_int(_ value: Int) -> CGFloat {
        return value~
    }
    @objc func sn_float(_ value: CGFloat) -> CGFloat {
        return value~
    }
    @objc func sn_point(_ value: CGPoint) -> CGPoint {
        return value~
    }
    @objc func sn_size(_ value: CGSize) -> CGSize {
        return value~
    }
    @objc func sn_rect(_ value: CGRect) -> CGRect {
        return value~
    }
    @objc func sn_EdgeInsets(_ value: UIEdgeInsets) -> UIEdgeInsets {
        return value~
    }
    
    @objc func snz_int(_ value: Int) -> CGFloat {
        return value≈
    }
    @objc func snz_float(_ value: CGFloat) -> CGFloat {
        return value≈
    }
    @objc func snz_point(_ value: CGPoint) -> CGPoint {
        return value≈
    }
    @objc func snz_size(_ value: CGSize) -> CGSize {
        return value≈
    }
    @objc func snz_rect(_ value: CGRect) -> CGRect {
        return value≈
    }
    @objc func snz_EdgeInsets(_ value: UIEdgeInsets) -> UIEdgeInsets {
        return value≈
    }
}
