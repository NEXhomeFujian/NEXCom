//
//  VideoSettingViewCtrl.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/24.
//

import UIKit
import linphonesw
import NHFoundation

class VideoSettingViewCtrl: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var b_tip_head: UIButton!
    @IBOutlet weak var l_bit_type: UILabel!
    @IBOutlet weak var tv_bit: UITableView!
    @IBOutlet var v_bit: UIView!
    @IBOutlet weak var l_type: UILabel!
    @IBOutlet weak var b_close: UIButton!
    @IBOutlet weak var b_save: UIButton!
    @IBOutlet var v_ano: UIView!
    @IBOutlet weak var tb_main: UITableView!
    @IBOutlet weak var v_main: UITableView!
    @IBOutlet weak var v_head: UIView!
    var videoList: [String] = []
   
    let list: [VideoSettingItem] = [
        VideoSettingItem.init(name: nh_localizedString(forKey: "Resolving"), items: ["QVGA", "VGA", "720P"], selectedIndex: 0),
        VideoSettingItem.init(name: nh_localizedString(forKey: "Bit"), items: ["128", "256", "512", "1024", "2048"], selectedIndex: 0),
        VideoSettingItem.init(name: nh_localizedString(forKey: "Frame"), items: ["25 fps"]),
//        VideoSettingItem.init(name: "Payload", items: [""]),
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setupUI()
    }

    func setupUI() {
        // 当前h264启用状态
        self.title = nh_localizedString(forKey: "VideoSet")
        if UserDefaults.standard.array(forKey: "video") == nil {
            videoList =  [ "QVGA", "1024"]
        } else {
            videoList = UserDefaults.standard.array(forKey: "video") as?[String] ?? [ "QVGA", "1024"]
        }
        self.view.backgroundColor = .groupTableViewBackground
        self.tb_main.backgroundColor = .groupTableViewBackground
        self.tb_main.tableFooterView = UIView()
        self.tb_main.register(.init(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        self.b_save.addTarget(self, action: #selector(self.saveValue), for: .touchUpInside)
        self.b_close.addTarget(self, action: #selector(self.backPage), for: .touchUpInside)
        self.b_tip_head.addTarget(self, action: #selector(self.bitBackPage), for: .touchUpInside)
        self.b_save.backgroundColor = UIColor(hexString: "ffcccccc")
        self.b_save.isUserInteractionEnabled = false
        self.v_main.register(.init(nibName: "TypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TypeTableViewCell")
        v_main.dataSource = self
        v_main.delegate = self
        self.tv_bit.register(.init(nibName: "TypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TypeTableViewCell")
        tv_bit.dataSource = self
        tv_bit.delegate = self
    }
    @objc func saveValue(){
        UserDefaults.standard.setValue(videoList, forKey: "video")
        UserDefaults.standard.synchronize()
        let currentFrame = videoList[0]
        let currentRate = Int(videoList[1]) ?? 1024
         // 设置分辨率
         var name: NHVideoName!
         switch currentFrame {
         case "VGA":
             name = ._vga
         case "720P":
             name = ._720p
         default:
             name = ._qvga
         }
        
        NHVoipManager.it.videoCode(.h264)?.normalBitrate = currentRate
         NHVoipManager.it.setSentVideoDefinitionByName(name)
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 2 {
            return 5
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath) as! VideoTableViewCell
            let model = self.list[indexPath.row]
            if indexPath.row == 0 {
                cell.l_set.text = model.name
                cell.l_type.text = videoList[0]
                cell.b_more.isHidden = false
                cell.b_set.isHidden = false
                cell.l_type.snp.remakeConstraints { make in
                    make.right.equalToSuperview().offset(-40)
                }
                cell.separatorInset = .init(top: 0, left: -20, bottom: 0, right: 0)
            } else if indexPath.row == 1 {
                cell.l_set.text = model.name
                cell.l_type.text = videoList[1] + " kbps"
                cell.b_more.isHidden = false
                cell.b_set.isHidden = false
                cell.l_type.snp.remakeConstraints { make in
                    make.right.equalToSuperview().offset(-40)
                }
                cell.separatorInset = .init(top: 0, left: -20, bottom: 0, right: 0)
            } else if indexPath.row == 2 {
                cell.selectionStyle = .none
                cell.l_set.text = model.name
                cell.b_more.isHidden = true
                cell.b_set.isHidden = true
                cell.l_type.text = "25 fps"
                cell.l_type.snp.remakeConstraints { make in
                    make.right.equalToSuperview().offset(-20)
                }
                cell.separatorInset = .init(top: 0, left: 1000, bottom: 0, right: 0)
                
            }
            cell.videoBlock = {
                print("nnnnn1")
                if $0 == nh_localizedString(forKey: "Resolving"){
                    self.addPage()
                } else {
                    self.addBitPage()
                }
            }
            return cell
        }else if tableView.tag == 1 {
            self.l_type.text = nh_localizedString(forKey: "Resolving")
            let cell:TypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TypeTableViewCell", for: indexPath) as! TypeTableViewCell
            cell.lb_type.text = self.list[0].items[indexPath.row]
            if indexPath.row == 0 {
                cell.lb_type.text = self.list[0].items[indexPath.row] + " (" + nh_localizedString(forKey: "default") + ")"
            }
            cell.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
            if indexPath.row + 1 == 3 {
                cell.separatorInset = .init(top: 0, left: 1000, bottom: 0, right: 0)
            }
            return cell
        } else {
            
            self.l_bit_type.text = nh_localizedString(forKey: "Bit")
            let cell:TypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TypeTableViewCell", for: indexPath) as! TypeTableViewCell
            cell.lb_type.text = self.list[1].items[indexPath.row] + " kbps"
            if indexPath.row == 3 {
                cell.lb_type.text = self.list[1].items[indexPath.row] + " kbps (" + nh_localizedString(forKey: "default") + ")"
            }
            cell.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
            if indexPath.row  == 4 {
                cell.separatorInset = .init(top: 0, left: 1000, bottom: 0, right: 0)
            }
            return cell
        }
        
            //            let index = (model.selectedIndex) % 3
            //            let nextFrame = model.items[index]
            //            let currentFrame = NHVoipManager.it.mCore.preferredVideoDefinitionByName
            //            cell.textLabel?.text = (model.name ?? "") + " - 当前：\(currentFrame)" + " - 下个设置：\(nextFrame)"
            //            let index = (model.selectedIndex) % 5
            //            let nextRate = model.items[index]
            //            let currentRate = NHVoipManager.it.videoCode(.h264)?.normalBitrate ?? 0
            //            cell.textLabel?.text = (model.name ?? "") + " - 当前：\(currentRate)" + " - 下个设置：\(nextRate)"
//            let currentframe = NHVoipManager.it.mCore.preferredFramerate
//            cell.textLabel?.text = (model.name ?? "") + " - 当前：\(currentframe)" + " - 下个设置：\(25)"
        
//        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == 1 {
            videoList[0] = self.list[0].items[indexPath.row]
//            UserDefaults.standard.setValue(videoList, forKey: "video")
//            UserDefaults.standard.synchronize()
            tb_main.reloadData()
            self.b_save.backgroundColor = UIColor(hexString: "2864aa")
            self.b_save.isUserInteractionEnabled = true
            self.backPage()
        } else if tableView.tag == 2 {
            videoList[1] = self.list[1].items[indexPath.row]
            tb_main.reloadData()
            self.b_save.backgroundColor = UIColor(hexString: "2864aa")
            self.b_save.isUserInteractionEnabled = true
            self.bitBackPage()
        }
//        let model = self.list[indexPath.row]
//        if indexPath.row == 0 {
//            let currentFrame = model.items[model.selectedIndex]
//            // 设置分辨率
//            var name: NHVideoName!
//            switch currentFrame {
//            case "VGA":
//                name = ._vga
//            case "720P":
//                name = ._720p
//            default:
//                name = ._qvga
//            }
//            NHVoipManager.it.setSentVideoDefinitionByName(name)
//            model.selectedIndex += 1
//            model.selectedIndex %= 3
//            tableView.reloadData()
//        } else if indexPath.row == 1 { // 比特率设置
//            let rate: Int = Int(model.items[model.selectedIndex]) ?? 0
//            // 设置比特率
//            NHVoipManager.it.videoCode(.h264)?.normalBitrate = rate
//            model.selectedIndex += 1
//            model.selectedIndex %= 5
//            tableView.reloadData()
//        } else if indexPath.row == 2 {
//            // 设置帧率
//            NHVoipManager.it.mCore.preferredFramerate = 25
//            tableView.reloadData()
//        } else {
//
//        }
    }
    @objc func save(){
        UserDefaults.standard.setValue(videoList, forKey: "video")
        UserDefaults.standard.synchronize()
        self.navigationController?.popViewController(animated: true)
    }
    @objc func backPage(){
        self.v_ano.removeFromSuperview()
    }
    @objc func bitBackPage(){
        self.v_bit.removeFromSuperview()
    }
    @objc func addPage(){
//        self.navigationController?.view.addSubview(self.v_ano)
        if let app = UIApplication.shared.keyWindow {
            app.addSubview(v_ano)
        } else {
            self.view.addSubview(v_ano)
        }
        self.v_ano.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.endEditing(true)
    }
    @objc func addBitPage(){
        if let app = UIApplication.shared.keyWindow {
            app.addSubview(v_bit)
        } else {
            self.view.addSubview(v_bit)
        }
        self.v_bit.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.endEditing(true)
    }

}


class VideoSettingItem {
    var name:String?
    var items:[String] = []
    var selectedIndex: Int = 0
    init(name:String? , items:[String] = [], selectedIndex: Int = 0) {
        self.name = name
        self.items = items
        self.selectedIndex = selectedIndex
    }
}
