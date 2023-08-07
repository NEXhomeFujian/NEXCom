//
//  NHDate.swift
//  NHFoundation
//
//  Created by 骆亮 on 2022/12/28.
//

import UIKit
import Foundation

public class NHDate: NSObject { }

public var nhDateFormatter: DateFormatter = {
    let formatter: DateFormatter = .init()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()


extension NHDate {
    
    /// 当前时间戳
    /// - Returns: 时间戳
    public class func nh_timeStamp() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    /// 今日凌晨0点的时间戳
    /// - Returns: 时间戳
    public class func nh_todayDawnTimeStamp() -> TimeInterval? {
        return self.nh_dawnTimeStampFrom(Date())
    }

    /// 指定日期的凌晨0点的时间戳
    /// - Parameter date: 日期
    /// - Returns: 时间戳
    public class func nh_dawnTimeStampFrom(_ date: Date) -> TimeInterval? {
        let comps: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let year = comps.year, let month = comps.month, let day = comps.day else { return nil }
        nhDateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = "\(year)" + "-" + "\(month)" + "-" + "\(day)"
        guard let dateDawn = self.nh_dateFrom(dateString) else { return nil }
        return dateDawn.timeIntervalSince1970
    }

    /// 日期字符串转换为Date
    /// - Parameters:
    ///   - dateString: 日期字符串
    ///   - format: 日期formatter
    /// - Returns: Date?
    public class func nh_dateFrom(_ dateString: String, format: String? = "yyyy-MM-dd") -> Date? {
        if let ft = format {
            nhDateFormatter.dateFormat = ft
        }
        let date = nhDateFormatter.date(from: dateString)
        return date
    }

    /// 时间戳转换为Date
    /// - Parameter timeStamp: 时间戳
    /// - Returns: Date?
    public class func nh_dateFrom(_ timeStamp: TimeInterval?) -> Date? {
        guard let ts = timeStamp else { return nil }
        guard let time = TimeInterval("\(ts)".prefix(10)) else { return nil }
        return Date.init(timeIntervalSince1970: time)
    }
    
}

