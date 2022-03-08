//
//  Helper.swift
//  slnovaios
//
//  Created by Jcwang on 2022/1/22.
//

import Foundation

extension String {
    // MARK: 字符串转字典
    func stringValueDic() -> [String : Any]? {
        let data = self.data(using: String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!,
                        options: .mutableContainers) as? [String : Any] {
            return dict
        }

        return nil
    }
}

class Helper {
    static func getCurrentTime() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"// 自定义时间格式
        // GMT时间 转字符串，直接是系统当前时间
        
        return dateformatter.string(from: Date())
    }
    
    static func getAllSeconds(time: String) -> Int {
        let yearStr = time[time.index(time.startIndex, offsetBy: 0)..<time.index(time.startIndex, offsetBy: 4)]
        let monthStr = time[time.index(time.startIndex, offsetBy: 5)..<time.index(time.startIndex, offsetBy: 7)]
        let dayStr = time[time.index(time.startIndex, offsetBy: 8)..<time.index(time.startIndex, offsetBy: 10)]
        
        let hourStr = time[time.index(time.startIndex, offsetBy: 11)..<time.index(time.startIndex, offsetBy: 13)]
        let minuteStr = time[time.index(time.startIndex, offsetBy: 14)..<time.index(time.startIndex, offsetBy: 16)]
        let secondStr = time[time.index(time.startIndex, offsetBy: 17)..<time.index(time.startIndex, offsetBy: 19)]
        
        let year = Int(yearStr)!
        let month = Int(monthStr)!
        var day = Int(dayStr)!
        
        let hour = Int(hourStr)!
        let minute = Int(minuteStr)!
        let second = Int(secondStr)!
        
        for i in 2000..<year {
            if ((i % 4 == 0 && i % 100 != 0) || i % 400 == 0) {
                day += 366
            } else {
                day += 365
            }
        }
        
        let monthDays = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        for i in 1..<month {
            day += monthDays[i]
        }
        if (month > 2 && ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)) {
            day += 1;
        }
        day -= 1; // 当天的时间我在下面的时分秒中计算
        
        return day * 24 * 60 * 60 + hour * 60 * 60 + minute * 60 + second
    }
}
