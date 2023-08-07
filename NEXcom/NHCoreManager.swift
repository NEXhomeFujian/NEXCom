//
//  NHCoreManager.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/23.
//

import UIKit
import linphonesw

class NHCoreManager: NSObject {
    
    static let it: NHCoreManager = .init()

    var mCore: Core!
    var mAccount: Account?
    var mCoreDelegate : CoreDelegate!
    
    var username : String = ""
    var passwd : String = ""
    var server : String = ""
    var domain : String = ""
    var loggedIn: Bool = false
    var transportType : String = ""
    var privacy : UInt?
    var expires : UInt?
    
    var callMsg : String = ""
    var isCallIncoming : Bool = false {
        didSet {
            let tip = self.isCallIncoming ? "来电" : "来电结束"
            print(tip)
        }
    }
    var isCallRunning : Bool = false {
        didSet {
            let tip = self.isCallRunning ? "通话中" : "通话结束"
            print(tip)
        }
    }
    var isSpeakerEnabled : Bool = true
    var isMicrophoneEnabled : Bool = true
    var isVideoEnabled : Bool = false
    var canChangeCamera : Bool = false
    var remoteAddress : String = "Nobody yet"
    
    /// 注册状态
    public var registrationStateChanged: ((_ state: RegistrationState)->Void)?
    
    override init() {
        super.init()
    }
    
