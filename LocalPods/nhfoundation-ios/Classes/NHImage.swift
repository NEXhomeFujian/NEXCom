//
//  NHImage.swift
//  NHFoundation
//
//  Created by 骆亮 on 2021/11/10.
//

import UIKit
import Luban_iOS
import Photos

// MARK: - 人脸相关的图片处理
extension UIImage {
    
    /// 处理为符合人脸识别规格的图片
    /// - Returns: UIImage?
    public func nh_faceImage() -> UIImage? {
//        var image_t = self.nh_cutImage() ?? UIImage.init()
//        image_t = image_t.nh_compressImage() ?? UIImage.init()
//        return image_t
        let img_t = self.nh_cutImage()
//        print("==1==face image size========", Double(img_t?.pngData()?.count ?? 0))
        if let image_data = UIImage.lubanCompressImage(img_t) {
//            print("==2==face image size========", Double(image_data.count))
            if Double(image_data.count) <= 1000000 {
                return UIImage.init(data: image_data)
            }else{
                //图片大小超过1000k 予以压缩
                var ratio = 1000000.0 / Double(image_data.count)
                ratio = (NSString.init(format: "%.2f", ratio)).doubleValue
                ratio = ratio - 0.01
                ratio = (NSString.init(format: "%.2f", ratio)).doubleValue
                let Data_img:Data = self.jpegData(compressionQuality: CGFloat(ratio)) ?? Data.init()//UIImageJPEGRepresentation(self, CGFloat(ratio))! as NSData
                
                let img_result:UIImage = UIImage.init(data: Data_img)!
                return img_result
            }
        }
        return self.nh_compressImage()
    }
    
    /// 缩小图片
    private func nh_cutImage() -> UIImage? {
        guard let cgImage = self.cgImage ?? self.nh_convertCIImageToCGImage(self.ciImage) else { return nil }
        var fixelW:CGFloat = CGFloat(cgImage.width)
        var fixelH:CGFloat = CGFloat(cgImage.height)
        let max_w = max(fixelW, fixelH)
        if max_w > 960 {
            let ratio =  960 / max_w
            fixelW = fixelW * CGFloat(ratio)
            fixelH = fixelH * CGFloat(ratio)
        }
        let img_t = self.nh_scaleToSize(CGSize.init(width: fixelW, height: fixelH))
        return img_t
    }
    
    /// 压缩图片
    /// - Parameter byte: 字节，默认为 100000.0byte，即100kb
    /// - Returns: UIImage?
    public func nh_compressImage(_ byte: Float? = 100000.0) -> UIImage? {
        var ratio = 1.0
        let tempData:Data = self.pngData() ?? Data.init()
        // 压缩图片在100k以内
        ratio = Double(byte!) / Double(tempData.count)
        if ratio - 1 < 0 {
            ratio = (NSString.init(format: "%.2f", ratio)).doubleValue
            ratio = ratio - 0.01
            ratio = (NSString.init(format: "%.2f", ratio)).doubleValue
        }else{
            ratio = 1.0
        }
        if let data_img:Data = self.jpegData(compressionQuality: CGFloat(ratio)) {
            return UIImage.init(data: data_img)
        }
        return nil
    }
    
    /// 缩放图片，将图片缩放到指定大小
    /// - Parameter size: 缩放尺寸
    /// - Returns: UIImage?
    public func nh_scaleToSize(_ size:CGSize) -> UIImage? {
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size)
        // 绘制改变大小的图片
        self.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        // 从当前context中创建一个改变大小后的图片
        let scaledImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage.init()
        // 使当前的context出堆栈
        UIGraphicsEndImageContext()
        // 返回新的改变大小后的图片
        return scaledImage
    }
   
}


// MARK: - 二维码相关
extension UIImage {
    
    /// 识别图片中的二维码内容，同步，可能会阻碍线程
    /// - Returns: 内容数组
    public func nh_recognitionQRCode() -> [String]? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)
        guard let ciImage = CIImage(image: self) else { return nil }
        guard let features = detector?.features(in: ciImage) else { return nil }
        var resultArr = [String]()
        for feature in features {
            if let f = feature as? CIQRCodeFeature , let messgae = f.messageString {
                resultArr.append(messgae)
            }
        }
        return resultArr
    }
    
    /// 识别图片中的二维码内容，异步
    /// - Parameter result: 内容回调
    public func nh_recognitionQRCode(_ result:@escaping (_ texts: [String]?) -> Void ) {
        DispatchQueue.global().async {
            let list = self.nh_recognitionQRCode()
            DispatchQueue.main.async {
                result(list)
            }
        }
    }
    
    /// 生成二维码图片
    /// - Parameters:
    ///   - string: 二维码内容
    ///   - width: 二维码宽度
    ///   - centerImage: 中心填充图片
    ///   - color: 二维码颜色
    /// - Returns: 二维码图片
    static public func nh_initWithString(_ string: String, width: CGFloat, centerImage:UIImage? = nil, color:UIColor? = .black) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        // 设置生成的二维码的容错率, value = @"L/M/Q/H"
        filter.setValue("H", forKey: "inputCorrectionLevel")
        // 获取生成的二维码
        guard let outPutImage = filter.outputImage else { return nil }
        // 设置二维码颜色
        let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage":outPutImage,"inputColor0":CIColor(cgColor: color?.cgColor ?? UIColor.black.cgColor),"inputColor1":CIColor(cgColor: UIColor.clear.cgColor)])
        // 获取带颜色的二维码
        guard let newOutPutImage = colorFilter?.outputImage else { return nil }
        let scale = width / newOutPutImage.extent.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let output = newOutPutImage.transformed(by: transform)
        let QRCodeImage = UIImage(ciImage: output)
        // 有无中心填充图片
        guard let centerImage = centerImage else { return QRCodeImage }
        let imageSize = QRCodeImage.size
        UIGraphicsBeginImageContext(imageSize)
        QRCodeImage.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let fillRect = CGRect(x: (width - width / 5) / 2, y: (width - width / 5 ) / 2, width: width / 5, height: width / 5)
        centerImage.draw(in: fillRect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return QRCodeImage }
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

