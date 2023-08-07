//
//  NHButton.swift
//  zhenro-iOS
//
//  Created by 骆亮 on 2022/1/12.
//  Copyright © 2022 NexHome. All rights reserved.
//

import UIKit

// MARK: - 下划线
extension UIButton {
    
    /// 添加下划线
    public func nh_underline() {
        if let attributedText = self.titleLabel?.attributedText { // 已经是富文本的情况下
            let attributedString = NSMutableAttributedString.init(attributedString: attributedText)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedText.string.count))
            self.setAttributedTitle(attributedString, for: .normal)
        } else if let text = self.titleLabel?.text { // 纯文本
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
            self.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
}

// MARK: - 回调
extension UIButton {
    
    struct associatedKeys {
        static var blocksKey: String = "blocksKey"
    }

    /// 各种事件
    private var eventBlocks: [String: [Any]] {
        get {
            if let old = objc_getAssociatedObject(self, &associatedKeys.blocksKey) as? [String: [Any]] {
                return old
            }
            let new = [String: [Any]]()
            objc_setAssociatedObject(self, &associatedKeys.blocksKey, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return new
        }
        set {
            objc_setAssociatedObject(self, &associatedKeys.blocksKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 添加按钮点击事件，1对n，可同时添加多个事件回调
    /// - Parameter block: 事件触发回调
    public func nh_addClickEvent(_ block:@escaping ((_ btn:UIButton)->Void)) {
        self.nh_addEvent(.touchUpInside, block)
    }
    
    /// 添加按钮事件，1对n，可同时添加多个事件回调
    /// - Parameters:
    ///   - controlEvents: 按钮各种事件
    ///   - block: 事件触发回调
    public func nh_addEvent(_ controlEvents: UIControl.Event, _ block:@escaping ((_ btn:UIButton)->Void)) {
        var sel: Selector? = nil;
        switch controlEvents {
        case .touchDown:
            sel = #selector(touchDown)
        case .touchDownRepeat:
            sel = #selector(touchDownRepeat)
        case .touchDragInside:
            sel = #selector(touchDragInside)
        case .touchDragOutside:
            sel = #selector(touchDragOutside)
        case .touchDragEnter:
            sel = #selector(touchDragEnter)
        case .touchDragExit:
            sel = #selector(touchDragExit)
        case .touchUpInside:
            sel = #selector(touchUpInside)
        case .touchUpOutside:
            sel = #selector(touchUpOutside)
        case .touchCancel:
            sel = #selector(touchCancel)
        default:
            break
        }
        if let sel = sel {
            var array:[Any] = self.eventBlocks[NSStringFromSelector(sel)] ?? []
            array.append(block)
            self.eventBlocks[NSStringFromSelector(sel)] = array
            self.addTarget(self, action: sel, for: controlEvents)
        }
    }
    @objc func touchDown() { self.block(cmd: "touchDown") }
    @objc func touchDownRepeat() { self.block(cmd: "touchDownRepeat") }
    @objc func touchDragInside() { self.block(cmd: "touchDragInside") }
    @objc func touchDragOutside() { self.block(cmd: "touchDragOutside") }
    @objc func touchDragEnter() { self.block(cmd: "touchDragEnter") }
    @objc func touchDragExit() { self.block(cmd: "touchDragExit") }
    @objc func touchUpInside() { self.block(cmd: "touchUpInside") }
    @objc func touchUpOutside() { self.block(cmd: "touchUpOutside") }
    @objc func touchCancel() { self.block(cmd: "touchCancel") }
    private func block(cmd: String) {
        if var array = self.eventBlocks[cmd] as? [((UIButton) -> Void)] {
            array.reverse() // 系统的Action是栈形式
            array.forEach { block in
                block(self)
            }
        }
    }
    
}

