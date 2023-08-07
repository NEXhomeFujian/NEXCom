//
//  NHData.swift
//  NHFoundation
//
//  Created by 骆亮 on 2023/7/11.
//

import Foundation

extension Data {
    
    /// data转为String
    /// - Returns: 转换结果String
    public func nh_hexString() -> String {
        var hexString:String = self.map { String(format: "%02x", $0) }.joined(separator: "")
        hexString = hexString.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        return hexString
    }
    
}

