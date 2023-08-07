//
//  NSLanguageManager.swift
//  NextSmart
//
//  Created by csh on 2023/4/4.
//

import UIKit


class NSLanguageManager: NSObject {

    /*
     0:跟随系统
     1：英文
     2：中文
     */
    fileprivate static let kChooseLanguageKey = "language"
    /// 单例
    static let shared = NSLanguageManager()

    var language: Language
    private override init() {
        // 第一次初始语言, 看手机是什么语言
        self.language = NSLanguageManager.currentLanguage()
        print("current language:\(self.language.rawValue)")
        super.init()
    }
    enum Language: String {
        /// 请注意, 这个命名不是随意的, 是根据你本地的语言包,可以show in finder 看到. en.lproj / zh-Hans.lproj
        case Chinese = "zh-Hans"
        case English = "en"
        case HK = "zh-Hant"
        case System = "system"
        var code: String {
            switch self {
            case .System:
                let current = localtype()
                if current == "cn" {
                    return Language.Chinese.rawValue
                } else if current == "zh-tw" {
                    return Language.HK.rawValue
                }
                return Language.English.rawValue
            default:
                return rawValue
            }
        }
       
    }
    /// 判断手机语言
    static func localtype() -> String {
        let preferredLang = Locale.preferredLanguages.first! as String
        if preferredLang.contains("Hans") {
            return "cn"
        } else if preferredLang.contains("Hant") {
            return "zh-tw"
        } else {
            return "en"
        }
    }

    /// 保存所选的语言
    static func saveLanguage(chooseLanguage:Language) {
        var language: String = "0"
        if chooseLanguage == .English {
            language = "1"
        } else if chooseLanguage == .Chinese {
            language = "2"
        }
        UserDefaults.standard.set(language, forKey: kChooseLanguageKey)
        UserDefaults.standard.synchronize()
    }
    
    /// 获取上次保存的语言
    static func currentLanguage() -> Language {
        let langString = UserDefaults.standard.string(forKey: kChooseLanguageKey)
        if langString == "1" { // 英文
            return .English
        } else if langString == "2" { // 中文
            return .Chinese
        } else { // 跟随系统, 繁体/简体-> 简体, 其他-> 英文
            let current = localtype()
            if current == "cn" {
                return .Chinese
            } else if current == "zh-tw" {
                return .HK
            }
            return .English
        }
    }

}


private var bundleByLanguageCode: [String: Foundation.Bundle] = [:]
extension NSLanguageManager.Language {
    var bundle: Foundation.Bundle? {
        /// 存起来, 避免一直创建
        if let bundle = bundleByLanguageCode[code] {
            return bundle
        } else {
            let mainBundle = Foundation.Bundle.main
            if let path = mainBundle.path(forResource: code, ofType: "lproj"),
               let bundle = Foundation.Bundle(path: path) {
                bundleByLanguageCode[code] = bundle
                return bundle
            } else {
                return nil
            }
        }
    }
}

/// 首先, 我们会在启动时设置成我们自己的Bundle,这样就可以做到,当使用时会调用这个方法.
class NSBundle: Foundation.Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = NSLanguageManager.shared.language.bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}

