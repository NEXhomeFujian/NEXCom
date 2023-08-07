//
//  NHView.swift
//  NHFoundation_Example
//
//  Created by 骆亮 on 2021/11/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

// MARK: - 截图
public extension UIView {
    
    /// 当前视图截图
    /// - Returns: UIImage?
    func nh_snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        guard let currentContentx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: currentContentx)
        let screenShotImage:UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenShotImage
    }
    
}

// MARK: - 渐变色
extension UIView {
    
    /// 内置效果
    public enum GradientType {
        /// ⬇️
        case upToDown
        /// ➡️
        case leftToRight
        /// ↘️
        case leftUpToRightDown
        /// ↗️
        case leftDownToRightUp
        /// ⬇️
        case GT_0111
        /// ➡️
        case GT_1011
        /// ↘️
        case GT_0011
        /// ↗️
        case GT_0110
    }
    
    struct associatedKeys {
        static var gradientKey: String = "gradientAssociatedKey"
    }
    
    /// 绑定一个渐变图层
    private var gradientLayer: CAGradientLayer? {
        get {
            if let old = objc_getAssociatedObject(self, &associatedKeys.gradientKey) as? CAGradientLayer {
                return old
            }
            let new = CAGradientLayer()
            objc_setAssociatedObject(self, &associatedKeys.gradientKey, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return new
        }
        set {
            objc_setAssociatedObject(self, &associatedKeys.gradientKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 给当前视图添加渐变色
    /// - Parameters:
    ///   - type: 内置的类型
    ///   - size: view 宽高大小
    ///   - colors: 颜色数组
    ///   - lcs: 位置，默认为 [0, 1]
    public func nh_setGradient(with type: GradientType, size:CGSize? = nil, cornerRadius: CGFloat? = 0, colors:[CGColor], lcs:[NSNumber]? = [0, 1]) {
        guard let gl = self.gradientLayer else { return }
        let sz = size ?? self.bounds.size
        gl.cornerRadius = cornerRadius ?? 0
        gl.frame = CGRect.init(x: 0, y: 0, width: sz.width, height: sz.height)
        gl.colors = colors
        if type == .leftToRight || type == .GT_0111 { // 左上点为(0,0), 右下点为(1,1)
            gl.startPoint = CGPoint(x: 0, y: 1)
            gl.endPoint =  CGPoint(x: 1, y: 1)
        } else if type == .upToDown || type == .GT_1011 {
            gl.startPoint = CGPoint(x: 1, y: 0)
            gl.endPoint = CGPoint(x: 1, y: 1)
        } else if type == .leftUpToRightDown || type == .GT_0011 {
            gl.startPoint = CGPoint(x: 0, y: 0)
            gl.endPoint = CGPoint(x: 1, y: 1)
        } else if type == .leftDownToRightUp || type == .GT_0110 {
            gl.startPoint = CGPoint(x: 0, y: 1)
            gl.endPoint = CGPoint(x: 1, y: 0)
        }
        gl.locations = lcs
        self.layer.insertSublayer(gl, at: 0)
    }
    
    /// 给当前视图添加渐变色
    /// - Parameters:
    ///   - type: 内置的类型
    ///   - size: view 宽高大小
    ///   - from: from color
    ///   - to: to color
    public func nh_setGradient(with type: GradientType, size:CGSize? = nil, cornerRadius: CGFloat? = 0, from: UIColor, to: UIColor) {
        self.nh_setGradient(with: type, size: size, cornerRadius: cornerRadius, colors: [from.cgColor, to.cgColor])
    }
    
}


// MARK: - 阴影
extension UIView {
    
    /// 给视图添加阴影
    /// - Parameters:
    ///   - shadowColor: 阴影色，默认值为：0.05透明度的black
    ///   - shadowRadius: 圆角，默认值为：4.0
    public func nh_addShadow(_ shadowColor: UIColor=UIColor.black.withAlphaComponent(0.03), _ shadowRadius: CGFloat=4.0) {
        self.nh_addShadow(shadowColor, shadowRadius, 2)
    }
    /// 给视图添加阴影
    /// - Parameters:
    ///   - size: view 宽高
    ///   - shadowColor: 阴影色，默认值为：0.05透明度的black
    ///   - shadowRadius: 圆角，默认值为：4.0
    public func nh_addShadow(_ size:CGSize, _ shadowColor: UIColor=UIColor.black.withAlphaComponent(0.03), _ shadowRadius: CGFloat=4.0) {
        self.nh_addShadow(size, shadowColor, shadowRadius, 2)
    }
    /// 给视图添加阴影
    /// - Parameters:
    ///   - size: view 宽高
    ///   - shadowColor: 阴影色，默认值为：0.05透明度的black
    ///   - shadowRadius: 圆角，默认值为：4.0
    ///   - shadowOffset: 阴影偏移量，默认值为：2.0
    public func nh_addShadow(_ size:CGSize, _ shadowColor: UIColor? = UIColor.black.withAlphaComponent(0.03), _ shadowRadius: CGFloat? = 4.0, _ shadowOffset: CGFloat? = 2) {
        let sz = size
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor?.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: shadowOffset!)
        self.layer.shadowRadius = shadowRadius!
        let shadowSize0:CGFloat = -1
        let shadowSpreadRect0 = CGRect(x: -shadowSize0, y: -shadowSize0, width: sz.width+shadowSize0*2, height: sz.height+shadowSize0*2)
        let shadowSpreadRadius0 = self.layer.cornerRadius == 0 ? 0 : self.layer.cornerRadius+shadowSize0
        let shadowPath0 = UIBezierPath(roundedRect: shadowSpreadRect0, cornerRadius: shadowSpreadRadius0)
        self.layer.shadowPath = shadowPath0.cgPath
    }
    
    /// 给视图添加阴影
    /// - Parameters:
    ///   - size: view 宽高
    ///   - shadowColor: 阴影色，默认值为：0.05透明度的black
    ///   - shadowRadius: 圆角，默认值为：4.0
    ///   - shadowOffset: 阴影偏移量，默认值为：2.0
    public func nh_addShadow(_ shadowColor: UIColor? = UIColor.black.withAlphaComponent(0.03), _ shadowRadius: CGFloat? = 4.0, _ shadowOffset: CGFloat? = 2) {
        let sz = self.layer.bounds.size
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor?.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: shadowOffset!)
        self.layer.shadowRadius = shadowRadius!
        let shadowSize0:CGFloat = -1
        let shadowSpreadRect0 = CGRect(x: -shadowSize0, y: -shadowSize0, width: sz.width+shadowSize0*2, height: sz.height+shadowSize0*2)
        let shadowSpreadRadius0 = self.layer.cornerRadius == 0 ? 0 : self.layer.cornerRadius+shadowSize0
        let shadowPath0 = UIBezierPath(roundedRect: shadowSpreadRect0, cornerRadius: shadowSpreadRadius0)
        self.layer.shadowPath = shadowPath0.cgPath
    }
}


// MARK: - 圆角部分
public extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return self.layer.cornerRadius }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
    }
}


