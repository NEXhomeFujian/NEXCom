//
//  firstViewController.swift
//  CustomizeUITableViewCell
//
//  Created by csh on 2022/9/9.
//

import UIKit
import WebKit
import SnapKit
import NHFoundation
import Lottie
class FirstViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var limitTime: Int = 5
    lazy var v_wkweb = WKWebView()
    @IBOutlet weak var v_b_reload: UIView!
    @IBOutlet weak var v_reload: UIView!
    @IBOutlet weak var b_reload: UIButton!
    @IBOutlet weak var v_text: UIView!
    @IBOutlet weak var lb_pro: UILabel!
    @IBOutlet weak var btn_agree: UIButton!
    @IBOutlet weak var btn_disagree: UIButton!
    @IBOutlet weak var btn_new: UIButton!
    @IBOutlet weak var l_agree: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        // 背景渐变颜色：
        let gradientLayer =  CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        let fromColor = UIColor(hexString: "#2864AA").cgColor
        let toColor = UIColor(hexString: "#FFFFFF").cgColor
        gradientLayer.colors=[fromColor,toColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0,1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupUI() {
        // web链接：
        self.v_text.addSubview(self.v_wkweb)
        self.v_text.layer.cornerRadius = 6
        self.v_wkweb.layer.cornerRadius = 6
        self.v_wkweb.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(self.lb_pro.snp.bottom).offset(15)
        }
        v_b_reload.layer.borderWidth = 1
        v_b_reload.layer.borderColor = UIColor(hexString: "2864AA").cgColor
        v_wkweb.uiDelegate = self
        v_wkweb.navigationDelegate = self
        reload()
        self.v_wkweb.addSubview(v_reload)
    
        
        self.lb_pro.text = nh_localizedString(forKey: "agreement")
        // 按钮：跳转
        btn_new.addTarget(self, action: #selector(self.loginBtnAction), for: .touchUpInside)
        b_reload.addTarget(self, action: #selector(self.reload), for: .touchUpInside)
        // 按钮：倒计时，颜色
        btn_disagree.layer.cornerRadius = 4
        btn_agree.layer.cornerRadius = 4
        btn_disagree.layer.borderWidth = 1
        self.btn_disagree.addTarget(self, action: #selector(self.exitEvent), for: .touchUpInside)
        self.updateJumpBtn()
        self.startCountDown()
//        let starView = AnimationView(name: "data")
//        self.view.addSubview(starView)
//        starView.snp.makeConstraints { make in
////            make.size.equalTo(CGSize.init(width: 150, height: 150))
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
//        starView.loopMode = .playOnce
//        starView.play()
    }
  
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        self.v_reload.isHidden = true
        
    }

//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        if (!(navigationAction.targetFrame?.isMainFrame ?? false)) {
//            webView.load(navigationAction.request)
//
//        }
//        return nil
//    }
    @objc func exitEvent() {
        exit(1)
        
    }
   
    @objc func reload() {
        if let url = URL(string: getCurrentPrivacyUrlString()) {
            let urlRequest = URLRequest(url: url)
            v_wkweb.load(urlRequest)
        }
    }
    
    @objc func loginBtnAction() {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .custom
        self.present(loginViewController, animated: true, completion: nil)
        UserDefaults.standard.setValue(true, forKey: "protocol")
        UserDefaults.standard.synchronize()
    }
    
    func startCountDown() {
        self.countDownThread()
    }
    
    @objc func countDownThread() {
        guard self.limitTime >= 0 else {
            return
        }
        self.updateJumpBtn()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.limitTime -= 1
            self.countDownThread()
        }
    }
    
    @objc func updateJumpBtn() {
        if (limitTime <= 0) {
            l_agree.text = nh_localizedString(forKey: "agree")
            btn_new.isEnabled = true
            btn_agree.layer.backgroundColor = UIColor(hexString: "2864AA").cgColor
            btn_disagree.isEnabled = true
            btn_disagree.setTitleColor(UIColor(hexString: "2864AA"), for: .normal)
            btn_disagree.layer.borderColor = UIColor(hexString: "2864AA").cgColor
        } else {
            l_agree.text = nh_localizedString(forKey: "agree") + "(\(limitTime)s)"
            btn_new.isEnabled = false
            btn_agree.layer.backgroundColor = UIColor(hexString: "CCCCCC").cgColor
            btn_disagree.isEnabled = false
            btn_disagree.layer.borderColor = UIColor(hexString: "CCCCCC").cgColor
            btn_disagree.setTitleColor(UIColor(hexString: "CCCCCC"), for: .normal)
        }
    }

}
