//
//  StylesHelper.swift
//  ZappApple
//
//  Created by Anton Kononenko on 12/9/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import UIKit
import ZappCore

var ZappStyles:[AnyHashable:Any]? = StylesHelper.retriveStyles()

class StylesHelper {
    struct StylesHelperApi {
        static let universal = "universal"
        struct UniversalKey {
            static let color = "color"
            static let font = "font"
            static let fontSize = "font_size"
        }
    }
    
    class var deviceType: String {
        var retValue = UIDevice.current.model.lowercased()
        #if os(tvOS)
            retValue = "apple_tv"
        #endif
        return retValue
    }

    public class func retriveStyles() -> [AnyHashable:Any]? {
        let file = LoadingManager().file(type: .styles)
        var url = file?.localURLPath()
        if file?.isInLocalStorage() == false,
            let zappStylesPath = DataManager.zappStylesPath() {
            url = URL(fileURLWithPath:zappStylesPath)
        }
        if let url = url {
            do {
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    return jsonResult
                }
            } catch {
            }
        }
        return nil
    }
    
    public class func updateZappStyles() {
        ZappStyles = retriveStyles()
    }
    
    public class func style(forKey key: String) -> [String:String]? {
        var styleDict:[String:String]?
        if let universalDict = ZappStyles?[StylesHelperApi.universal] as? [String:[String:String]],
            let value = universalDict[key] {
            styleDict = value
        }
        else if let deviceTypeDict = ZappStyles?[deviceType] as? [String:[String:String]],
            let value = deviceTypeDict[key] {
            styleDict = value
        }
        return styleDict
    }
    
    public class func color(forKey key:String) -> UIColor? {
        guard let stylesDict = style(forKey: key),
            let colorKey = stylesDict[StylesHelperApi.UniversalKey.color] else {
            return nil
        }
        return UIColor(ARGBHex: colorKey)
    }
    
    public class func updateLabel(forKey key:String, label:UILabel?) {
        guard let label = label else {
            return
        }
        
        let labelStyles = StylesHelper.label(forKey: key)
        
        if let color = labelStyles.color {
            label.textColor = color
        }
        
        if let font = labelStyles.font {
            label.font = font
        }
    }
    
    public class func label(forKey key:String) -> (color:UIColor?, font:UIFont?) {
        var retVal:(color:UIColor?, font:UIFont?) = (nil, nil)
        
        guard let stylesDict = style(forKey: key) else {
            return retVal
        }
        
        if let color = color(forKey: key) {
            retVal.color = color
        }
        
        if let fontSizeString = stylesDict[StylesHelperApi.UniversalKey.fontSize] {
            let fontSize = CGFloat((fontSizeString as NSString).floatValue)
            if let fontName = stylesDict[StylesHelperApi.UniversalKey.font],
                let font = UIFont(name: fontName,
                                  size: fontSize) {
                retVal.font = font
            } else {
                retVal.font = UIFont.systemFont(ofSize: fontSize)
            }
        }
        
        
        return retVal
    }
}
