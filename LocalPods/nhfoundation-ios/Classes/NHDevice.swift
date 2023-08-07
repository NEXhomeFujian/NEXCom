//
//  NHDevice.swift
//  NHFoundation
//
//  Created by 骆亮 on 2022/6/2.
//

import UIKit

class NHDevice: NSObject { }

extension UIDevice {
    
    /// e.g. "4.0"
    public var nh_systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    /// 设备型号
    public var nh_modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        if (uname(&systemInfo) < 0) {
            return "";
        } else {
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier:String = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else {return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            let modelName: String = self.nh_models[identifier] ?? identifier
            return modelName
        }
    }
    
    /// 设备型号数据
    public var nh_models: [String: String] {
        [
            // iPhone
            "iPhone1,1" : "iPhone",
            "iPhone1,2" : "iPhone 3G",
            "iPhone2,1" : "iPhone 3GS",
            "iPhone3,1" : "iPhone 4",
            "iPhone3,2" : "iPhone 4",
            "iPhone3,3" : "iPhone 4",
            "iPhone4,1" : "iPhone 4S",
            "iPhone5,1" : "iPhone 5",
            "iPhone5,2" : "iPhone 5",
            "iPhone5,3" : "iPhone 5c",
            "iPhone5,4" : "iPhone 5c",
            "iPhone6,1" : "iPhone 5s",
            "iPhone6,2" : "iPhone 5s",
            "iPhone7,2" : "iPhone 6",
            "iPhone7,1" : "iPhone 6 Plus",
            "iPhone8,1" : "iPhone 6s",
            "iPhone8,2" : "iPhone 6s Plus",
            "iPhone8,4" : "iPhone SE (1st generation)",
            "iPhone9,1" : "iPhone 7",
            "iPhone9,3" : "iPhone 7",
            "iPhone9,2" : "iPhone 7 Plus",
            "iPhone9,4" : "iPhone 7 Plus",
            "iPhone10,1" : "iPhone 8",
            "iPhone10,4" : "iPhone 8",
            "iPhone10,2" : "iPhone 8 Plus",
            "iPhone10,5" : "iPhone 8 Plus",
            "iPhone10,3" : "iPhone X",
            "iPhone10,6" : "iPhone X",
            "iPhone11,8" : "iPhone XR",
            "iPhone11,2" : "iPhone XS",
            "iPhone11,6" : "iPhone XS Max",
            "iPhone11,4" : "iPhone XS Max",
            "iPhone12,1" : "iPhone 11",
            "iPhone12,3" : "iPhone 11 Pro",
            "iPhone12,5" : "iPhone 11 Pro Max",
            "iPhone12,8" : "iPhone SE (2nd generation)",
            "iPhone13,1" : "iPhone 12 mini",
            "iPhone13,2" : "iPhone 12",
            "iPhone13,3" : "iPhone 12 Pro",
            "iPhone13,4" : "iPhone 12 Pro Max",
            "iPhone14,4" : "iPhone 13 mini",
            "iPhone14,5" : "iPhone 13",
            "iPhone14,2" : "iPhone 13 Pro",
            "iPhone14,3" : "iPhone 13 Pro Max",
            "iPhone14,6" : "iPhone SE (3rd generation)",
            // iPad
            "iPad1,1" : "iPad",
            "iPad2,1" : "iPad 2",
            "iPad2,2" : "iPad 2",
            "iPad2,3" : "iPad 2",
            "iPad2,4" : "iPad 2",
            "iPad3,1" : "iPad (3rd generation)",
            "iPad3,2" : "iPad (3rd generation)",
            "iPad3,3" : "iPad (3rd generation)",
            "iPad3,4" : "iPad (4th generation)",
            "iPad3,5" : "iPad (4th generation)",
            "iPad3,6" : "iPad (4th generation)",
            "iPad6,11" : "iPad (5th generation)",
            "iPad6,12" : "iPad (5th generation)",
            "iPad7,5" : "iPad (6th generation)",
            "iPad7,6" : "iPad (6th generation)",
            "iPad7,11" : "iPad (7th generation)",
            "iPad7,12" : "iPad (7th generation)",
            "iPad11,6" : "iPad (8th generation)",
            "iPad11,7" : "iPad (8th generation)",
            "iPad12,1" : "iPad (9th generation)",
            "iPad12,2" : "iPad (9th generation)",
            "iPad4,1" : "iPad Air",
            "iPad4,2" : "iPad Air",
            "iPad4,3" : "iPad Air",
            "iPad5,3" : "iPad Air 2",
            "iPad5,4" : "iPad Air 2",
            "iPad11,3" : "iPad Air (3rd generation)",
            "iPad11,4" : "iPad Air (3rd generation)",
            "iPad13,1" : "iPad Air (4th generation)",
            "iPad13,2" : "iPad Air (4th generation)",
            "iPad13,16" : "iPad Air (5th generation)",
            "iPad13,17" : "iPad Air (5th generation)",
            "iPad6,7" : "iPad Pro (12.9-inch)",
            "iPad6,8" : "iPad Pro (12.9-inch)",
            "iPad6,3" : "iPad Pro (9.7-inch)",
            "iPad6,4" : "iPad Pro (9.7-inch)",
            "iPad7,1" : "iPad Pro (12.9-inch) (2nd generation)",
            "iPad7,2" : "iPad Pro (12.9-inch) (2nd generation)",
            "iPad7,3" : "iPad Pro (10.5-inch)",
            "iPad7,4" : "iPad Pro (10.5-inch)",
            "iPad8,1" : "iPad Pro (11-inch)",
            "iPad8,2" : "iPad Pro (11-inch)",
            "iPad8,3" : "iPad Pro (11-inch)",
            "iPad8,4" : "iPad Pro (11-inch)",
            "iPad8,5" : "iPad Pro (12.9-inch) (3rd generation)",
            "iPad8,6" : "iPad Pro (12.9-inch) (3rd generation)",
            "iPad8,7" : "iPad Pro (12.9-inch) (3rd generation)",
            "iPad8,8" : "iPad Pro (12.9-inch) (3rd generation)",
            "iPad8,9" : "iPad Pro (11-inch) (2nd generation)",
            "iPad8,10" : "iPad Pro (11-inch) (2nd generation)",
            "iPad8,11" : "iPad Pro (12.9-inch) (4th generation)",
            "iPad8,12" : "iPad Pro (12.9-inch) (4th generation)",
            "iPad13,4" : "iPad Pro (11-inch) (3rd generation)",
            "iPad13,5" : "iPad Pro (11-inch) (3rd generation)",
            "iPad13,6" : "iPad Pro (11-inch) (3rd generation)",
            "iPad13,7" : "iPad Pro (11-inch) (3rd generation)",
            "iPad13,8" : "iPad Pro (12.9-inch) (5th generation)",
            "iPad13,9" : "iPad Pro (12.9-inch) (5th generation)",
            "iPad13,10" : "iPad Pro (12.9-inch) (5th generation)",
            "iPad13,11" : "iPad Pro (12.9-inch) (5th generation)",
            "iPad2,5" : "iPad mini",
            "iPad2,6" : "iPad mini",
            "iPad2,7" : "iPad mini",
            "iPad4,4" : "iPad mini 2",
            "iPad4,5" : "iPad mini 2",
            "iPad4,6" : "iPad mini 2",
            "iPad4,7" : "iPad mini 3",
            "iPad4,8" : "iPad mini 3",
            "iPad4,9" : "iPad mini 3",
            "iPad5,1" : "iPad mini 4",
            "iPad5,2" : "iPad mini 4",
            "iPad11,1" : "iPad mini (5th generation)",
            "iPad11,2" : "iPad mini (5th generation)",
            "iPad14,1" : "iPad mini (6th generation)",
            "iPad14,2" : "iPad mini (6th generation)",
            // 其他
            "i386" : "iPhone Simulator",
            "x86_64" : "iPhone Simulator",
        ]
    }
}
