//
//  loginViewController.swift
//  CustomizeUITableViewCell
//
//  Created by csh on 2022/9/9.
//

import UIKit
import UserNotifications
import linphonesw
import CloudPushSDK
import Foundation
import CommonCrypto
import CryptoKit


class LoginViewController: UIViewController {

    @IBOutlet weak var f_display: UITextField!
    @IBOutlet weak var f_account: UITextField!
    @IBOutlet weak var f_pwd: UITextField!
    @IBOutlet weak var f_regis: UITextField!
    @IBOutlet weak var f_trans: UISegmentedControl!
    @IBOutlet weak var f_domain: UITextField!
    @IBOutlet weak var f_serve: UITextField!
    @IBOutlet weak var v_login_top_h: NSLayoutConstraint!
    @IBOutlet weak var v_body: UIView!
    @IBOutlet weak var f_privacy: UITextField!
    @IBOutlet weak var v_regis: UIView!
    @IBOutlet weak var v_privacy: UIView!
    @IBOutlet weak var v_trans: UIView!
    @IBOutlet weak var v_body_height: NSLayoutConstraint!
    @IBOutlet var v_foot: UIView!
    @IBOutlet weak var v_main: UITableView!
    @IBOutlet var v_login: UIView!
    @IBOutlet weak var btn_jump1: UIButton!
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var v_more_jump: UIView!
    @IBOutlet weak var btn_more: UIButton!
    @IBOutlet weak var btn_jump: UIButton!
    @IBOutlet var v_head: UIView!
    
    var transArray:[String]  {["UDP","TCP","TLS"]}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.checkoutInput() // 检测登录按钮是否可用
    }
    
    func setupUI() {
       
        // 渐变
        let gradientLayer =  CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        let fromColor = UIColor(hexString: "#2864AA").cgColor
        let toColor = UIColor(hexString: "#FFFFFF").cgColor
        gradientLayer.colors=[fromColor,toColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0,1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        // 列表
        self.v_main.tableHeaderView = self.v_head
        self.v_main.tableFooterView = self.v_foot
        if #available(iOS 11.0, *) {
            self.v_main.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.v_foot.layer.cornerRadius = 6
        self.v_body.layer.cornerRadius = 6
        self.v_login.layer.cornerRadius = 4
        self.v_login.backgroundColor = UIColor.gray
        
        self.v_body_height.constant = CGFloat(484)
        v_login_top_h.constant = CGFloat(78)
        v_trans.isHidden = true
        v_privacy.isHidden = true
        v_regis.isHidden = true
        btn_jump.isHidden = true
//        v_main.isScrollEnabled = false
        btn_login.layer.cornerRadius = 4
        
        btn_more.addTarget(self, action: #selector(LoginViewController.moreBtnAction), for: .touchUpInside)
        //This is for the keyboard to GO AWAYY !! when user clicks anywhere on the view
        btn_login.addTarget(self, action: #selector(LoginViewController.loginBtnAction), for: .touchUpInside)
        self.f_display.addTarget(self, action: #selector(self.checkoutInput), for: .editingChanged)
        self.f_account.addTarget(self, action: #selector(self.checkoutInput), for: .editingChanged)
        self.f_pwd.addTarget(self, action: #selector(self.checkoutInput), for: .editingChanged)
        self.f_serve.addTarget(self, action: #selector(self.checkoutInput), for: .editingChanged)
        self.f_domain.addTarget(self, action: #selector(self.checkoutInput), for: .editingChanged)
        self.btn_jump1.addTarget(self, action: #selector(LoginViewController.jump1), for: .touchUpInside)
        self.btn_jump.addTarget(self, action: #selector(LoginViewController.jump1), for: .touchUpInside)
        self.btn_login.isUserInteractionEnabled = false
        
       
    }
    
    // 跳转到登录页面
    @objc func jump1(){
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        UserDefaults.standard.setValue(true, forKey: "logined")
        appDelegate?.pushMainPage()
    }
   
    @objc func checkoutInput() {
        if let pwd = self.f_pwd.text, pwd.count > 0,
           let serve = self.f_serve.text, serve.count > 0,
           let account = self.f_account.text, account.count > 0,
           let display = self.f_display.text, display.count > 0,
           let domain = self.f_serve.text, domain.count > 0
        {
            self.btn_login.backgroundColor = UIColor(hexString: "2864aa")
            self.btn_login.isUserInteractionEnabled = true
        } else {
            self.btn_login.backgroundColor = UIColor(hexString: "ffcccccc")
            self.btn_login.isUserInteractionEnabled = false
        }
    }

    @objc func moreBtnAction(){
        self.v_body_height.constant = CGFloat(748)
        v_login_top_h.constant = CGFloat(24)
        v_trans.isHidden = false
        v_privacy.isHidden = false
        v_regis.isHidden = false
        btn_jump.isHidden = false
        v_main.isScrollEnabled = true
        v_more_jump.isHidden = true
    }
   
    @objc func loginBtnAction() {
        let displayName = self.f_display.text ?? ""
        let account = self.f_account.text ?? ""
        let pwd = self.f_pwd.text ?? ""
        let serve = self.f_serve.text ?? ""
        let port = self.f_domain.text ?? ""
        let trans1 = String(self.f_trans.selectedSegmentIndex)
        let privacy = self.f_privacy.text ?? "0"
        let regis = self.f_regis.text ?? "1800"

        UserDefaults.standard.setValue(true, forKey: "logined")
        UserDefaults.standard.synchronize()
        let myinformation:[String:String] = [
            "displayName": displayName,
            "account": account,
            "pwd": pwd,
            "serve": serve,
            "port": port,
            "trans": trans1,
            "privacy": privacy,
            "regis": regis
        ]
        UserDefaults.standard.setValue(myinformation, forKey: "myinfo")
        UserDefaults.standard.synchronize()
        if NHVoipManager.it.mAccount?.username != nil {
            unbinding()
        }
        NHVoipManager.it.loginWith(username: account, passwd: pwd, domain: serve, port: port, displayName: displayName, transportType: TransportType(rawValue: Int(trans1)!)! , privacy: UInt(privacy ), expires: UInt(regis))
//        NHVoipManager.it.onAccountStateChanged = { (state , message) in
//            if state == .Ok {
//                let s1 = "sipnum="
//                let s2 = "&timestamp="
//                let s3 = "&password="
//                let sip = self.f_account.text!
//                let timestamp = Date().milliStamp
//                let pwd =  self.f_pwd.text!
//                let str = s1+sip+s2+timestamp+s3+pwd
//                let device_id = CloudPushSDK.getDeviceId()
//
//                let newStr = str.sha256.uppercased()
//                print("-----"+newStr)
//                NHVoipRequest.it.bindDevice(SIPNUM: sip, SIGN: newStr, device_id: device_id!, TIMESTAMP: String(timestamp))
//                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
//                appDelegate?.pushMainPage()
//                NHVoipManager.it.onAccountStateChanged = nil
//            }
//        }
        // 无论是否登录成功，都直接进入app
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.pushMainPage()
    }
    
        
}

