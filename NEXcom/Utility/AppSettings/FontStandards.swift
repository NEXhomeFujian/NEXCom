//
//  FontStandards.swift
//  community-iOS
//
//  Created by 骆亮 on 2022/3/25.
//  Copyright © 2022 NextHome. All rights reserved.
//

import Foundation
import NHFoundation
extension NHAppFonts: NHAppFontsInterface {
    /// 导航字体：18
    public var huge: UIFont     { return .systemFont(ofSize: 18~) }
    /// 内容字体：16
    public var large: UIFont    { return .systemFont(ofSize: 16~) }
    /// 标题字体：14
    public var title: UIFont    { return .systemFont(ofSize: 14~) }
    /// 描述字体：12
    public var content: UIFont  { return .systemFont(ofSize: 12~) }
    /// 接口，字体的映射关系
    public func info() -> [String : UIFont] {[
        "huge"      : self.huge,
        "large"      : self.large,
        "title"     : self.title,
        "content"   : self.content,
    ]}
}
