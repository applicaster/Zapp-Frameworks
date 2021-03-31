//
//  RTLLocales.swift
//  AppCenter-AppCenterDistributeResources
//
//  Created by François Roland on 23/09/2020.
//

import Foundation

public enum RTLLocales:String, CaseIterable {
    case ARABIC = "ar"
    case ARAMAIC = "arc"
    case DIVEHI = "dv"
    case FARSI = "fa"
    case HAUSA = "ha"
    case HEBREW = "he"
    case KHOWAR = "khw"
    case KASHMIRI = "ks"
    case KURDISH = "ku"
    case PASHTO = "ps"
    case URDU = "ur"
    case YIDDISH = "yi"
    
    private static func allStringValues() -> [String] {
        return RTLLocales.allCases.map { $0.rawValue }
    }
    
    public static func includes(locale: String) -> Bool {
        return allStringValues().contains(locale)
    }
}