    func setup() {
        LoggingService.Instance.logLevel = LogLevel.Debug
        
        try? self.mCore = Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
        self.mCore.videoCaptureEnabled = true
        self.mCore.videoDisplayEnabled = true
        self.mCore.videoActivationPolicy!.automaticallyAccept = true
        
        
        // 启用 h264
        let result = self.videoCode(.h264)?.enable(enabled: true)
        print("h264启用:" + "\(result == 0 ? "成功" : "失败")")
        
        try? self.mCore.start()
        
        self.mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
            self.callMsg = message
            if (state == .IncomingReceived) { // When a call is received
                self.isCallIncoming = true
                self.isCallRunning = false
                self.remoteAddress = call.remoteAddress!.asStringUriOnly()
                
                // 临时测试，需要讲状态抛出去
                let callCtrl = CallingViewCtrl.init()
                callCtrl.address = self.remoteAddress
                callCtrl.coming = true
                let tabCtrl = UIApplication.shared.keyWindow?.rootViewController
                tabCtrl?.present(callCtrl, animated: true, completion: nil)
                
            } else if (state == .Connected) { // When a call is over
                self.isCallIncoming = false
                self.isCallRunning = true
            } else if (state == .Released) { // When a call is over
                self.isCallIncoming = false
                self.isCallRunning = false
                self.remoteAddress = "Nobody yet"
            } else if (state == .OutgoingInit) {
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
                self.isCallRunning = true
                
                // Only enable toggle camera button if there is more than 1 camera
                // We check if core.videoDevicesList.size > 2 because of the fake camera with static image created by our SDK (see below)
                self.canChangeCamera = core.videoDevicesList.count > 2
            } else if (state == .Paused) {
                // When you put a call in pause, it will became Paused
                self.canChangeCamera = false
            } else if (state == .PausedByRemote) {
                // When the remote end of the call pauses it, it will be PausedByRemote
            } else if (state == .Updating) {
                // When we request a call update, for example when toggling video
            } else if (state == .UpdatedByRemote) {
                // When the remote requests a call update
            } else if (state == .Released) {
                // Call state will be released shortly after the End state
                self.isCallRunning = false
                self.canChangeCamera = false
            } else if (state == .Error) {
                
            }
        }, onAudioDeviceChanged: { (core: Core, device: AudioDevice) in
            // This callback will be triggered when a successful audio device has been changed
        }, onAudioDevicesListUpdated: { (core: Core) in
            // This callback will be triggered when the available devices list has changed,
            // for example after a bluetooth headset has been connected/disconnected.
        }, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
            NSLog("New registration state is \(state) for user id \( String(describing: account.params?.identityAddress?.asString()))\n")
            if (state == .Ok) {
                self.loggedIn = true
            } else if (state == .Cleared) {
                self.loggedIn = false
            }
            self.registrationStateChanged?(state)
        })
        self.mCore.addDelegate(delegate: mCoreDelegate)
    }
    
    
    /// 登录
    /// - Parameters:
    ///   - username: sip账号
    ///   - passwd: 密码
    ///   - domain: 域名
    ///   - displayName: 给对方的显示名称
    ///   - transportType: 传输类型，默认 UDP
    ///   - privacy: 代理
    ///   - expires: 过期时间，单位 秒，默认 1800 秒
    func loginWith(username: String,
                   passwd: String,
                   domain: String,
                   displayName: String? = nil,
                   transportType: String? = "UDP",
                   privacy: UInt? = 0,
                   expires: UInt? = 1800) {
        self.username = username
        self.passwd = passwd
        self.domain = domain
        self.transportType = transportType ?? "UDP"
        self.privacy = privacy
        self.expires = expires
        do {
            var transport : TransportType
            if (transportType == "TLS") { transport = TransportType.Tls }
            else if (transportType == "TCP") { transport = TransportType.Tcp }
            else  { transport = TransportType.Udp }
            
            let authInfo = try Factory.Instance.createAuthInfo(username: username, userid: "", passwd: passwd, ha1: "", realm: "", domain: domain)
            let accountParams = try mCore.createAccountParams()
            if let p = self.privacy, p != 0 {
                accountParams.privacy = p
            }
            accountParams.expires = Int(self.expires ?? 1800)
            let identity = try Factory.Instance.createAddress(addr: String("sip:" + username + "@" + domain))
            try identity.setDisplayname(newValue: displayName ?? "")
            try! accountParams.setIdentityaddress(newValue: identity)
            let address = try Factory.Instance.createAddress(addr: String("sip:" + domain))
            try address.setTransport(newValue: transport)
            try accountParams.setServeraddress(newValue: address)
            accountParams.registerEnabled = true
            mAccount = try mCore.createAccount(params: accountParams)
            mCore.addAuthInfo(info: authInfo)
            try mCore.addAccount(account: mAccount!)
            mCore.defaultAccount = mAccount
            
        } catch { NSLog(error.localizedDescription) }
    }
    
    /// 注销
    func unregister()
    {
        if let account = mCore.defaultAccount {
            let params = account.params
            let clonedParams = params?.clone()
            clonedParams?.registerEnabled = false
            account.params = clonedParams
        }
    }
    
    /// 清除设备上所有sip账号信息
    func delete() {
        if let account = mCore.defaultAccount {
            mCore.removeAccount(account: account)
            mCore.clearAccounts()
            mCore.clearAllAuthInfo()
        }
    }
    
    /// 挂断当前账号
    func terminateCall() {
        do {
            // Terminates the call, whether it is ringing or running
            try mCore.currentCall?.terminate()
        } catch { NSLog(error.localizedDescription) }
    }
    
    /// 接听来电
    func acceptCall(_ view: UIView) {
        // IMPORTANT : Make sure you allowed the use of the microphone (see key "Privacy - Microphone usage description" in Info.plist) !
        do {
            // if we wanted, we could create a CallParams object
            // and answer using this object to make changes to the call configuration
            // (see OutgoingCall tutorial)
            self.mCore.nativeVideoWindow = view
            try mCore.currentCall?.accept()
        } catch { NSLog(error.localizedDescription) }
    }
    
    /// 呼叫
    func outgoingCall(_ view: UIView, addr: String, displayName: String? = nil) {
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            self.mCore.nativeVideoWindow = view
            self.remoteAddress = addr
            let remoteAddress = try Factory.Instance.createAddress(addr: remoteAddress)
            if let disName = displayName {
                try remoteAddress.setDisplayname(newValue: disName)
            }
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            // If we wanted to start the call with video directly
            params.videoEnabled = true
            
            // Finally we start the call
            let _ = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch { NSLog(error.localizedDescription) }
        
    }
    
    /// 设置麦克风
    func muteMicrophone() {
        // The following toggles the microphone, disabling completely / enabling the sound capture
        // from the device microphone
        mCore.micEnabled = !mCore.micEnabled
        isMicrophoneEnabled = !isMicrophoneEnabled
    }
    
    /// 设置喇叭
    func toggleSpeaker() {
        // Get the currently used audio device
        let currentAudioDevice = mCore.currentCall?.outputAudioDevice
        let speakerEnabled = currentAudioDevice?.type == AudioDeviceType.Speaker
        
        // We can get a list of all available audio devices using
        // Note that on tablets for example, there may be no Earpiece device
        for audioDevice in mCore.audioDevices {
            
            // For IOS, the Speaker is an exception, Linphone cannot differentiate Input and Output.
            // This means that the default output device, the earpiece, is paired with the default phone microphone.
            // Setting the output audio device to the microphone will redirect the sound to the earpiece.
            if (speakerEnabled && audioDevice.type == AudioDeviceType.Microphone) {
                mCore.currentCall?.outputAudioDevice = audioDevice
                isSpeakerEnabled = false
                return
            } else if (!speakerEnabled && audioDevice.type == AudioDeviceType.Speaker) {
                mCore.currentCall?.outputAudioDevice = audioDevice
                isSpeakerEnabled = true
                return
            }
            /* If we wanted to route the audio to a bluetooth headset
            else if (audioDevice.type == AudioDevice.Type.Bluetooth) {
            core.currentCall?.outputAudioDevice = audioDevice
            }*/
        }
    }
    
    /// 视频使能
    func toggleVideo() {
        do {
            if (mCore.callsNb == 0) { return }
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            // We will need the CAMERA permission for video call
            
            if let call = coreCall {
                // To update the call, we need to create a new call params, from the call object this time
                let params = try mCore.createCallParams(call: call)
                // Here we toggle the video state (disable it if enabled, enable it if disabled)
                // Note that we are using currentParams and not params or remoteParams
                // params is the object you configured when the call was started
                // remote params is the same but for the remote
                // current params is the real params of the call, resulting of the mix of local & remote params
                params.videoEnabled = !(call.currentParams!.videoEnabled)
                
                params.audioEnabled = true //..
                
                self.isVideoEnabled = params.videoEnabled
                // Finally we request the call update
                try call.update(params: params)
                // Note that when toggling off the video, TextureViews will keep showing the latest frame displayed
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
    /// 相机使能
    func toggleCamera() {
        do {
            // Currently used camera
            let currentDevice = mCore.videoDevice
            
            // Let's iterate over all camera available and choose another one
            for camera in mCore.videoDevicesList {
                // All devices will have a "Static picture" fake camera, and we don't want to use it
                if (camera != currentDevice && camera != "StaticImage: Static picture") {
                    try mCore.setVideodevice(newValue: camera)
                    break
                }
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
    /// 视频恢复/暂停
    func pauseOrResume() {
        do {
            if (mCore.callsNb == 0) { return }
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            
            if let call = coreCall {
                if (call.state != Call.State.Paused && call.state != Call.State.Pausing) {
                    // If our call isn't paused, let's pause it
                    try call.pause()
                } else if (call.state != Call.State.Resuming) {
                    // Otherwise let's resume it
                    try call.resume()
                }
            }
        } catch { NSLog(error.localizedDescription) }
    }

}

enum VideoCode: String {
    case vp8 = "vp8"
    case h264 = "h264"
    case h265 = "h265"
}

enum AudioCode: String {
    case pcma = "pcma"
    case g722 = "g722"
    case pcmu = "pcmu"
}

enum VideoName: String {
    case _720p = "720p"
    case _vga  = "vga"
    case _qvga = "qvga"
}

enum VideoSize {
    case _QVGA, _VGA, _720P
}

enum Method {
    case DTMF_SIP_INFO
    case DTMF_RFC_4733
    case SIP_MESSAGE
}

extension NHCoreManager {

    
    /// 视频编码，可获取当前信息，设置是否启用等
    func videoCode(_ type: VideoCode) -> PayloadType? {
        self.mCore.videoPayloadTypes.first { $0.mimeType.lowercased() == type.rawValue }
    }
    
    /// 当前call
    var currentCall: Call? {
        if (mCore.callsNb == 0) { return nil }
        let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
        return coreCall
    }
    
    /// 音频编码
    func audioCode(_ type: AudioCode) -> PayloadType? {
        self.mCore.audioPayloadTypes.first { $0.mimeType.lowercased() == type.rawValue }
    }

    /// 设置视频分辨率
    func setSentVideoDefinitionByName(_ name: VideoName) {
        NHCoreManager.it.mCore.preferredVideoDefinitionByName = name.rawValue
    }
    
}

