//
//  AboutViewController.swift
//  CustomizeUITableViewCell
//
//  Created by csh on 2022/9/12.
//

import UIKit
import NHFoundation
class AboutViewController: UIViewController {

    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var btn_pas: UIButton!
    @IBOutlet weak var lab_emial: UILabel!
    @IBOutlet weak var lab_version: UILabel!
    @IBOutlet weak var img_logopic: UIImageView!
    
    @IBOutlet weak var v_tip: UIView!
    @IBOutlet weak var imv_tip: UIImageView!
    
  
//    override func viewWillAppear(_ animated: Bool) {
//           super.viewWillAppear(animated)
//           self.view.layoutIfNeeded()
//        let style = UIView(frame: CGRect(x: img_logopic.frame.origin.x, y: img_logopic.frame.origin.y+88, width: img_logopic.frame.width, height: img_logopic.frame.height))
//        self.view.insertSubview(style, belowSubview: img_logopic)
//        style.layer.cornerRadius = 8
//        style.layer.backgroundColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
//        style.alpha = 1
//        let shadowLayer0 = CALayer()
//        shadowLayer0.frame = style.bounds
//        shadowLayer0.shadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.1).cgColor
//        shadowLayer0.shadowOpacity = 1
//        shadowLayer0.shadowOffset = CGSize(width: 0, height: 2)
//        shadowLayer0.shadowRadius = 3
//        let shadowSize0:CGFloat = 0
//        let shadowSpreadRect0 = CGRect(x: -shadowSize0, y: -shadowSize0, width: style.bounds.size.width+shadowSize0*2, height: style.bounds.size.height+shadowSize0*2)
//        let shadowSpreadRadius0 =  style.layer.cornerRadius == 0 ? 0 : style.layer.cornerRadius+shadowSize0;
//        let shadowPath0 = UIBezierPath(roundedRect: shadowSpreadRect0, cornerRadius: shadowSpreadRadius0)
//        shadowLayer0.shadowPath = shadowPath0.cgPath;
//        style.layer.addSublayer(shadowLayer0)
//       }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = .groupTableViewBackground
        setShadow(view: img_logopic, sColor: UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.1), offset: CGSize(width: 0, height: 2), opacity: 1, radius: 3)
        img_logopic.layer.masksToBounds = false
        lab_emial.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        
        lab_version.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        
        btn_pas.addTarget(self, action: #selector(AboutViewController.pasteBtnAction), for: .touchUpInside)
        let infoDictionary = Bundle.main.infoDictionary
        if let infoDictionary = infoDictionary {
            let appVersion = infoDictionary["CFBundleShortVersionString"] as! String
             let appBuild = infoDictionary["CFBundleVersion"] as! String
            lab_version.text = nh_localizedString(forKey: "l_version") + String(describing: appVersion) + "(" + String(describing: appBuild) + ")"
            print("version\(appVersion),build\(appBuild)")
          }

        self.title = nh_localizedString(forKey: "about")
        
//        self.imv_tip.image = UIImage.init(named: "tip")?.withRenderingMode(.alwaysTemplate)
//        self.imv_tip.tintColor = UIColor.white
        
    }
    
    @objc func pasteBtnAction(){
        UIPasteboard.general.string = lab_emial.text
        self.v_tip.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.v_tip.isHidden = true
        }
    }

}

