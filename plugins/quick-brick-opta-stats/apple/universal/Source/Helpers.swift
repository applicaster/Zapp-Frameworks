//
//  Helpers.swift
//  OptaStats
//
//  Created by Jesus De Meyer on 3/7/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation

class Helpers {
    static var tournamentFinished: Bool = false
    static var showTeam: Bool = false
    static var forceNumberOfMatches = 3

    static var shortDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'Z'"
        df.locale = Locale(identifier: "en-US")
        df.timeZone = TimeZone(abbreviation: "GMT")
        return df
    }()

    static var longDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        df.locale = Locale(identifier: "en-US")
        df.timeZone = TimeZone(abbreviation: "GMT")
        return df
    }()

    static var birthdayDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en-US")
        return df
    }()

    static func shortDate(from dateString: String) -> Date? {
        return shortDateFormatter.date(from: dateString)
    }

    static func longDate(from dateString: String) -> Date? {
        return longDateFormatter.date(from: dateString)
    }

    static func birthdayDate(from dateString: String) -> Date? {
        return birthdayDateFormatter.date(from: dateString)
    }

    static func dateAndTime(_ date: String?, time: String?) -> Date? {
        guard let dateString = date else {
            return nil
        }

        if let timeString = time {
            var cleanDateString = dateString.replace("Z", withString: "T")
            cleanDateString += timeString

            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            df.locale = Locale(identifier: "en-US")
            df.timeZone = TimeZone(abbreviation: "GMT")

            return df.date(from: cleanDateString)
        } else {
            return shortDateFormatter.date(from: dateString)
        }
    }

    static func boolFromString(_ string: String) -> Bool? {
        let cleanString = string.lowercased()

        switch cleanString {
        case "true", "t", "yes", "1":
            return true
        case "false", "f", "no", "0":
            return false
        default:
            return nil
        }
    }

    static func sanatizeID(_ id: String, fromPush: Bool) -> String {
        var cleanID = id

        if fromPush {
            cleanID = id.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
            cleanID = "urn:perform:opta:fixture:\(cleanID)"
        }

        return cleanID
    }

    // MATCH: -

    static func isDateToday(_ date: Date) -> Bool {
        let today = Date()

        var calendar = Calendar(identifier: .gregorian)
        if let timeZone = TimeZone(abbreviation: "GMT") {
            calendar.timeZone = timeZone
        }
        calendar.locale = Locale(identifier: "en-US")

        let dateComps = calendar.dateComponents([.year, .day, .month], from: date)

        let todayComps = Calendar(identifier: .gregorian).dateComponents([.year, .day, .month], from: today)

        if let year = todayComps.year, let day = todayComps.day, let month = todayComps.month, let dateYear = dateComps.year, let dateDay = dateComps.day, let dateMonth = dateComps.month, day == dateDay && month == dateMonth && year == dateYear {
            return true
        }

        return false
    }
}
