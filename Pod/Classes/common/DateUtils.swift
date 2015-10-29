//
//  DateUtils.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/6.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import Foundation

class DateUtils {
    
    /**
    显示友好事件
    
    - parameter dateTime: “yyyy-MM-dd HH:mm:ss”时间
    
    - returns:
    */
    class func friendlyTime(dateTime: String) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
        if let date = dateFormatter.dateFromString(dateTime) {
            let delta = NSDate().timeIntervalSinceDate(date)
            
            if (delta <= 0) {
                return "刚刚"
            }
            else if (delta < 60) {
                return "\(Int(delta))秒前"
            }
            else if (delta < 3600) {
                return "\(Int(delta / 60))分钟前"
            }
            else {
                let calendar = NSCalendar.currentCalendar()
                let unitFlags: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute]
                let comp = calendar.components(unitFlags, fromDate: NSDate())
                let currentYear = String(comp.year)
                let currentDay = String(comp.day)
                
                let comp2 = calendar.components(unitFlags, fromDate: date)
                let year = String(comp2.year)
                let month = String(comp2.month)
                let day = String(comp2.day)
                var hour = String(comp2.hour)
                var minute = String(comp2.minute)
                
                if comp2.hour < 10 {
                    hour = "0" + hour
                }
                if comp2.minute < 10 {
                    minute = "0" + minute
                }
                
                if currentYear == year {
                    if currentDay == day {
                        return "今天 \(hour):\(minute)"
                    } else {
                        return "\(month)月\(day)日 \(hour):\(minute)"
                    }
                } else {
                    return "\(year)年\(month)月\(day)日 \(hour):\(minute)"
                }
            }
        }
        return ""
    }
    
    /**
    显示友好事件，用于聊天
    
    - parameter dateTime: “yyyy-MM-dd HH:mm:ss”时间
    
    - returns:
    */
    class func friendlyTimeForChat(dateTime: NSDate?) -> String {
        
        if let date = dateTime {
//            let delta = NSDate().timeIntervalSinceDate(date)
            
            let calendar = NSCalendar.currentCalendar()
            let unitFlags: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute]
            let comp = calendar.components(unitFlags, fromDate: NSDate())
            let currentYear = String(comp.year)
            let currentDay = String(comp.day)
            
            let comp2 = calendar.components(unitFlags, fromDate: date)
            let year = String(comp2.year)
            let month = String(comp2.month)
            let day = String(comp2.day)
            var hour = String(comp2.hour)
            var minute = String(comp2.minute)
            
            if comp2.hour < 10 {
                hour = "0" + hour
            }
            if comp2.minute < 10 {
                minute = "0" + minute
            }
            
            if currentYear == year {
                if currentDay == day {
                    return "今天 \(hour):\(minute)"
                } else {
                    return "\(month)月\(day)日 \(hour):\(minute)"
                }
            } else {
                return "\(year)年\(month)月\(day)日 \(hour):\(minute)"
            }
        }
        return ""
    }
}

