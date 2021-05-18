//
//  DateFormatter+Extras.swift
//  OptaStats
//
//  Created by Alex Zchut on 29/04/2021.
//

import Foundation

extension DateFormatter {
    static func create(with dateFormat: String, locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = dateFormat
        return formatter
    }
}
