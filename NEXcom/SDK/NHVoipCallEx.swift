//
//  NHVoipCall.swift
//  NEXcom
//
//  Created by 骆亮 on 2022/9/16.
//

import UIKit
import linphonesw

extension Call {
    
    /// 远程账号信息
    public var remoteAccount: NHVoipAccount? {
        let username = self.remoteAddress?.username
        let displayName = self.remoteAddress?.displayName
        let password = self.remoteAddress?.password
        var port: String? = nil
        if let p = self.remoteAddress?.port, p != 0 {
            port = String(p)
        }
        let domain = self.remoteAddress?.domain
        return .init(username: username, displayName: displayName, password: password, domain: domain, port: port)
    }
    
    /// 远程 sip 地址
    public var remoteAddressString: String? {
        return self.remoteAddress?.asStringUriOnly()
    }
    
    /// 是否是视频通话
    public var isVideoCall: Bool {
        self.remoteParams?.videoEnabled ?? false
    }
    
    

    /// 执行命令
    /// - Parameters:
    ///   - action: 动作code
    ///   - method: 方法，默认为 DTMF_SIP_INFO
    public func performAction(_ action: String, method: NHMethod =  .DTMF_SIP_INFO) {
        do {
            if method == .DTMF_SIP_INFO {
                NHVoipManager.it.mCore.useInfoForDtmf = true
                try self.sendDtmfs(dtmfs: action)
                print("-----open")
            }
            else if method == .DTMF_RFC_4733 {
                NHVoipManager.it.mCore.useRfc2833ForDtmf = true
                try self.sendDtmfs(dtmfs: action)
            }
            else {
                let params = try NHVoipManager.it.mCore.createDefaultChatRoomParams()
                params.groupEnabled = false
                params.encryptionEnabled = false
                var chatRoom = NHVoipManager.it.mCore.searchChatRoom(params: params, localAddr: self.remoteAddress, remoteAddr: self.remoteAddress, participants: [self.remoteAddress!])
                if (chatRoom == nil)  {
                    chatRoom = try NHVoipManager.it.mCore.createChatRoom(params: params, localAddr: self.remoteAddress, participants: [self.remoteAddress!])
                }
                let message = try chatRoom?.createMessageFromUtf8(message: action)
                message?.send()
            }
        }  catch {
            print("Unable to perform action \(action) error is \(error)")
        }
    }

}


/// 呼叫配置
public class NHVoipCallConfigure: NSObject {
    /// 远程地址
    var remoteAddress: String!
    /// 视频展示视图，不传则表示音频通话
    var videoView: UIView?
    /// 给对方的名称
    var displayName: String?
    
    var camareView: UIView?
    
    init(remoteAddress: String, videoView: UIView? = nil, displayName: String? = nil, camareView: UIView? = nil) {
        
        self.remoteAddress = remoteAddress
        self.videoView = videoView
        self.displayName = displayName
        self.camareView = camareView
    }
}
