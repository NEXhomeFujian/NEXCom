//
//  NHString.swift
//  NHFoundation_Example
//
//  Created by 骆亮 on 2021/11/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

// MARK: - 新增功能
extension String {
    
    /// 去掉前后空格
    /// - Returns: String
    public func nh_trim() -> String {
        return trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    /// 去掉所有空格
    /// - Returns: String
    public func nh_removeSpace() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
    
    /// 通过format插入字符串
    /// - Parameter arguments: 参数
    /// - Returns: String
    public func nh_formatted(_ arguments: CVarArg...) -> String {
        return String(format: self, arguments: arguments)
    }
    
    /// 是否为空，空格不算在内
    /// - Returns: Bool
    public func nh_isEmpty() -> Bool {
        return self.nh_trim().count <= 0
    }
    
}

// MARK: - 计算和裁剪
extension String {
    
    /// 获取字符串特定的长度，中文表情占2个字节
    /// - Returns: 字符串长度
    public func nh_getCount() -> Int {
        var nic_count:Int = 0
        self.forEach { (ch) in
            let i_c = "\(ch)".lengthOfBytes(using: .utf8)
            if i_c == 3 || i_c == 4 { // 汉字或表情
                nic_count += 2
            }else {
                nic_count += 1
            }
        }
        return nic_count
    }
    
    /// 截取到特定长度的字符串
    /// - Parameter count: 长度
    /// - Returns: 特定长度的字符串
    public func nh_prefixString(to count:Int) -> String {
        var nic_count:Int = 0
        var content_t:String = ""
        for ch in self {
            let i_c = "\(ch)".lengthOfBytes(using: .utf8)
            //汉字或表情
            if i_c == 3 || i_c == 4 {
                nic_count += 2
            }else {
                nic_count += 1
            }
            if nic_count <= count {
                content_t = String("\(content_t)\(ch)")
            }else{
                break
            }
            
        }
        return content_t
    }
    
}


import CommonCrypto
// MARK: - MD5加密
extension String {

    /// 获取md5加密后字符串
    /// - Returns: 加密字符串
    public func nh_md5String() -> String {
        let cStr = self.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16 {
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }
}


// MARK: - json转对象
extension String {
    
    /// json字符串转多种类型
    /// - Parameter type: 待转换的类型
    /// - Returns: 转换结果
    public func nh_to<T>(_ type: T.Type) -> T? {
        if let jsonData:Data = self.data(using: .utf8) {
            if let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? T {
                return dict
            }
        }
        return nil
    }
    
    /// json字符串转【字典】
    /// - Returns: 转换结果
    public func nh_toDictionary() -> NSDictionary? {
        return self.nh_to(NSDictionary.self)
    }
    
    /// json字符串转【数组】
    /// - Returns: 转换结果
    public func nh_toArray() -> NSArray? {
        return self.nh_to(NSArray.self)
    }
    
}


// MARK: - 对象转json字符串
extension String {
    
    /// 将 Any 类型转换为字符串
    /// - Parameter obj: any
    /// - Returns: 转换结果
    static public func nh_json(by obj: Any) -> String? {
        guard JSONSerialization.isValidJSONObject(obj) else {
            return nil
        }
        if let data: Data = try? JSONSerialization.data(withJSONObject: obj, options: .fragmentsAllowed) {
            return String.init(data: data, encoding: .utf8)
        }
        return nil
    }
    
}


// MARK: - url编码/解码
extension String {
    
    /// 将urlString编码为合法的urlString
    /// - Returns: urlString
    public func nh_urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
     
    /// 将编码后的urlString转换回原始的urlString
    /// - Returns: urlString
    public func nh_urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
}


// MARK: - 随机字符串
extension String {
    
    /// 随机生成指定长度的字符
    /// - Parameter count: 长度值
    /// - Returns: 随机字符
    static public func nh_arbitrary(_ count: Int) -> String {
        let randomLength = count
        let randomCharacters = tabulate(times: randomLength) { _ in
            Character(UnicodeScalar(Int.random(in: 65...90)) ?? "a")
        }
        return String(randomCharacters)
    }
    static private func tabulate<T>(times: Int, transform: (Int) -> T) -> [T] {
        return (0..<times).map(transform)
    }
    
}


// MARK: - 时间转换
extension String {
    
