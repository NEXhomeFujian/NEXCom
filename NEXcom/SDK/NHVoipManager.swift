//
//  NHVoipManager.swift
//  NEXcom
//
//  Created by 骆亮 on 2022/9/16.
//

import UIKit
import linphonesw

/// 功能接口
public protocol NHVoipManagerInterface {
    
    /// 初始化
    func setup()
    /// 初始化
    func setup(with configPath:String?, factoryConfigPath:String?)
    
    
    /// 登录
    /// - Parameters:
    ///   - username: sip账号
    ///   - passwd: 密码
    ///   - domain: 域名
    ///   - port: 端口
    ///   - displayName: 给对方的显示名称
    ///   - transportType: 传输类型，默认 UDP
    ///   - privacy: 代理
    ///   - expires: 过期时间，单位 秒，默认 1800 秒
    func loginWith(username: String,
                   passwd: String?,
                   domain: String?,
                   port: String?,
                   displayName: String?,
                   transportType: TransportType,
                   privacy: UInt?,
                   expires: UInt?)
    func loginWith(username: String,
                   passwd: String?,
                   domain: String?,
                   port: String?,
                   displayName: String?)
    /// 账号注销
    func unregister()
    /// 清除设备上所有sip账号信息
    func delete()
    
    
    /// 接听来电
    /// - Parameter view: 通话视图，未传则为音频通话
    func acceptCall(_ view: UIView?, v_our: UIView?)
    /// 挂断当前来电
    func terminateCall()
    /// 挂断某来电
    func terminate(_ call: Call)
    /// 呼叫某设备
    func outgoingCall(with config: NHVoipCallConfigure)
    /// 暂停当前call
    func pauseCall()
    /// 恢复当前call
    func resumeCall()
    
    var nativeRingingEnabled: Bool {get set}
    var ring: String {get set}
    var ringDuringIncomingEarlyMedia: Bool {get set}
    
    /// 麦克风状态
    var isMicrophoneEnabled: Bool { get set }
    /// 喇叭状态
    var isSpeakerEnabled: Bool { get set }
    /// 视频画面状态
    var isVideoEnabled: Bool { get set }
    /// 摄像机状态
    var isCameraEnabled: Bool { get set }
    /// 切换镜头
    func toggleCamera()
    
    
//    /// 启动 core
//    func start()
//    /// 停止 core
//    func stop()
//    /// 添加代理
//    func addDelegate(delegate: CoreDelegate)
//    /// 添加代理
//    func addDelegate()
//    /// 移除代理
//    func removeDelegate(delegate: CoreDelegate)
//    /// 移除代理
//    func removeDelegate()
//    /// 确保已注册
//    func ensureRegistered()
//    /// 进入前台
//    func enterForeground()
//    /// 进入后台
//    func enterBackground()
}

 
class NHVoipManager: NSObject, NHVoipManagerInterface {

    /// Voip的管理实例
    public static let it: NHVoipManager = .init()
    /// 账号信息
    public var mAccount: NHVoipAccount?
    /// 账号状态变化回调
    public var onAccountStateChanged: ((_ state: RegistrationState, _ message: String) -> Void)?
    /// call的状态，这里的call不区分来电还是呼出
    public var onCallStateChanged: ((_ call: Call, _ state: Call.State, _ message: String) -> Void)?
    
    /// linphone的核心
    public var mCore: Core!
    
    public var mCoreDelegate : CoreDelegate!
    
