//
//  APFile.swift
//  ApplicasterSDK
//
//  Created by Avi Levin on 13/11/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import Foundation

@objc public class APFile: NSObject {
    var filename: String
    var url: String
    var request: URLRequest?
    var searchPathDirectory: FileManager.SearchPathDirectory = .documentDirectory

    public convenience init(filename: String,
                url: String,
                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) {
        self.init(filename: filename,
                  url: url,
                  searchPathDirectory: .documentDirectory,
                  cachePolicy: cachePolicy)
    }

    public init(filename: String,
                url: String,
                searchPathDirectory: FileManager.SearchPathDirectory = .documentDirectory,
                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) {
        self.filename = filename
        self.searchPathDirectory = searchPathDirectory
        self.url = url
        if let fileURL = URL(string: url) {
            self.request = URLRequest(url: fileURL,
                                      cachePolicy: cachePolicy)
        }
    }

    /*
     * Returns the local url path of the file
     */
    public func localURLPath() -> URL? {
        var retVal: URL?
  
        var path = NSSearchPathForDirectoriesInDomains(self.searchPathDirectory, .userDomainMask, true)
        //https://developer.apple.com/library/archive/documentation/General/Conceptual/AppleTV_PG/index.html#//apple_ref/doc/uid/TP40015241
        // tvOS can not have local storage
        #if os(tvOS)
            path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        #endif
        if let documentDirectoryPath:String = path.first {
            retVal = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/\(filename)"))
        }
        return retVal
    }
    
    /*
     * Check if the File exists in localstorage
     */
    public func isInLocalStorage() -> Bool {
        guard let localURL = localURLPath() else {
            return false
        }
        return FileManager.default.fileExists(atPath: localURL.path)
    }
    
    /*
     * Save a temp URL in local memory of an app
     */
    func saveToStorage(data: Data) -> Bool {
        var success = false
        let fileManager = FileManager.default
        if let localURLPath = localURLPath() {
            do {
                if isInLocalStorage() {
                    try fileManager.removeItem(at: localURLPath)
                }
                
                try data.write(to: localURLPath, options: .atomic)
                success = true
            } catch let error {
                debugPrint("An error occurred while writing file file to destination url, caught: \(error)")
            }
        }
        return success
    }
    
    override public var description: String {
        return "File -> filename: \(filename) url: \(url)"
    }
    
    func getCachedData() -> Data? {
        guard let localURLPath = localURLPath() else {
            return nil
        }
        return FileManager.default.contents(atPath: localURLPath.path)
    }

    public func deleteCachedData() {
        guard let localURL = localURLPath(),
            self.isInLocalStorage() else {
            return
        }

        do {
            try FileManager.default.removeItem(atPath: localURL.path)
        }
        catch {}
    }
}
