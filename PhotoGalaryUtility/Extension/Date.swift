//
//  Date.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import Foundation

extension Date {
    init(string: String) {
        let formatter = Date.formatter()
        if let date = formatter.date(from: string) {
            self = date

        } else {
            let formatter2 = Date.formatter(dateSeparetor: ":")
            if let date = formatter2.date(from: string) {
                self = date
            } else {
                let formatter3 = Date.formatter(dateSeparetor: ":", short: true)
                if let date = formatter3.date(from: string) ?? Date.formatter(dateSeparetor: "-", short: true).date(from: string) {
                    self = date
                } else {
                    if #available(iOS 15, *) {
                        self = .now
                    } else {
                        self = .init()
                    }
                }
            }
            
        }
    }
    
    var string: String {
        if #available(iOS 16.0, *) {
            return self.ISO8601Format(.iso8601(timeZone: .current, includingFractionalSeconds: true, dateSeparator: .dash, dateTimeSeparator: .space, timeSeparator: .colon))
        } else {
            if #available(iOS 15.0, *) {
                return self.ISO8601Format()
            } else {
                return ""
            }
        }
    }
    
    fileprivate static func formatter(dateSeparetor: String = "-", short: Bool = false) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy\(dateSeparetor)MM\(dateSeparetor)dd" + (short ? "" : " HH:mm:ss")
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}

extension DateComponents {
    init(string: String) {
        self = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date(string: string))
    }
    
    var stringMonthes: [Int: String] {
        [
            1: "January",
            2: "February",
            3: "March",
            4: "April",
            5: "May",
            6: "June",
            7: "July",
            8: "August",
            9: "September",
            10: "October",
            11: "November",
            12: "December"
        ]
    }
    
    var stringMonthesShort: [Int: String] {
        [
            1: "Jan",
            2: "Feb",
            3: "Mar",
            4: "Apr",
            5: "May",
            6: "June",
            7: "Jul",
            8: "Aug",
            9: "Sept",
            10: "Oct",
            11: "Nov",
            12: "Dec"
        ]
    }
    
    var stringDate: String {
        "\(stringMonthesShort[month ?? 0] ?? "") \(day ?? 0) , \(year ?? 0)"
    }
    
    var stringTime: String {
        "\(hour ?? 0): \(minute ?? 0)"
    }
}
