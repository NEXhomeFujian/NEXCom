//
//  AudioSettingViewCtrl.swift
//  NexPhone
//
//  Created by 骆亮 on 2022/8/24.
//

import UIKit
import linphonesw
import SwiftUI
import NHFoundation

class AudioSettingViewCtrl: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tb_main: UITableView!
    
    @IBOutlet weak var v_tip: UIImageView!
    @IBOutlet weak var v_ano: UIView!
    @IBOutlet weak var b_save: UIButton!
    
    var listRow: [String] = []
    var listRowValue: [String:Bool] = [:]
    var list: [NHAudioCode] = [ ]
    var countTimer = Timer()

    /*
     * iOS11以下型号,通过自己写长按手势实现拖拽功能,需要如下属性
     */
    /// 手势储存point,保证有两个,为初始点和结束点
    private var touchPoints: [CGPoint] = []
    /// 手势选中cell.index
    private var sourceIndexPath: IndexPath?
    /// 将手势选中cell以image形式表现
    private var cellImageView = UIImageView()
    /// 被手势选中的cell
    
    private var currentCell:UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
//        if UserDefaults.standard.array(forKey: "audio") == nil {
//            listRow =  [ "pcma", "g722", "pcmu" ]
//        } else {
//            listRow = UserDefaults.standard.array(forKey: "audio") as?[String] ?? [ "pcma", "g722", "pcmu" ]
//        }
        if UserDefaults.standard.array(forKey: "audio") == nil {
            listRow =  [ "pcma", "pcmu" ]
        } else {
            listRow = UserDefaults.standard.array(forKey: "audio") as?[String] ?? [ "pcma",  "pcmu" ]
        }
        for row in listRow {
            if row == "pcma" {
                list.append(.pcma)
            } else if row == "g722"{
                list.append(.g722)
            } else {
                list.append(.pcmu)
            }
        }
        self.setupUI()
    }

    func setupUI() {
        self.title = nh_localizedString(forKey: "AudioSet")
        self.tb_main.backgroundColor = .groupTableViewBackground
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.tb_main.tableFooterView = UIView()
        self.tb_main.register(.init(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
        self.b_save.addTarget(self, action: #selector(self.saveValue), for: .touchUpInside)
        self.b_save.backgroundColor = UIColor(hexString: "ffcccccc")
        self.b_save.isUserInteractionEnabled = false
        self.v_ano.layer.cornerRadius = 4
        self.v_tip.layer.cornerRadius = 8
        if UserDefaults.standard.dictionary(forKey: "audioValue") == nil {
            listRowValue =  [ "pcma":true,  "pcmu":true ]
        } else {
            
            listRowValue = UserDefaults.standard.dictionary(forKey: "audioValue") as? [String:Bool] ?? [ "pcma":true,  "pcmu":true]
        }
        
        NHVoipManager.it.audioCode(.pcma)?.enable(enabled: listRowValue["pcma"] ?? true)
        NHVoipManager.it.audioCode(.pcmu)?.enable(enabled: listRowValue["pcmu"] ?? true)
        
        
        
    }
    @objc func saveValue(){
        listRow = []
        for row in list {
            if row == .pcma {
                listRow.append("pcma")
                listRowValue.updateValue(NHVoipManager.it.audioCode(.pcma)?.enabled() ?? true, forKey: "pcma")
            } else {
                listRow.append("pcmu")
                listRowValue.updateValue(NHVoipManager.it.audioCode(.pcmu)?.enabled() ?? true, forKey: "pcmu")
            }
        }
        UserDefaults.standard.setValue(listRowValue, forKey: "audioValue")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.setValue(listRow, forKey: "audio")
        UserDefaults.standard.synchronize()
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.list.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
        cell.l_type.text = list[indexPath.row].rawValue
        if indexPath.row == 2 {
            
            cell.separatorInset = .init(top: 0, left: 1000, bottom: 0, right: 0)
        } else {
            cell.separatorInset = .init(top: 0, left: -20, bottom: 0, right: 0)
        }
        if list[indexPath.row].rawValue == "pcma" {
            
            cell.l_up.text = "PCMA"
        } else if list[indexPath.row].rawValue == "pcmu" {
            cell.l_up.text = "PCMU"
        }
        
        if cell.l_type.text == "pcma" {
            cell.bt_switch.isSelected = (NHVoipManager.it.audioCode(.pcma)?.enabled() == true)
        }else if cell.l_type.text == "pcmu" {
            cell.bt_switch.isSelected = (NHVoipManager.it.audioCode(.pcmu)?.enabled() == true)
        }
        
//        if cell.l_type.text == "pcma" {
//            cell.bt_switch.isSelected = listRowValue["pcma"] ?? true
//            NHVoipManager.it.audioCode(.pcma)?.enable(enabled: cell.bt_switch.isSelected)
//        }else if cell.l_type.text == "g722" {
//            cell.bt_switch.isSelected = listRowValue["g722"] ?? true
//            NHVoipManager.it.audioCode(.g722)?.enable(enabled: cell.bt_switch.isSelected)
//        }else if cell.l_type.text == "pcmu"{
//            cell.bt_switch.isSelected = listRowValue["pcmu"] ?? true
//            NHVoipManager.it.audioCode(.pcmu)?.enable(enabled: cell.bt_switch.isSelected)
//        }
        cell.audioBlock = {

            
            if $0 == "pcma" {
                if  (NHVoipManager.it.audioCode(.pcmu)?.enabled() == false) {
                    self.v_ano.isHidden =  false
                    self.countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countTime), userInfo: nil, repeats: true)
                }else {
                    
                    
                    
                    self.b_save.backgroundColor = UIColor(hexString: "2864aa")
                    self.b_save.isUserInteractionEnabled = true
                    NHVoipManager.it.audioCode(.pcma)?.enable(enabled: !cell.bt_switch.isSelected)
                    cell.bt_switch.isSelected = !cell.bt_switch.isSelected
                }
                
            }else if $0 == "pcmu"{
                if (NHVoipManager.it.audioCode(.pcma)?.enabled() == false) {
                    self.v_ano.isHidden =  false
                    self.countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countTime), userInfo: nil, repeats: true)
                }else {
                    self.b_save.backgroundColor = UIColor(hexString: "2864aa")
                    self.b_save.isUserInteractionEnabled = true
                    NHVoipManager.it.audioCode(.pcmu)?.enable(enabled: !cell.bt_switch.isSelected)
                    cell.bt_switch.isSelected = !cell.bt_switch.isSelected
                }
            }
           

        }
