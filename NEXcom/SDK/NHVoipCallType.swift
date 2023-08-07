//
//  NHVoipCallType.swift
//  NEXcom
//
//  Created by csh on 2023/2/14.
//

import UIKit

class NHVoipCallType: NSObject {

    public static let it: NHVoipCallType = .init()
    /// 0: 音频 1:视频 2: 监控
    var callType = 0
}
