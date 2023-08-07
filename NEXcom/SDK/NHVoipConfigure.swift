//
//  NHVoipConfigure.swift
//  NEXcom
//
//  Created by 骆亮 on 2022/9/16.
//

import UIKit
import linphonesw

/// 云对讲配置信息
class NHVoipConfigure: NSObject {
    
    /// 传输类型，默认为 udp
    public var transportType : TransportType = .Udp
    /// 代理服务器
    var privacy : UInt?
    /// 过期时间，默认为 1800s
    var expires : UInt? = 1800

}



public enum NHVideoCode: String {
    case vp8 = "vp8"
    case h264 = "h264"
    case h265 = "h265"
}

public enum NHAudioCode: String {
    case pcma = "pcma"
    case g722 = "g722"
    case pcmu = "pcmu"
}

public enum NHVideoName: String {
    case _720p = "720p"
    case _vga  = "vga"
    case _qvga = "qvga"
}

public enum NHMethod {
    case DTMF_SIP_INFO
    case DTMF_RFC_4733
    case SIP_MESSAGE
}

public enum NHCameraState {
    case close
    case front
    case back
}