//        cell.bt_switch.isSelected = true
//        let model = self.list[indexPath.row]
//        let usable: Bool = NHVoipManager.it.audioCode(model)?.enabled() ?? false
//        cell.textLabel?.text = model.rawValue + " - " + (usable ? "启用" : "未启用")
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.cellPanPressGesture))
        cell.v_touch.addGestureRecognizer(pan)
        return cell
    }
    @objc func countTime(){
        v_ano.isHidden = true
        countTimer.invalidate()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        52
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let model = self.list[indexPath.row]
//        let usable: Bool = NHVoipManager.it.audioCode(model)?.enabled() ?? false
//        let result = NHVoipManager.it.audioCode(model)?.enable(enabled: !usable)
//        tableView.reloadData()
    }


}
extension AudioSettingViewCtrl {
    /***
     *  实际上拖拽的不是cell,而是cell的快照imageView.并且同时将cell隐藏,当拖拽手势结束时,通过moveRow方法调换cell位置,进行数据修改.并且将imageView删除.再将cell展示出来,就实现了拖拽动画.
     */
    /// 手势方法
//    @objc func longPressGesture(_ recognise: UILongPressGestureRecognizer) {
    @objc func cellPanPressGesture(_ recognise: UIPanGestureRecognizer) {
        let currentPoint: CGPoint = recognise.location(in: self.tb_main)
        let currentIndexPath = self.tb_main?.indexPathForRow(at: currentPoint)
        guard let indexPath = currentIndexPath else {
            /// 将生成的cellimage清除
            initCellImageView()
            return
        }
        if indexPath.section == 0 {
            guard indexPath.row < self.list.count else {
                /// 将生成的cellimage清除
                initCellImageView()
                return
            }
        }else if indexPath.section == 1 {
            guard indexPath.row < self.list.count else {
                /// 将生成的cellimage清除
                initCellImageView()
                return
            }
        }else if indexPath.section == 2 {
            guard indexPath.row < self.list.count else {
                /// 将生成的cellimage清除
                initCellImageView()
                return
            }
        }
        
        switch recognise.state {
        case .began:
            /// 手势开始状态
            longPressGestureBegan(recognise)
        case .changed:
            /// 手势拖拽状态
            longPressGestureChanged(recognise)
        default:
            /// 手势结束状态
            /// 清空保存的手势点
             self.touchPoints.removeAll()
            /// 将隐藏的cell展示
            if let cell = self.tb_main?.cellForRow(at: sourceIndexPath! ) {
                cell.isHidden = false
            }
            /// 将生成的cellimage清除
            initCellImageView()
        }
    }
    /// 长按开始状态调用方法
    private func longPressGestureBegan(_ recognise: UIPanGestureRecognizer) {
        /// 获取长按手势触发时的接触点
        let currentPoint: CGPoint = recognise.location(in: self.tb_main)
        /// 根据手势初始点获取需要拖拽的cell.indexPath
        guard let currentIndexPath = self.tb_main?.indexPathForRow(at: currentPoint) else { return }
        /// 将拖拽cell.index储存
        sourceIndexPath = currentIndexPath
        /// 获取拖拽cell
        currentCell = self.tb_main?.cellForRow(at: currentIndexPath )
        /// 获取拖拽cell快照
        cellImageView = getImageView(currentCell)
        /// 将快照加入到tableView.把拖拽cell覆盖
        cellImageView.frame = currentCell.frame
        self.tb_main?.addSubview(cellImageView)
        /// 将选中cell隐藏
        self.currentCell.isHidden = true
    }
    /// 拖拽手势过程中方法,核心方法,实现拖拽动画和数据的更新
    