    /// 初始化
    func setup() {
        self.setup(with: nil, factoryConfigPath: nil)
    }
    /// 初始化
    func setup(with configPath: String?, factoryConfigPath: String?) {
        #if DEBUG
        // 日志
        LoggingService.Instance.logLevel = LogLevel.Debug
        #endif
        
        // core
        try? self.mCore = Factory.Instance.createCore(configPath: configPath, factoryConfigPath: configPath, systemContext: nil)
        // 默认设置
        self.mCore.videoCaptureEnabled = true
        self.mCore.videoDisplayEnabled = true
        self.mCore.videoActivationPolicy!.automaticallyAccept = true
        // 启用 h264
        let result = self.videoCode(.h264)?.enable(enabled: true)
        print("h264启用:" + "\(result == 0 ? "成功" : "失败")")
        let result1 = self.videoCode(.h265)?.enable(enabled: false)
        let result2 = self.videoCode(.vp8)?.enable(enabled: false)
//        NHVoipManager.it.audioCode(.g722)?.enable(enabled: true)
        /// 设置铃声
        self.mCore.ringDuringIncomingEarlyMedia = true
        self.mCore.ring =  Bundle.main.path(forResource: "ring", ofType: "wav") ?? ""
        // 启动
        try? self.mCore.start()
        
        self.mCoreDelegate = CoreDelegateStub.init(
            //
            onGlobalStateChanged: { core, globalState, message in
                print("message:\(message)")
            },
            // 来电状态回调
            onCallStateChanged: { [weak self] (core, call, state, message) in
                guard let `self` = self else { return }
                self.onCallStateChanged?(call, state, message)
                // 以下状态解释
                if (state == .IncomingReceived) {
                    // When a call is received
                } else if (state == .Connected) {
                    // When a call is over
                } else if (state == .Released) {
                    // When a call is over
                } else if (state == .OutgoingInit) {
                    print("-----hhhh")
                    // First state an outgoing call will go through
                } else if (state == .OutgoingProgress) {
                    // Right after outgoing init
                } else if (state == .OutgoingRinging) {
                    // This state will be reached upon reception of the 180 RINGING
                } else if (state == .Connected) {
                    // When the 200 OK has been received
                } else if (state == .StreamsRunning) {
                    // This state indicates the call is active.
                    // You may reach this state multiple times, for example after a pause/resume
                    // or after the ICE negotiation completes
                    // Wait for the call to be connected before allowing a call update
                    // Only enable toggle camera button if there is more than 1 camera
                    // We check if core.videoDevicesList.size > 2 because of the fake camera with static image created by our SDK (see below)
                } else if (state == .Paused) {
                    // When you put a call in pause, it will became Paused
                } else if (state == .PausedByRemote) {
                    // When the remote end of the call pauses it, it will be PausedByRemote
                } else if (state == .Updating) {
                    // When we request a call update, for example when toggling video
                } else if (state == .UpdatedByRemote) {
                    // When the remote requests a call update
                } else if (state == .Released) {
                    // Call state will be released shortly after the End state
                } else if (state == .Error) {
                    
                }
            },
            // 账号登录回调
            onAccountRegistrationStateChanged: { [weak self] (core, account, state, message) in
                guard let `self` = self else { return }
                self.mAccount?.loginState = state
                self.onAccountStateChanged?(state, message)
            })
        self.mCore.addDelegate(delegate: self.mCoreDelegate)
        
        /// 关闭镜头
        self.cameraUnable()
    }
    

}


// MARK: - 账号相关
extension NHVoipManager {
    /// 登录
    func loginWith(username: String,
                   passwd: String?,
                   domain: String?,
                   port: String?,
                   displayName: String?,
                   transportType: TransportType,
                   privacy: UInt?,
                   expires: UInt?) {
        self.mAccount = .init(username: username, displayName: displayName, password: passwd, domain: domain, port: port)
        // TODO: - 记录传输类型、过期时间等
        do {
            let transport : TransportType = transportType
            
            let authInfo = try Factory.Instance.createAuthInfo(username: username, userid: "", passwd: passwd, ha1: "", realm: "", domain: domain)
            let accountParams = try self.mCore.createAccountParams()
            if let p = privacy, p > 0 {
                accountParams.privacy = p
            }
            accountParams.expires = Int(expires ?? 1800)
            var server: String = domain ?? ""
            server = (port?.count ?? 0) > 0 ? (server + ":" + port!) : server
            let identity = try Factory.Instance.createAddress(addr: String("sip:" + username + "@" + server))
            try identity.setDisplayname(newValue: displayName ?? "")
            try! accountParams.setIdentityaddress(newValue: identity)
            let address = try Factory.Instance.createAddress(addr: String("sip:" + server))
            try address.setTransport(newValue: transport)
            try accountParams.setServeraddress(newValue: address)
            accountParams.registerEnabled = true
            let coreAccount = try mCore.createAccount(params: accountParams)
            self.mAccount?.coreAccount = coreAccount
            self.mCore.addAuthInfo(info: authInfo)
            try self.mCore.addAccount(account: coreAccount)
            self.mCore.defaultAccount = coreAccount
            
        } catch { print(error.localizedDescription) }
    }
    
    func loginWith(username: String, passwd: String?, domain: String?, port: String?, displayName: String?) {
        self.loginWith(username: username, passwd: passwd, domain: domain, port: port, displayName: displayName, transportType: .Udp, privacy: nil, expires: nil)
    }
    