    /// 时间戳转时间字符串，dateFormat默认："yyyy-MM-dd HH:mm:ss"
    /// - Parameters:
    ///   - timeInterval: 时间戳
    ///   - dateFormat: 时间格式，默认："yyyy-MM-dd HH:mm:ss"
    /// - Returns: 时间字符串
    static public func nh_timeIntervalChangeToTimeStr(timeInterval:Double, _ dateFormat:String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let time = TimeInterval("\(timeInterval)".prefix(10)) ?? 0
        let date:Date = Date.init(timeIntervalSince1970: time)
        let formatter = DateFormatter.init()
        if dateFormat == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            formatter.dateFormat = dateFormat
        }
        return formatter.string(from: date as Date)
    }
    
    /// 通过既定的 dateFormat 将时间戳转换为时间字符串
    /// - Parameter timeInterval: 时间戳
    /// - Returns: 时间字符串
    public func nh_changeToTimeStrWith(timeInterval: Double) -> String {
        return String.nh_timeIntervalChangeToTimeStr(timeInterval: timeInterval, self)
    }
    
    /// 时间字符串转时间戳（String），dateFormat默认："yyyy-MM-dd HH:mm:ss"
    /// - Parameter dateFormat: 时间格式
    /// - Returns: 时间戳
    public func nh_timeStrChangeTotimeInterval(_ dateFormat:String? = "yyyy-MM-dd HH:mm:ss") -> String {
        if self.isEmpty {
           return ""
        }
        let format = DateFormatter.init()
        format.dateStyle = .medium
        format.timeStyle = .short
        if dateFormat == nil {
           format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
           format.dateFormat = dateFormat
        }
        let date = format.date(from: self)
        return String(date!.timeIntervalSince1970)
    }

}


extension String {
    
    /// 字符串首字母，A-Z，其他为 “#”
    /// - Returns: 首字母
    public func nh_firstLetter() -> String {
        let letter =  self.nh_firstChar()
        let regex = "^[A-Z]$"
        let pred = NSPredicate.init(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: letter) ? letter : "#"
    }
    
    /// 字符串首字母
    /// - Returns: 首字母
    public func nh_firstChar() -> String {
        guard self.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 else { return "" }
        let mutableString = NSMutableString.init(string: self)
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformStripDiacritics, false)
        let letter = String(mutableString.capitalized.prefix(1))
        return letter
    }
}



// MARK: - 正则表达式
public enum NHRegularExpression: String {
    /// 邮箱
    case email = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
    /// 域名
    case domain = "[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+\\.?"
    /// 手机号
    case phone = "^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\\d{8}$"
    /// 手机+固话
    case phoneAndTel = "((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)"
    /// 身份证号
    case IDNumber = "(^\\d{15}$)|(^\\d{18}$)|(^\\d{17}(\\d|X|x)$)"
    /// 邮编号
    case postalCode = "[1-9]\\d{5}(?!\\d)"
    /// 车牌号
    case carNumber = "^([京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[a-zA-Z](([DF]((?![IO])[a-zA-Z0-9](?![IO]))[0-9]{4})|([0-9]{5}[DF]))|[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1})$"
}

// MARK: - 正则相关
extension String {
    
    /// 校验字符串
    /// - Parameter patternInner: 内置正则表达式
    /// - Returns: 校验结果
    public func nh_regexWith(_ patternInner: NHRegularExpression) -> Bool {
        return self.nh_regexWith(patternInner.rawValue)
    }
    
    /// 校验字符串
    /// - Parameters:
    ///   - pattern: 这则表达式
    /// - Returns: 校验结果
    public func nh_regexWith(_ pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression.init(pattern: pattern, options: [.allowCommentsAndWhitespace])
            let number = regex.numberOfMatches(in: self, options: .init(rawValue: 0), range: NSMakeRange(0, self.count))
            return number > 0
        } catch {
            return false
        }
    }
     
    /// 匹配字符串数组
    /// - Parameter pattern: 正则表达式
    /// - Returns: 匹配结果
    public func nh_regexStringsWith(_ pattern: String) -> [String] {
        var subStrs:[String] = []
        do {
            let regex = try NSRegularExpression.init(pattern: pattern, options:[.caseInsensitive])
            let results = regex.matches(in: self, options: .init(rawValue: 0), range: NSMakeRange(0, self.count))
            for rst in results {
                let nsStr = self as NSString
                subStrs.append(nsStr.substring(with: rst.range))
            }
            return subStrs
        } catch {
            return subStrs
        }
    }

}
