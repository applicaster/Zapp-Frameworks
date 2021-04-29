//
//  Image+Extension.swift
//  ZappCore
//
//  Created by Alex Zchut on 28/04/2021.
//

import Foundation

extension UIImage {
    public func getDataUrl() -> URL? {
        guard let base64Image = pngData()?.base64EncodedString() else { return nil }
        return URL(string: "data:image/png;base64,\(base64Image)")
    }

    public func getLocalUrl() -> URL? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = UUID().uuidString + ".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            try pngData()?.write(to: fileURL)
            return fileURL
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