    /// 注销
    func unregister() {
        if let account = self.mCore.defaultAccount {
            let params = account.params
            let clonedParams = params?.clone()
            clonedParams?.registerEnabled = false
            account.params = clonedParams
        }
    }
    
    /// 清除设备上所有sip账号信息
    func delete() {
        guard let account = self.mCore.defaultAccount else { return }
        self.mCore.removeAccount(account: account)
        self.mCore.clearAccounts()
        self.mCore.clearAllAuthInfo()
    }
}



// MARK: - 来电/呼叫相关
extension NHVoipManager {
    
    /*
     IMPORTANT : Make sure you allowed the use of the microphone (see key "Privacy - Microphone usage description" in Info.plist) !
     */
    
    /// 接听来电
    func acceptCall(_ view: UIView?, v_our: UIView?) {
        do {
            // if we wanted, we could create a CallParams object
            // and answer using this object to make changes to the call configuration
            // (see OutgoingCall tutorial)
            
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            if let v_video = view {
                self.mCore.nativeVideoWindow = v_video
                if v_our != nil {
                    self.mCore.nativePreviewWindow = v_our
                }
//                self.mCore.nativePreviewWindow = v_our
                // If we wanted to start the call with video directly
                params.videoEnabled = true
            } else {
                params.videoEnabled = false
            }
            params.audioEnabled = true
            try self.mCore.currentCall?.acceptWithParams(params: params)
        } catch { print(error.localizedDescription) }
    }
    /// 来电预览
    func acceptEarlyCall(_ view: UIView?) {
        do {
            // if we wanted, we could create a CallParams object
            // and answer using this object to make changes to the call configuration
            // (see OutgoingCall tutorial)
            
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            if let v_video = view {
                self.mCore.nativeVideoWindow = v_video
               
//                self.mCore.nativePreviewWindow = v_our
                // If we wanted to start the call with video directly
                params.videoEnabled = true
            } else {
                params.videoEnabled = false
            }
            params.audioEnabled = true
            try self.mCore.currentCall?.acceptEarlyMediaWithParams(params: params)
        } catch { print(error.localizedDescription) }
    }
    func toggleView(_view: UIView?){
        do {
            // Currently used camera
            let currentDevice = self.mCore.videoDevice
            self.mCore.nativePreviewWindow = _view
            // Let's iterate over all camera available and choose another one
            for camera in self.mCore.videoDevicesList {
                // All devices will have a "Static picture" fake camera, and we don't want to use it
                if (camera != currentDevice && camera != "StaticImage: Static picture") {
                    try self.mCore.setVideodevice(newValue: camera)
                    break
                }
            }
        } catch { print(error.localizedDescription) }
    }
    
    private func cameraSet(state: NHCameraState) {
        do {
            // 关闭镜头
            if state == .close {
                // Let's iterate over all camera available and choose another one
                for camera in self.mCore.videoDevicesList {
                    // All devices will have a "Static picture" fake camera, and we want to use it
                    if (camera == "StaticImage: Static picture") {
                        try self.mCore.setVideodevice(newValue: camera)
                        break
                    }
                }
            }
            // 开启前置镜头
            if state == .front {
                for camera in self.mCore.videoDevicesList {
                    if (camera as AnyObject).contains("front") || (camera as AnyObject).contains("1") {
                        try self.mCore.setVideodevice(newValue: camera)
                        break
                    }
                }
            }
            // 开启后置镜头
            if state == .back {
                for camera in self.mCore.videoDevicesList {
                    if (camera as AnyObject).contains("back") || (camera as AnyObject).contains("0") {
                        try self.mCore.setVideodevice(newValue: camera)
                        break
                    }
                }
            }
        } catch { print(error.localizedDescription) }
        
    }
    
    /// 挂断当前来电
    func terminateCall() {
        do {
            // Terminates the call, whether it is ringing or running
//            try self.mCore.currentCall?.decline(reason: .Declined)
            try self.mCore.currentCall?.terminate()
        } catch { print(error.localizedDescription) }
    }
    
