//
//  NHObject.swift
//  NHFoundation_Example
//
//  Created by 骆亮 on 2021/11/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

enum NHModelToolError: Error {
    case message(String)
}

// MARK: - 数据模型 和 字典 相互转换工具
public class NHObject: NSObject {
    
    /// 字典转简单模型，hintDic为映射字典，即key和模型属性映射关系
    /// - Returns: 类型
    static public func nh_decode<T>(_ type: T.Type, resDic: [String:Any] , hintDic:[String:Any]?) throws -> T where T: Decodable {
        // 将映射字典转换成模型所需的字典
        var transformDic = resDic
        if (hintDic != nil) {
            transformDic = self.setUpResourceDic(resDic: resDic, hintDic: hintDic!)
        }
        guard let jsonData = self.getJsonData(param: transformDic) else {
            throw NHModelToolError.message("转成 Data 时出错!!!")
        }
        guard let model = try? JSONDecoder().decode(type, from: jsonData)
            else {
            throw NHModelToolError.message("转成 数据模型 时出错!!!")
        }
        return model
        
    }
    
    /// json转模型，hintDic为映射字典，即key和模型属性映射关系
    /// - Returns: 模型
    static public func nh_decode<T>(_ type: T.Type, jsonData: Data , hintDic:[String:Any]?) throws -> T where T: Decodable {
        guard let resDic: [String:Any] = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] else {
            throw NHModelToolError.message("转成 字典 时出错!!!")
        }
        return try! self.nh_decode(type, resDic: resDic, hintDic: hintDic)
    }
    
    /// 字典转json字符串
    /// - Parameter dictionary: 字典数据
    /// - Returns: json字符串
    static public func nh_encode(dictionary:[String:Any]) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")//getJSONStringFromDictionary
            return ""
        }
        let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        guard let data_t = data as NSData? else {
            return ""
        }
        let JSONString = NSString(data:data_t as Data, encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }

    /// 根据映射字典设置当前字典内容
    private static func setUpResourceDic(resDic: [String:Any] , hintDic:[String:Any]) -> [String:Any]{
        var transformDic = resDic
        for (key,value) in hintDic {
            let valueNew: AnyObject = value as AnyObject
            if valueNew.classForCoder == NSDictionary.classForCoder(){      // 模型映射
                let res_value = resDic[key] as AnyObject    // 为了获取数据类型
                if res_value.classForCoder == NSArray.classForCoder(){  // 数据类型为数组（模型数组）
                    let res_value_array = res_value as! [[String:Any]]
                    var resArray: [Any] = []
                    for item in res_value_array {
                        // 递归调用，寻找子模型
                        let res = self.setUpResourceDic(resDic: item , hintDic: valueNew as! [String : Any])
                        resArray.append(res)
                    }
                    let realKey = self.getRealKey(key: key, dic: hintDic)
                    transformDic[realKey] = resArray
                    // 移除旧的数据
                    if realKey != key {
                        transformDic.removeValue(forKey: key)
                    }
                }
                else if res_value.classForCoder == NSDictionary.classForCoder(){    // 数据类型为字典（模型）
                    // 递归调用，寻找子模型
                    let res = self.setUpResourceDic(resDic: res_value as! [String : Any] , hintDic: valueNew as! [String : Any])
                    let realKey = self.getRealKey(key: key, dic: hintDic)
                    transformDic[realKey] = res
                    // 移除旧的数据
                    if realKey != key {
                        transformDic.removeValue(forKey: key)
                    }
                }
            }else if valueNew.classForCoder == NSString.classForCoder(){    // 普通映射
                // 去掉
                if !hintDic.keys.contains(valueNew as! String){
                    transformDic[key] = resDic[valueNew as! String]
                }
                // 移除旧的数据
                if key != valueNew as! String {
                    transformDic.removeValue(forKey: valueNew as! String)
                }
            }
        }
        return transformDic
    }
    
    /// 从映射字典中获取到模型中对应的key
    private static func getRealKey(key:String, dic:[String:Any]) -> String {
        for (k,v) in dic {
            let value: AnyObject = v as AnyObject
            if value.classForCoder == NSString.classForCoder(){
                let valueNew = value as! String
                if valueNew == key{
                    return k
                }
            }
        }
        return key
    }

}


extension NSObject {
    
    /// 数据模型转字典
    /// - Parameter model: 数据模型
    /// - Returns: 字典
    static public func nh_reflectToDict<T>(model: T) -> [String:Any] {
        let mirro = Mirror(reflecting: model)
        var dict = [String:Any]()
        for case let (key?, value) in mirro.children {
            dict[key] = value
        }
        return dict
    }
    
    /// 获取 json 数据，data类型
    static public func getJsonData(param: Any) -> Data? {
        if !JSONSerialization.isValidJSONObject(param) {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: param, options: []) else {
            return nil
        }
        return data
    }
    
    /// 将当前对象转换为字典
    /// - Returns: 字典
    public func nh_toDictionary() -> [String: Any] {
        NSObject.nh_reflectToDict(model: self)
    }

}
