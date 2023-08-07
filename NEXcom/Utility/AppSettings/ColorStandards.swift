//
//  ColorStandards.swift
//  community-iOS
//
//  Created by 骆亮 on 2022/3/25.
//  Copyright © 2022 NextHome. All rights reserved.
//

import Foundation
import NHFoundation
extension NHAppColors: NHAppColorsInterface {
    /// E13944 主题色
    public var theme: UIColor       { return .nh_hex(0xE13944) }
    /// 497ffe 辅助颜色：图标、标签、模块
    public var blue: UIColor        { return .nh_hex(0x497ffe) }
    /// E13944 辅助颜色：图标、模块
    public var red: UIColor         { return .nh_hex(0xE13944) }
    /// f99901 辅助颜色：图标、标签、时间选择、按钮、模块
    public var yellow: UIColor      { return .nh_hex(0xf99901) }
    /// 5ed451 辅助颜色：主要用于图标，不同模块的区分等
    public var green: UIColor       { return .nh_hex(0x5ed451) }
    /// cccecf 状态色：未选中、按钮
    public var status: UIColor      { return .nh_hex(0xcccecf) }
    /// F9F9F9 背景色：非卡片界面的背景色
    public var background: UIColor  { return .nh_hex(0xF9F9F9) }
    /// E8E8E8 线条色：分割线
    public var line: UIColor        { return .nh_hex(0xE8E8E8) }
    /// 333333 标题：标题、内容
    public var title: UIColor       { return .nh_hex(0x333333) }
    /// 757D89 次要信息：列表标题、正文次要文字
    public var secondary: UIColor   { return .nh_hex(0x757D89) }
    /// 999999 辅助信息：辅助文字，用户副标题
    public var auxiliary: UIColor   { return .nh_hex(0x999999) }
    /// C0C0C0 辅助信息：占位符
    public var placeholder: UIColor { return .nh_hex(0xC0C0C0) }
    /// 接口：颜色的映射关系
    public func info() -> [String : UIColor] {[
        "theme"         : self.theme,
        "blue"          : self.blue,
        "red"           : self.red,
        "yellow"        : self.yellow,
        "status"        : self.status,
        "background"    : self.background,
        "line"          : self.line,
        "title"         : self.title,
        "secondary"     : self.secondary,
        "auxiliary"     : self.auxiliary,
        "placeholder"   : self.placeholder,
    ]}
}
