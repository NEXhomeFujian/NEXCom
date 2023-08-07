//
//  NHColor.swift
//  NHFoundation
//
//  Created by 骆亮 on 2021/11/10.
//

import UIKit

// MARK: - 生成颜色
extension UIColor {
    
    /// 通过RGB生成颜色
    /// - Parameters:
    ///   - r: red
    ///   - g: green
    ///   - b: blue
    ///   - a: alpha
    /// - Returns: UIColor
    public class func nh_rgba(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ a:CGFloat) -> UIColor {
        return UIColor.init(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
    }
    
    /// 通过RGB生成颜色
    /// - Parameters:
    ///   - r: red
    ///   - g: green
    ///   - b: blue
    /// - Returns: UIColor
    public class func nh_rgb(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat) -> UIColor {
        return nh_rgba((r), (g), (b), 1)
    }
    
    /// 通过十六进制生成颜色，例如：0xfff000
    /// - Parameter value: 0xfff000
    /// - Returns: UIColor
    public class func nh_hex(_ value:Int) -> UIColor {
        return nh_rgb(CGFloat((value & 0xFF0000) >> 16),
                   CGFloat((value & 0x00FF00) >> 8),
                   CGFloat((value & 0x0000FF)))
    }
    
    /// 生成随机色
    public class var nh_rand: UIColor {
        return nh_rgb(CGFloat(arc4random_uniform(255)), CGFloat(arc4random_uniform(255)), CGFloat(arc4random_uniform(255)))
    }
    
    /// 根据不同模式获取颜色
    /// - Parameters:
    ///   - lightColor: 明亮模式下的颜色
    ///   - darkColor: 暗黑模式下的颜色
    /// - Returns: 颜色
    public class func nh_dynamicColor(with lightColor: UIColor, darkColor: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            let dc = UIColor.init { tr in
                return tr.userInterfaceStyle == .light ? lightColor : darkColor
            }
            return dc
        } else {
            return lightColor
        }
    }
    
}


// MARK: - 处理为图片
extension UIColor {
    
    /// 将当前颜色生成图片， 默认尺寸 (1,1)
    /// - Parameter size: 默认尺寸 (1,1)
    /// - Returns: UIImage?
    public func nh_toImage(_ size: CGSize = .init(width: 1, height: 1)) -> UIImage? {
       var resultImage: UIImage? = nil
       let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
       UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
       guard let context = UIGraphicsGetCurrentContext() else {
           return resultImage
       }
       context.setFillColor(self.cgColor)
       context.fill(rect)
       resultImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return resultImage
   }
    
}




// MARK: - App的颜色标准，项目中可通过扩展方式新增样式
@objc public protocol NHAppColorsInterface {
    /// 当前颜色标准信息，key - value
    func info() -> [String: UIColor]
}
public class NHAppColors: NSObject {
    public override init() {}
}
// MARK: - App颜色
extension UIColor {
    struct AppColorAssociatedKey {
        static var appColor: String = "AppColorAssociatedKey"
    }
    /// app颜色标准，区别于系统颜色
    public static var app: NHAppColors? {
        get {
            if let old = objc_getAssociatedObject(self, &AppColorAssociatedKey.appColor) as? NHAppColors {
                return old
            }
            let new = NHAppColors()
            objc_setAssociatedObject(self, &AppColorAssociatedKey.appColor, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return new
        }
        set {
            objc_setAssociatedObject(self, &AppColorAssociatedKey.appColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
