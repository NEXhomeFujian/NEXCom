//
//  PermissionViewController.swift
//  NEXcom
//
//  Created by csh on 2022/9/24.
//

import UIKit
import WebKit
import SnapKit
import NHFoundation
import Lottie
class PermissionViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var v_pri: UIView!
    lazy var v_wkweb = WKWebView()
    var navigationHistory: [URL] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let url = URL(string: getCurrentPrivacyUrlString()) {
            
            let urlRequest = URLRequest(url: url)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.v_pri.addSubview(self.v_wkweb)
                self.v_pri.layer.cornerRadius = 6
                self.v_wkweb.layer.cornerRadius = 6
                self.v_wkweb.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                self.v_wkweb.uiDelegate = self
                self.v_wkweb.navigationDelegate = self

                self.v_wkweb.load(urlRequest)
                self.title = nh_localizedString(forKey: "agreement")
            }
        }
        
        let starView = AnimationView(name: "data")
//        self.view.addSubview(starView)
//        starView.loopMode = .playOnce
//        starView.play()

    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if (!(navigationAction.targetFrame?.isMainFrame ?? false) ) {
            webView.load(navigationAction.request)

        }
        
        return nil
    }
    

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
       // print(navigation)
    } 
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
}
extension PermissionViewController {
    // 添加导航记录
    func addNavigationHistory(_ url: URL) {
        if navigationHistory.last != url {
            navigationHistory.append(url)
        }
    }
    
    // 后退一个页面
    @objc func goBack() {
        if navigationHistory.count > 1 {
            navigationHistory.removeLast()
            let previousURL = navigationHistory.last
            loadURL(previousURL!.absoluteString)
        } else{
            self.navigationController?.popViewController(animated: true)
        }
            
    }
    // 加载指定 URL
    func loadURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            v_wkweb.load(request)
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let currentURL = webView.url {
            addNavigationHistory(currentURL)
        }
    }
    
    // 监听用户点击返回按钮
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 监听返回按钮点击事件
        let backButtonImage = UIImage(named: "return")
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = backButton
    }
}