    /// 挂断某来电
    func terminate(_ call: Call) {
        do {
            // Terminates the call, whether it is ringing or running
            try call.terminate()
//            try call.decline(reason: .Declined)
        } catch { print(error.localizedDescription) }
        
    }
    /// 视频呼叫
    func monitorCall(with config: NHVoipCallConfigure) {
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            let remoteAddress = try Factory.Instance.createAddress(addr: config.remoteAddress)
            if let disName = config.displayName, disName.count != 0 {
                try remoteAddress.setDisplayname(newValue: disName)
            }
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            self.mCore.nativePreviewWindow  = nil
            cameraUnable()
            params.mediaEncryption = MediaEncryption.None
            if let v_video = config.videoView {
                self.mCore.nativeVideoWindow = v_video
                // If we wanted to start the call with video directly
                params.videoEnabled = true
                
//                params.videoMulticastEnabled = true
            } else {
                params.videoEnabled = false
            }
            
            params.audioEnabled = true
            
            // Finally we start the call
            let _ = self.mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch { NSLog(error.localizedDescription) }
    }
    /// 呼叫
    func outgoingCall(with config: NHVoipCallConfigure) {
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            let remoteAddress = try Factory.Instance.createAddress(addr: config.remoteAddress)
            if let disName = config.displayName, disName.count != 0 {
                try remoteAddress.setDisplayname(newValue: disName)
            }
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            if let v_video = config.videoView {
                self.mCore.nativeVideoWindow = v_video
                if config.camareView != nil {
                    self.mCore.nativePreviewWindow = config.camareView
                }
                
            
                // If we wanted to start the call with video directly
                params.videoEnabled = true
            } else {
                params.videoEnabled = false
            }
            
            params.audioEnabled = true
            
            // Finally we start the call
            let _ = self.mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch { NSLog(error.localizedDescription) }
    }
    
