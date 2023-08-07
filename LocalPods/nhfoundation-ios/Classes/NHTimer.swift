//
//  NHTimer.swift
//  zhenro-iOS
//
//  Created by 骆亮 on 2022/1/12.
//  Copyright © 2022 NexHome. All rights reserved.
//

import Foundation

/// NHTimer的功能接口
public protocol NHTimerInterface: NSObjectProtocol {
    /// 开始
    func start()
    /// 暂停
    func pause()
    /// 恢复
    func resume()
    /// 指定时间后恢复
    func resumeAfter(time: TimeInterval)
    /// 重启
    func restart()
    /// 关闭，此时会注销定时器，无法resume只能restart
    func shutDown()
}

/// 定时器处理对象，以转移NSTimer的引用对象
public class NHTimerHandler: NSObject {
    var doBlock:(()->Void)?
    public convenience init(_ block:@escaping (()->Void)) {
        self.init()
        self.doBlock = block
    }
    @objc public func doSomething() {
        self.doBlock?()
    }
    deinit {
        #if DEBUG
        print("\(self.classForCoder) 释放")
        #endif
    }
}

/// NHTimer定时器，可直接被self使用
public class NHTimer: NSObject, NHTimerInterface {
    
    var timer:Timer?
    var timeInterval: TimeInterval = 0
    weak var target: AnyObject!
    var selector: Selector!
    var userInfo: Any?
    var handler: NHTimerHandler!
    
    var repeats: Bool = false
    var block:(()->Void)?
    
    public convenience init(timeInterval:TimeInterval, target: AnyObject, selector:Selector, userInfo: Any? = nil) {
        self.init()
        self.timeInterval = timeInterval
        self.target = target
        self.selector = selector
        self.userInfo = userInfo
        // 事件处理
        self.handler = .init({ [weak self] in
            guard let `self` = self else { return }
            let tar = self.target
            let sel = self.selector
            let info = self.userInfo
            if let `tar` = tar, tar.responds(to: sel) {
                _ = tar.perform(sel, with: info)
            }
        })
        self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self.handler!, selector: #selector(self.handler!.doSomething), userInfo: nil, repeats: true)
    }
    
    @available(iOS 10.0, *)
    public convenience init(timeInterval:TimeInterval, repeats:Bool, _ block:@escaping (()->Void)) {
        self.init()
        self.timeInterval = timeInterval
        self.repeats = repeats
        self.block = block
        self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: repeats, block: { t in
            block()
        })
    }
    
    public func start() {
        guard self.timer?.isValid ?? false else { return }
        self.resumeAfter(time: self.timeInterval)
    }
    
    public func pause() {
        guard self.timer?.isValid ?? false else { return }
        self.timer?.fireDate = .distantFuture
    }
    
    public func resume() {
        guard self.timer?.isValid ?? false else { return }
        self.timer?.fireDate = Date()
    }
    
    public func resumeAfter(time: TimeInterval) {
        guard self.timer?.isValid ?? false else { return }
        self.timer?.fireDate = Date.init(timeIntervalSinceNow: time)
    }
    
    public func restart() {
        self.shutDown()
        if let _ = self.target, let _ = self.selector {
            self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self.handler!, selector: #selector(self.handler!.doSomething), userInfo: nil, repeats: true)
        } else {
            if #available(iOS 10.0, *) {
                self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: repeats, block: { [weak self] t in
                    guard let `self` = self else { return }
                    self.block?()
                })
            }
        }
    }
    
    public func shutDown() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    deinit {
        #if DEBUG
        print("\(self.classForCoder) 释放")
        #endif
    }
    
}
