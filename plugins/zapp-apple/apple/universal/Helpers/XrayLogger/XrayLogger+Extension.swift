//
//  Logger Extensions.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

extension Logger {
    public func verboseLog(template: LogTemplate,
                           data: [String: Any]? = nil,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           args: [CVarArg] = []) {
        verboseLog(message: template.message, category: template.category, data: data, file: file, function: function, line: line, args: args)
    }

    public func debugLog(template: LogTemplate,
                         data: [String: Any]? = nil,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line,
                         args: [CVarArg] = []) {
        debugLog(message: template.message, category: template.category, data: data, file: file, function: function, line: line, args: args)
    }

    public func infoLog(template: LogTemplate,
                        data: [String: Any]? = nil,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line,
                        args: [CVarArg] = []) {
        infoLog(message: template.message, category: template.category, data: data, file: file, function: function, line: line, args: args)
    }

    public func warningLog(template: LogTemplate,
                           data: [String: Any]? = nil,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           args: [CVarArg] = []) {
        warningLog(message: template.message, category: template.category, data: data, file: file, function: function, line: line, args: args)
    }

    public func errorLog(template: LogTemplate,
                         data: [String: Any]? = nil,
                         exception: NSException? = nil,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line,
                         args: [CVarArg] = []) {
        errorLog(message: template.message, category: template.category, data: data, exception: exception, file: file, function: function, line: line, args: args)
    }
}
