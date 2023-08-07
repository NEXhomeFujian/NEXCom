//
//  NHNavigationCtrl.swift
//  greenhome
//
//  Created by Thinking on 2019/5/7.
//  Copyright © 2019 yango. All rights reserved.
//

import UIKit
import NHFoundation

class NHNavigationCtrl: UINavigationController, UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    func setupUI() {
        self.navigationBar.backIndicatorImage = UIImage.init(named: "icon_back_b");
        self.navigationBar.backIndicatorTransitionMaskImage = UIImage.init(named: "icon_back_b");

        //去掉线条 透明背景
        let img_t:UIImage? = UIColor.clear.nh_toImage(.init(width: self.navigationBar.bounds.size.width, height: self.navigationBar.bounds.size.height))
        self.navigationBar.setBackgroundImage(img_t, for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage.init()
        self.navigationBar.tintColor = UIColor.black
        self.navigationBar.isTranslucent = true
        let dict:NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.init(name: "PingFangSC-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)]
        self.navigationBar.titleTextAttributes = dict as? [NSAttributedString.Key : AnyObject]
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
        super.pushViewController(viewController, animated: animated);
    }
}

extension  UINavigationController{
    /// 设置为黑色
    public func setBarBlack(){
        self.navigationBar.tintColor = UIColor.black
        let dict:NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.init(name: "PingFangSC-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)]
        self.navigationBar.titleTextAttributes = dict as? [NSAttributedString.Key : AnyObject]
    }
    /// 设置为白色
    public func setBarWhite(){
        self.navigationBar.tintColor = UIColor.white
        let dict:NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont.init(name: "PingFangSC-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)]
        self.navigationBar.titleTextAttributes = dict as? [NSAttributedString.Key : AnyObject]
    }
    /// 设置背景透明
    public func setBarBackgroundClear() {
        self.navigationBar.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default)
    }
    /// 设置为默认样式
    public func setBarBackgroundDefault() {
        self.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
    }
}
