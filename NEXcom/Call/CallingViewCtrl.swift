//
//  CallingViewCtrl.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/24.
//

import UIKit

class CallingViewCtrl: UIViewController {
    
    @IBOutlet weak var v_player: UIView!
    
    var address: String = ""
    var coming: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.outCall()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NHVoipManager.it.terminateCall()
    }
    
    func setupUI() {
        
    }
    
    func outCall() {
        
        if self.coming {
//            NHVoipManager.it.acceptCall(self.v_player)
        } else {
            NHVoipManager.it.outgoingCall(with: .init(remoteAddress: self.address, videoView: self.v_player, displayName: ""))
        }
        
    }
    
    @IBAction func micAction(_ sender: UIButton) {
        NHVoipManager.it.isMicrophoneEnabled = !NHVoipManager.it.isMicrophoneEnabled
    }
    
    @IBAction func speakAction(_ sender: UIButton) {
        NHVoipManager.it.isSpeakerEnabled = !NHVoipManager.it.isSpeakerEnabled
    }
    
    @IBAction func voraAction(_ sender: UIButton) {
        NHVoipManager.it.isVideoEnabled = !NHVoipManager.it.isVideoEnabled
    }
    
    @IBAction func unlockAction(_ sender: UIButton) {
//        NHVoipManager.
    }
    
    @IBAction func hangupAction(_ sender: UIButton) {
        NHVoipManager.it.terminateCall()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pauseorresume(_ sender: UIButton) {
        
    }
    

}