    private func longPressGestureChanged(_ recognise: UIPanGestureRecognizer) {
        let selectedPoint: CGPoint = recognise.location(in: self.tb_main)
        let selectedIndexPath = self.tb_main?.indexPathForRow(at: selectedPoint)
        /// 将手势的点加入touchPoints并保证其内有两个点,即一个初始点,一个结束点,实现cell快照imageView从初始点到结束点的移动动画
        self.touchPoints.append(selectedPoint)
        if self.touchPoints.count > 2 {
            self.touchPoints.remove(at: 0)
        }
        var center = cellImageView.center
        center.y = selectedPoint.y
        // 快照x值随触摸点x值改变量移动,保证用户体验
        let pPoint = self.touchPoints.first
        let nPoint = self.touchPoints.last
        let moveX = nPoint!.x - pPoint!.x
        center.x += moveX
        cellImageView.center = center
        //同section才能调整位置
        guard let selIndexPath = selectedIndexPath, sourceIndexPath?.section == selIndexPath.section else { return }
        /// 如果手势当前index不同于拖拽cell,则需要moveRow,实现tableView上非拖拽cell的动画,这里还要实现数据源的重置,保证拖拽手势后tableView能正确的展示
        if  selIndexPath != sourceIndexPath && sourceIndexPath != nil {
            self.tb_main?.beginUpdates()
           
//            if selIndexPath.section == 0 {
//                self.list = self.updateCellDataSction1(selectedIndexPath: selIndexPath, arData: self.mar_if) as? [NHAudioCode] ?? []
//            }
//            self.refreshDataFromTabv()
            let model: NHAudioCode = list[sourceIndexPath!.row]
            list.remove(at: sourceIndexPath!.row)
                      if selectedIndexPath!.row > list.count{
                          list.append(model)
                      }else{
                          list.insert(model, at: selectedIndexPath!.row)
                      }
            self.b_save.backgroundColor = UIColor(hexString: "2864aa")
            self.b_save.isUserInteractionEnabled = true
            /// 调用moveRow方法,修改被隐藏的选中cell位置,保证选中cell和快照imageView在同一个row,实现动画效果
            self.tb_main?.moveRow(at: sourceIndexPath!, to: selectedIndexPath!)
            self.tb_main?.endUpdates()
            sourceIndexPath = selectedIndexPath
        }
    }
    
    private func updateCellDataSction1(selectedIndexPath:IndexPath, arData:[Any]) -> [Any] {
        /// 线程锁
        objc_sync_enter(self)
//            / 先更新tableView数据源
        var marData = arData
        let cellmode = marData[sourceIndexPath!.row]

//        //处理展示列表数据
        let i_select:Int = selectedIndexPath.row
        let i_source:Int = sourceIndexPath!.row

        marData.remove(at: i_source)
        marData.insert(cellmode, at: i_select)
        
        
        objc_sync_exit(self)
        return marData
    }
    /// 将生成的cell快照删除
    private func removeCellImageView() {
        self.cellImageView.removeFromSuperview()
        self.cellImageView = UIImageView()
        self.tb_main?.reloadData()
    }
    private func initCellImageView() {
        self.cellImageView.removeFromSuperview()
        self.tb_main?.reloadData()
    }
    /// 获取cell快照imageView
    private func getImageView(_ cell: UITableViewCell) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: image)
        return imageView
    }
}

class AudioItem: NSObject {
    var name: NHAudioCode!
    var enable: Bool = true
    init(name: NHAudioCode,enable: Bool = true) {
        self.name = name
        self.enable = enable
    }
}
