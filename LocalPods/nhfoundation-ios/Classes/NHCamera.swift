//
//  NHCamera.swift
//  zhenro-iOS
//
//  Created by 骆亮 on 2022/2/25.
//  Copyright © 2022 NexHome. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

@objc public protocol NHCameraDelegete: NSObjectProtocol   {
    /// 呈现到某视图上
    func cameraOnPreview(_ camera: NHCamera) -> UIView
    /// 得到图片
    func camera(_ camera: NHCamera, capture image: UIImage?, originalImage: UIImage?)
    /// 相机权限
    @objc optional func camera(_ camera: NHCamera, authorizationStatus: AVAuthorizationStatus)
}

public protocol NHCameraInterface {
    /// 开始
    func startRunning()
    /// 停止
    func stopRunning()
    /// 捕获照片
    func capture()
    /// 设置镜头
    func setCaptureDevice(position: AVCaptureDevice.Position)
    /// 切换镜头
    func changeCaptureDevice()
}

public class NHCamera: NSObject, NHCameraInterface {
    /// 当前镜头
    public var position: AVCaptureDevice.Position {
        return self.device?.position ?? .front
    }
    /// 获取设备：如摄像头
    private var device: AVCaptureDevice?
    /// 会话，协调着input到output的数据传输，input和output的桥梁
    public var captureSession: AVCaptureSession! = AVCaptureSession()
    /// 图像预览层，实时显示捕获的图像
    public var previewLayer: AVCaptureVideoPreviewLayer!
    /// 图像流输入
    private var input: AVCaptureInput?
    /// 图像流输出
    private var output: AVCaptureVideoDataOutput!
    /// 链接
    private var captureConnection: AVCaptureConnection?
    /// 相机开始拍照
    private var takePicture:Bool = false
    /// 代理
    private weak var delegate: NHCameraDelegete?
    
    public init(with delegate: NHCameraDelegete) {
        super.init()
        self.delegate = delegate
        DispatchQueue.main.async {
            // 获取输入设备
            self.device = self.getCamera(.front)
            self.setup()
        }
    }
    
    func setup() {
        guard self.device != nil else {
            print("无法获取当前设备的前置摄像头")
            return
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.captureSession.sessionPreset = .high
        } else {
            self.captureSession.sessionPreset = .photo
        }
        // 配置 session
        self.captureSession.beginConfiguration()
        // 设置摄像头作为session的输入流
        if let input = try? AVCaptureDeviceInput.init(device: self.device!), self.captureSession.canAddInput(input) {
            self.input = input
            self.captureSession.addInput(input)
        } else {
            print("设置输入流发生错误")
        }
        // 设置镜头预览层
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
        self.previewLayer.videoGravity = .resizeAspectFill
        let sessionView:UIView? = self.delegate?.cameraOnPreview(self)
        sessionView?.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = sessionView?.bounds ?? .zero
        // 设置输出流
        self.output = AVCaptureVideoDataOutput()
        self.output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : kCVPixelFormatType_32BGRA]
        // 是否直接丢弃处理旧帧时捕获的新帧,默认为True,如果改为false会大幅提高内存使用
        self.output.alwaysDiscardsLateVideoFrames = true
        if self.captureSession.canAddOutput(self.output) {
            self.captureSession.addOutput(self.output)
        }
        self.captureSession.commitConfiguration()
        // 开启新线程进行输出流代理方法的调用
        let queue = DispatchQueue.init(label: "com.nh.captureQueue")
        self.output.setSampleBufferDelegate(self, queue: queue)
        
        self.captureConnection = self.output.connection(with: .video)
        if (self.captureConnection?.isVideoOrientationSupported ?? false) == true {
            // 防止拍照完成，图片旋转90度
            self.captureConnection?.videoOrientation = self.getCaptureVideoOrientation()
        }
    }
    
    public func startRunning() {
        guard self.canUseCamera() else {
            print("无法访问相机权限")
            return
        }
        self.takePicture = false
        self.captureSession.startRunning()
    }
    
    public func stopRunning() {
        self.captureSession.stopRunning()
    }
    
    public func capture() {
        self.takePicture = true
    }
    
    public func setCaptureDevice(position: AVCaptureDevice.Position) {
        self.device = self.getCamera(position)
        guard self.device != nil else {
            print("无法获取当前设备的前置摄像头")
            return
        }
        if let input = self.input {
            self.captureSession.removeInput(input)
        }
        if let out = self.output {
            self.captureSession.removeOutput(out)
        }
        self.setup()
        
    }
    
    public func changeCaptureDevice() {
        guard let dev = self.device else { return }
        self.setCaptureDevice(position: dev.position == .front ? .back : .front)
    }
    
    private func getCamera(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            let availbleDevices = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
             return availbleDevices.first
        } else {
            let devices = AVCaptureDevice.devices(for: .video)
            guard devices.count > 0 else { return nil }
            return devices.filter({ dev in
                return dev.position == position
            }).first
        }
    }
    
    private func canUseCamera() -> Bool {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        self.delegate?.camera?(self, authorizationStatus: authStatus)
        if authStatus == .denied {
            return false
        }
        return true
    }
    
    /// 旋转方向
    private func getCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait, .faceUp, .faceDown:
            return .portrait
        case .portraitUpsideDown: // 如果这里设置成AVCaptureVideoOrientationPortraitUpsideDown,则视频方向和拍摄时的方向是相反的。
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
}


extension NHCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard self.takePicture else {
            return
        }
        DispatchQueue.main.async {
            self.stopRunning()
            let originalImage:UIImage? = self.imageConvert(sampleBuffer: sampleBuffer)
            var cutImage:UIImage? = nil
            // FIXME: 这里切图算法有问题
//            if let sessionView:UIView = self.delegate?.cameraOnPreview(self), let img: UIImage = originalImage {
//                let w_v = sessionView.bounds.size.width
//                let h_v = sessionView.bounds.size.height
//                let w_i = img.size.width
//                let h_i = img.size.height
//                let h_new = w_i * h_v / w_v;
//                let y = abs(h_i - h_new) / 2.0
//                let frame: CGRect = .init(x: 0, y: y, width: w_i, height: h_new)
//                cutImage = originalImage?.nh_clip(with: frame)
//            }
            // 回调图片
            self.delegate?.camera(self, capture: cutImage, originalImage: originalImage)
        }
    }
    
    /// CMSampleBufferRef => UIImage
    private func imageConvert(sampleBuffer:CMSampleBuffer?) -> UIImage? {
        guard let sampleBuffer = sampleBuffer, CMSampleBufferIsValid(sampleBuffer) else { return nil }
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage.init(cvPixelBuffer: pixelBuffer)
            return UIImage.init(ciImage: ciImage)
        }
        return nil
    }
    
}
