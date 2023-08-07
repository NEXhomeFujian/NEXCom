//
//  NHLocationManager.swift
//  zhenro-iOS
//
//  Created by 骆亮 on 2021/11/26.
//  Copyright © 2021 NexHome. All rights reserved.
//
/*
 to do
 */

import UIKit
import CoreLocation

public class NHLocationManager: NSObject, CLLocationManagerDelegate {
    
    /// 当前定位权限
    public var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    /// 权限变化回调
    public var authorizationDidChange:((_ status: CLAuthorizationStatus) -> Void)?
    
    /// 定位结果回调
    public var location:((CLLocationCoordinate2D?)->Void)?
    
    /// 实例
    static public var shared: NHLocationManager = NHLocationManager()
    
    /// 是否已选择定位权限
    private var notDetermined: Bool = true
    
    internal lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = 10
        manager.distanceFilter = 10
        return manager
    }()
    
    public enum NHLocationType: Int {
        /// 一次定位
        case onceTime = 0
        /// app使用时
        case whenInUse = 1
        /// 一直可用
        case always = 2
    }
    
    private var type: NHLocationType = .onceTime
    
    /// 开始定位，一次定位
    /// - Returns: 当前用户是否允许定位/是否开启服务
    public func startLocation() -> Bool {
        return self.startLocation(.onceTime)
    }
    
    /// 开始定位
    /// - Parameter type: 需要的定位方式
    /// - Returns: 当前用户是否允许定位/是否开启服务
    public func startLocation(_ type: NHLocationType) -> Bool {
        self.type = type
        let auth = UIApplication.shared.nh_checkAuthorization(.location)
        if auth == .denied || auth == .servicesUnabled {
            print("用于拒绝定位或当前手机未开启定位服务")
            return false
        }
        // 用户已经同意
        if auth == .authorized {
            self.locationManager.startUpdatingLocation()
            return true
        }
        self.notDetermined = true
        // 用户未决定
        switch type {
        case .onceTime: // 一次
            self.locationManager.requestWhenInUseAuthorization()
            break
        case .whenInUse: // app使用时候
            self.locationManager.requestWhenInUseAuthorization()
            break
        case .always: // 一直可用
            self.locationManager.requestAlwaysAuthorization()
            break
        }
        return true
    }
    
    // iOS 4.2+
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() != .notDetermined ||
            CLLocationManager.authorizationStatus() != .denied ||
            CLLocationManager.authorizationStatus() != .restricted
        {
            self.locationManager.startUpdatingLocation()
        }
        self.notDetermined = false
        self.authorizationDidChange?(CLLocationManager.authorizationStatus())
    }
    
    // iOS 14.0+
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if CLLocationManager.authorizationStatus() != .notDetermined ||
            CLLocationManager.authorizationStatus() != .denied ||
            CLLocationManager.authorizationStatus() != .restricted
        {
            self.locationManager.startUpdatingLocation()
        }
        self.notDetermined = false
        self.authorizationDidChange?(CLLocationManager.authorizationStatus())
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lc = locations.first
        if let coordinate = lc?.coordinate {
            self.location?(coordinate) // 回调数据
            switch type {
            case .onceTime: // 一次
                self.locationManager.stopUpdatingLocation()
                break
            case .whenInUse, .always:
                break
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if self.notDetermined == false {
            print("locate action did fail: \(error.localizedDescription)")
            self.location?(nil)
        }
    }
    
    
}

// MARK: - 功能扩展
extension NHLocationManager {
    
    public class NHPlaceMark {
        /// 国家
        public var country: String?
        /// 省份
        public var province: String?
        /// 城市
        public var city: String?
        /// 区域
        public var district: String?
        init(country: String? = nil, province: String? = nil, city: String? = nil, district: String? = nil) {
            self.country = country
            self.province = province
            self.city = city
            self.district = district
        }
    }
    
    public typealias NHGeocodeCompletionHandler = (NHPlaceMark?, CLPlacemark?, Error?) -> Void
    
    /// 地理反解析
    /// - Parameters:
    ///   - location: 地理坐标
    ///   - completionHandler: 完成回调
    public func reverseGeocodeLocation(_ location: CLLocationCoordinate2D, completionHandler: NHGeocodeCompletionHandler? = nil) {
        let loc = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
        let geocoder = CLGeocoder.init()
        geocoder.reverseGeocodeLocation(loc) { (placemarks, error) in
            var place: NHPlaceMark?
            if let placemark = placemarks?.first {
                place = NHPlaceMark.init()
                place?.country = placemark.country
                place?.province = placemark.administrativeArea
                place?.city = placemark.locality
                place?.district = placemark.subLocality
            }
            DispatchQueue.main.async {
                completionHandler?(place, placemarks?.first, error)
            }
        }
    }
    
}
