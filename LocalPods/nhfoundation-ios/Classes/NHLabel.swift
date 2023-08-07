//
//  NHLabel.swift
//  zhenro-iOS
//
//  Created by 骆亮 on 2022/1/12.
//  Copyright © 2022 NexHome. All rights reserved.
//

import UIKit

// MARK: - 下划线
extension UILabel {
    
    /// 添加下划线
    public func nh_underline() {
        if let attributedText = self.attributedText { // 已经是富文本的情况下
            let attributedString = NSMutableAttributedString.init(attributedString: attributedText)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedText.string.count))
            self.attributedText = attributedString
        } else if let text = self.text { // 纯文本
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
            self.attributedText = attributedString
        }
    }
    
}