// MARK: - 虚线
extension UIView {
    
    struct dashAssociatedKeys {
        static var dash: String = "dashAssociatedKey"
    }
    
    /// 绑定一个虚线图层
    private var dashLayer: CAShapeLayer? {
        get {
            if let old = objc_getAssociatedObject(self, &dashAssociatedKeys.dash) as? CAShapeLayer {
                return old
            }
            let new = CAShapeLayer()
            objc_setAssociatedObject(self, &dashAssociatedKeys.dash, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return new
        }
        set {
            objc_setAssociatedObject(self, &dashAssociatedKeys.dash, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public enum Direction {
        /// 水平方向
        case horizonal
        /// 垂直方向
        case vertical
    }
    
    /// 给当前视图添加虚线，默认长度：10，间隔：5
    /// - Parameters:
    ///   - strokeColor: 虚线颜色
    ///   - direction: 朝向
    public func nh_setDash(strokeColor: UIColor, direction: Direction = .horizonal) {
        self.nh_setDash(strokeColor: strokeColor, direction: direction, lineLength: 10, lineSpacing: 5)
    }
            
    /// 给当前视图添加虚线，默认长度：10，间隔：5
    /// - Parameters:
    ///   - strokeColor: 虚线颜色
    ///   - direction: 朝向
    ///   - lineLength: 虚线单位宽度
    ///   - lineSpacing: 虚线间隔
    public func nh_setDash(strokeColor: UIColor, direction: Direction = .horizonal, lineLength: Int = 10, lineSpacing: Int = 5) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineJoin = .round
        shapeLayer.lineCap = .round
        if direction == .horizonal {
            shapeLayer.lineWidth = self.bounds.size.height
            shapeLayer.position = .init(x: 0, y: self.bounds.size.height / 2.0)
        } else {
            shapeLayer.lineWidth = self.bounds.size.width
            shapeLayer.position = .init(x: self.bounds.size.width / 2.0, y: 0)
        }
        // 每一段虚线 [长度] 和 [间隔]
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        if direction == .horizonal {
            path.addLine(to: CGPoint(x: self.layer.bounds.size.width, y: 0))
        } else {
            path.addLine(to: CGPoint(x: 0, y: self.layer.bounds.size.height))
        }
        shapeLayer.path = path
        self.dashLayer?.removeFromSuperlayer()
        self.dashLayer = shapeLayer
        self.layer.addSublayer(shapeLayer)
    }
    
}
