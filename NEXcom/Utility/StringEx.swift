//
//  StringEx.swift
//  NEXcom
//
//  Created by 骆亮 on 2022/9/21.
//

import Foundation
import CommonCrypto
import CryptoKit

extension String {
    /// 字符串首字母
    /// - Returns: 首字母
    func nh_firstLetter() -> String {
        guard self.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 else { return "#" }
        let mutableString = NSMutableString.init(string: self)
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformStripDiacritics, false)
        let letter = String(mutableString.capitalized.prefix(1))
        let regex = "^[A-Z]$"
        let pred = NSPredicate.init(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: letter) ? letter : "#"
        
        
    }
    
} 


extension String {
    /// sha256加密
    var sha256: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}