// MARK: - 由颜色对象生成图片
extension UIImage {
    
    /// 由颜色生成图片
    /// - Parameters:
    ///   - cr: 颜色
    ///   - size: 图片大小
    /// - Returns: UIImage
    static public func nh_initWithColor(_ cr: UIColor, _ size: CGSize? = .init(width: 1.0, height: 1.0)) -> UIImage {
        let rect = CGRect.init(origin: .zero, size: size!)
        UIGraphicsBeginImageContext(rect.size)
        let content = UIGraphicsGetCurrentContext()
        content?.setFillColor(cr.cgColor)
        content?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage.init()
    }
    
    /// 生成渐变图片
    /// - Parameters:
    ///   - gradientType: 内置的渐变类型
    ///   - fromColor: from color
    ///   - toColor: to color
    ///   - size: 图片尺寸
    /// - Returns: UIImage?
    static public func nh_initWith(_ gradientType: UIView.GradientType, fromColor: UIColor, toColor: UIColor, size: CGSize) -> UIImage? {
        let view = UIView.init(frame: .init(origin: .zero, size: size))
        view.nh_setGradient(with: gradientType, from: fromColor, to: toColor)
        return view.nh_snapshot()
    }
    
}


// MARK: - 将图片进行裁剪
extension UIImage {
    
    /// 按照指定区域裁剪图片，路径的坐标系为图片的坐标系
    /// - Parameter rect: 图片坐标系中的 rect 区域
    /// - Returns: 裁剪后的图片
    public func nh_clip(with rect:CGRect) -> UIImage? {
        return self.nh_clip(with: UIBezierPath.init(rect: rect))
    }
    
    /// 按照指定路径裁剪图片
    /// - Parameter path: 图片中的路径
    /// - Returns: 裁剪后的图片
    public func nh_clip(with path:UIBezierPath) -> UIImage? {
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = self.scale    // 图片的scale，会影响到下面的裁剪完之后的大小
            format.opaque = false  // 透明
            // 这里的 bounds 参数，指定了裁剪的位置和大小
            // 如果这里是size，就需要配合方法来制定开始的绘制位置 self.draw(at: CGPoint.init(x: -rect.origin.x, y: -rect.origin.y))
            let renderer = UIGraphicsImageRenderer.init(bounds: path.bounds, format: format)
            return renderer.image { (context) in
                // 限制区域
                path.addClip()
                // 将图片绘制到当前上下文
                self.draw(at: .zero)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            path.addClip()
            self.draw(at: .zero)
            var image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsBeginImageContextWithOptions(path.bounds.size, false, self.scale)
            image?.draw(at: CGPoint.init(x: -path.bounds.origin.x, y: -path.bounds.origin.y))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    /// 图片镜像翻转
    public enum Mirror : Int {
        /// 横向翻转
        case horizontal
        /// 纵向翻转
        case vertical
    }
    
    /// 翻转图片
    /// - Parameter orientation: 翻转方向
    /// - Returns: 翻转图片
    public func nh_flip(to orientation: Mirror) -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
        context.clip(to: .init(origin: .zero, size: self.size))
        switch orientation {
        case .vertical:
            context.translateBy(x: 0, y: 0)
        default:
            context.rotate(by: CGFloat(Double.pi))
            context.translateBy(x: -self.size.width, y: -self.size.height)
        }
        guard let cgImage = self.cgImage ?? self.nh_convertCIImageToCGImage(self.ciImage) else { return nil }
        context.draw(cgImage, in: CGRect.init(origin: .zero, size: self.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func nh_convertCIImageToCGImage(_ ciImage: CIImage?) -> CGImage? {
        guard let ciImage = ciImage else { return nil }
        let ciContext = CIContext.init()
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
    
}

// MARK: - 图片旋转问题
extension UIImage {
    /// 修复图片旋转
    public func nh_fixOrientation() -> UIImage {
        if self.imageOrientation == .up { return self }
        var transform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        default:
            break
        }
        
        guard let cgImage = self.cgImage ?? self.nh_convertCIImageToCGImage(self.ciImage) else { return self }
        
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(cgImage, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
            
        default:
            ctx?.draw(cgImage, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
        
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
}


// MARK: - 保存到本地
extension UIImage {
    
    /// 保存图片到本地相册 - 请确保有相关权限
    /// - Parameter result: 保存结果
    public func nh_saveToPhotoLibrary(_ result:((Bool, Error?)->Void)?) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: self)
        } completionHandler: { isSucceed, error in
            DispatchQueue.main.async {
                result?(isSucceed, error)
            }
        }
    }
    
    /// 保存图片到本地相册
    /// - Parameters:
    ///   - handler: 是否有权限回调
    ///   - result: 保存结果
    public func nh_saveImage(_ handler:((Bool) -> Void)?, result:((Bool, Error?) -> Void)?) {
        UIApplication.shared.nh_saveImage(self, handler, result: result)
    }
    
}
