//
//  NHBrightness.swift
//  zhenro-iOS
//
//  Created by 骆亮 on 2022/1/12.
//  Copyright © 2022 NexHome. All rights reserved.
//

import Foundation
import UIKit

public class NHBrightness: NSObject {
    
    static public var currentBrightness = UIScreen.main.brightness
    
    /// 保存当前的屏幕亮度
    static public func nh_save() {
        self.currentBrightness = UIScreen.main.brightness
    }
    
    /// 设置屏幕亮度，[0, 1]
    /// - Parameter value: 亮度值 [0, 1]
    static public func nh_setBrightness(_ value: CGFloat) {
        let brightness = UIScreen.main.brightness
        let step = 0.005 * ((value > brightness) ? 1 : -1)
        let times: Int = Int(abs((value - brightness) / 0.005))
        for i in 0..<times {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 / 250 * Double(i+1)) {
                UIScreen.main.brightness = brightness + Double(i+1) * step
            }
        }
    }
    
    /// 恢复到保存的亮度
    static public func nh_resume() {
        self.nh_setBrightness(self.currentBrightness)
    }
    
}