    /// 暂停当前call
    func pauseCall() {
        do {
            if let call = self.currentCall, call.state != Call.State.Paused && call.state != Call.State.Pausing {
                try call.pause()
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
    /// 恢复当前call
    func resumeCall() {
        do {
            if let call = self.currentCall, call.state != Call.State.Resuming {
                try call.resume()
            }
        } catch { NSLog(error.localizedDescription) }
    }
}


// MARK: - 使能
extension NHVoipManager {
    var ring: String {
        get {self.mCore.ring}
        set { self.mCore.ring = newValue}
    }
    var nativeRingingEnabled: Bool {
        get { self.mCore.isNativeRingingEnabled}
        set {
            self.mCore.nativeRingingEnabled = newValue
        }
    }
    var ringDuringIncomingEarlyMedia: Bool {
        get { self.mCore.ringDuringIncomingEarlyMedia}
        set {
            self.mCore.ringDuringIncomingEarlyMedia = newValue
        }
    }
    /// 麦克风状态
    var isMicrophoneEnabled: Bool {
        get { self.mCore.micEnabled }
        set {
            let currentEnabled: Bool = self.mCore.micEnabled
            guard currentEnabled != newValue else { return }
            self.mCore.micEnabled = newValue
        }
    }
    
    /// 喇叭状态
    var isSpeakerEnabled: Bool {
        get { self.mCore.currentCall?.outputAudioDevice?.type == .Speaker }
        set {
            let currentEnabled: Bool = self.isSpeakerEnabled
            guard currentEnabled != newValue else { return }
            // We can get a list of all available audio devices using
            // Note that on tablets for example, there may be no Earpiece device
            for audioDevice in mCore.audioDevices {
                if (currentEnabled && audioDevice.type == AudioDeviceType.Microphone && newValue == false) {
                    self.mCore.currentCall?.outputAudioDevice = audioDevice
                    break
                } else if (!currentEnabled && audioDevice.type == AudioDeviceType.Speaker && newValue == true) {
                    self.mCore.currentCall?.outputAudioDevice = audioDevice
                    break
                }
            }
        }
    }
    
    /// 视频画面状态
    var isVideoEnabled: Bool {
        get {
            return (self.currentCall?.currentParams?.videoEnabled == true)
        }
        set {
            do {
                let currentEnabled: Bool = self.isVideoEnabled
                guard currentEnabled != newValue else { return }
                if let call = self.currentCall {
                    // To update the call, we need to create a new call params, from the call object this time
                    
                    let params = try mCore.createCallParams(call: call)
                    // Here we toggle the video state (disable it if enabled, enable it if disabled)
                    // Note that we are using currentParams and not params or remoteParams
                    // params is the object you configured when the call was started
                    // remote params is the same but for the remote
                    // current params is the real params of the call, resulting of the mix of local & remote params
                    params.videoEnabled = currentEnabled
                    // Finally we request the call update
                    try call.update(params: params)
                    // Note that when toggling off the video, TextureViews will keep showing the latest frame displayed
                }
            } catch { print(error.localizedDescription) }
        }
    }
    /// 摄像头状态
    var isCameraEnabled: Bool {
        get { self.mCore.videoDevice != "StaticImage: Static picture" }
        set {
           
        }
        
    }
    /// 切换前后摄像头
    func toggleCamera() {
        do {
            // Currently used camera
            let currentDevice = self.mCore.videoDevice
            
            // Let's iterate over all camera available and choose another one
            for camera in self.mCore.videoDevicesList {
                // All devices will have a "Static picture" fake camera, and we don't want to use it
                if (camera != currentDevice && camera != "StaticImage: Static picture") {
                    try self.mCore.setVideodevice(newValue: camera)
                    break
                }
            }
        } catch { print(error.localizedDescription) }
    }
    /// 开关镜头
    func toggleVideo() {
        do {
            // Currently used camera
            let currentDevice = self.mCore.videoDevice
            
            // Let's iterate over all camera available and choose another one
            for camera in self.mCore.videoDevicesList {
                // All devices will have a "Static picture" fake camera, and we don't want to use it
                if (currentDevice == "StaticImage: Static picture") {
                    if (camera != "StaticImage: Static picture") {
                        try self.mCore.setVideodevice(newValue: camera)
                        break
                    }
                } else {
                    
                        try self.mCore.setVideodevice(newValue: "StaticImage: Static picture")
                        break
                    
                }
               
            }
        } catch { print(error.localizedDescription) }
    }
    /// 关闭镜头
    func cameraUnable() {
        do {
            // Let's iterate over all camera available and choose another one
            for camera in self.mCore.videoDevicesList {
                // All devices will have a "Static picture" fake camera, and we want to use it
                if (camera == "StaticImage: Static picture") {
                    try self.mCore.setVideodevice(newValue: camera)
                    break
                }
            }
        } catch { print(error.localizedDescription) }
    }
    /// 开启镜头
    func cameraAble() {
        do {
            // Let's iterate over all camera available and choose another one
            for camera in self.mCore.videoDevicesList {
                // All devices will have a "Static picture" fake camera, and we want to use it
                if (camera != "StaticImage: Static picture") {
                    try self.mCore.setVideodevice(newValue: camera)
                    break
                }
            }
        } catch { print(error.localizedDescription) }
    }
}

// MARK: - 额外功能
extension NHVoipManager {
    
    /// 当前call
    public var currentCall: Call? {
        if (mCore.callsNb == 0) { return nil }
        let coreCall = (self.mCore.currentCall != nil) ? self.mCore.currentCall : self.mCore.calls[0]
        return coreCall
    }
    
    /// 视频编码，可获取当前信息，设置是否启用等
    public func videoCode(_ type: NHVideoCode) -> PayloadType? {
        self.mCore.videoPayloadTypes.first { $0.mimeType.lowercased() == type.rawValue }
    }
    
    /// 音频编码
    public func audioCode(_ type: NHAudioCode) -> PayloadType? {
        self.mCore.audioPayloadTypes.first { $0.mimeType.lowercased() == type.rawValue }
    }

    /// 设置视频分辨率
    public func setSentVideoDefinitionByName(_ name: NHVideoName) {
        NHVoipManager.it.mCore.preferredVideoDefinitionByName = name.rawValue
    }
    
//    func start() {
//        try? NHVoipManager.it.mCore.start()
//    }
//    
//    func stop() {
//        NHVoipManager.it.mCore.stop()
//    }
//
//    
//    func addDelegate(delegate: CoreDelegate) {
//        NHVoipManager.it.mCore.addDelegate(delegate: delegate)
//    }
//    func addDelegate() {
//        NHVoipManager.it.mCore.addDelegate(delegate: NHVoipManager.it.mCoreDelegate)
//    }
//    
//    func removeDelegate(delegate: CoreDelegate) {
//        NHVoipManager.it.mCore.removeDelegate(delegate: delegate)
//    }
//    func removeDelegate() {
//        NHVoipManager.it.mCore.removeDelegate(delegate: NHVoipManager.it.mCoreDelegate)
//    }
//    
//    func ensureRegistered() {
//        NHVoipManager.it.mCore.ensureRegistered()
//    }
//    
//    func enterForeground() {
//        NHVoipManager.it.mCore.enterForeground()
//    }
//    
//    func enterBackground() {
//        NHVoipManager.it.mCore.enterBackground()
//    }

}

