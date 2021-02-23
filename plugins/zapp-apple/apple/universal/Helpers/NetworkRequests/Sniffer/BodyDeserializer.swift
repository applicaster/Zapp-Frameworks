//
//  BodyDeserializer.swift
//  Sniffer
//
//  Created by Kofktu on 2020/12/29.
//  Copyright © 2020 Kofktu. All rights reserved.
//
//  Modified by Alex Zchut on 23/02/2021.

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

public protocol BodyDeserializer {
    func deserialize(body: Data) -> [String: Any]?
}

public final class PlainTextBodyDeserializer: BodyDeserializer {
    public func deserialize(body: Data) -> [String: Any]? {
        return ["body": String(data: body, encoding: .utf8) ?? ""]
    }
}

public final class JSONBodyDeserializer: BodyDeserializer {
    public func deserialize(body: Data) -> [String: Any]? {
        do {
            let obj = try JSONSerialization.jsonObject(with: body, options: [])
            return ["body": obj]
        } catch {
            return nil
        }
    }
}

public final class HTMLBodyDeserializer: BodyDeserializer {
    public func deserialize(body: Data) -> [String: Any]? {
        do {
            let attr = try NSAttributedString(
                data: body,
                options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                          NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil)
            return ["body": attr.string]
        } catch {
            return nil
        }
    }
}

public final class UIImageBodyDeserializer: BodyDeserializer {
    #if os(iOS) || os(tvOS) || os(watchOS)
        private typealias Image = UIImage
    #elseif os(OSX)
        private typealias Image = NSImage
    #endif

    public func deserialize(body: Data) -> [String: Any]? {
        return Image(data: body).map { ["image": "\(Int($0.size.width)) x \(Int($0.size.height))"] }
    }
}

public final class MultipartFormDataDeserializer: BodyDeserializer {
    public func deserialize(body: Data) -> [String: Any]? {
        guard let comps = String(data: body, encoding: .ascii)?.components(separatedBy: "\r\n") else {
            return nil
        }

        let boundary = comps[0]
        var values: [String] = []
        var formDatas: [MultipartFormData] = []

        for comp in comps {
            if comp.hasPrefix(boundary) {
                if values.isEmpty == false {
                    formDatas.append(MultipartFormData(comps: values))
                }

                values.removeAll()
            }

            values.append(comp)
        }

        return ["multipart_form": formDatas.map { $0.result }.joined(separator: "\n")]
    }
}

private struct MultipartFormData {
    /**
     [0]    String    "--alamofire.boundary.3199e7165559519a"
     [1]    String    "Content-Disposition: form-data; name=\"fileURL\"; filename=\"icon.png\""
     [2]    String    "Content-Type: image/png"
     [3]    String    ""
     [4]    String    "\u{c2}PNG"
     [5]    String    "[Data]"
     [12]    String    "--alamofire.boundary.3199e7165559519a"
     [13]    String    "Content-Disposition: form-data; name=\"intValue\""
     [14]    String    "Content-Type: text/plain"
     [15]    String    ""
     [16]    String    "7"
     */
    var result: String {
        var result = comps.filter { canAppended($0) || $0.isEmpty }
        if isSupportType == false {
            result.append("[ Raw Data ]")
        }
        return result.joined(separator: "\n")
    }

    private let comps: [String]
    private var type: String? {
        comps.first { $0.hasPrefix("Content-Type") }?
            .replacingOccurrences(of: "Content-Type: ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSupportType: Bool {
        guard let type = type,
              let deserializer = Sniffer.find(deserialize: type) else {
            return false
        }

        return (deserializer is UIImageBodyDeserializer) == false
    }

    init(comps: [String]) {
        self.comps = comps
    }

    // MARK: - Private

    private func canAppended(_ component: String) -> Bool {
        component.hasPrefix(comps[0]) || component.hasPrefix("Content-") ||
            (component.isEmpty == false && isSupportType)
    }
}
