//
//  APCacheManager.swift
//  ApplicasterSDK
//
//  Created by Avi Levin on 12/11/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import UIKit

@objc public class APCacheManager: NSObject {
    #if targetEnvironment(macCatalyst)
        static let urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024,
                                       diskCapacity: 50 * 1024 * 1024,
                                       directory: nil)

    #else
        static let urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024,
                                       diskCapacity: 50 * 1024 * 1024,
                                       diskPath: "cache_manager.path")
    #endif

    @objc public static let shared = APCacheManager()
    private var fileCompletions: [APFileLoadingCompletion] = []

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Public Methods

    @objc public func saveObjectToCache(_ object: JsonSerializableProtocol, identifier: String?) {
        let cachedModel = APCachedModel(object: object, identifier: identifier ?? "")
        _ = cachedModel.saveObjectToStorage()
    }

    @objc public func loadObjectFromCache(forClass classType: AnyClass, identifier: String?) -> JsonSerializableProtocol? {
        var retValue: JsonSerializableProtocol?
        guard let classType = classType as? JsonSerializableProtocol.Type else {
            return nil
        }
        let model = APCachedModel(object: classType.init(), identifier: identifier ?? "")
        if model.loadObjectFromStorage() == true {
            retValue = model.object
        }
        return retValue
    }

    @objc public func deleteObjectFromCache(_ object: JsonSerializableProtocol, identifier: String?) {
        let cachedModel = APCachedModel(object: object, identifier: identifier ?? "")
        _ = cachedModel.deleteLocalStorage()
    }

    @objc public func getLocalPath(forUrlString urlString: String, useMd5UrlFilename: Bool) -> URL? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var file: APFile?
        if useMd5UrlFilename {
            let filename = "\(urlString.toMd5hash()).\(url.pathExtension)"
            file = APFile(filename: filename, url: urlString)
        } else {
            file = APFile(filename: url.lastPathComponent, url: urlString)
        }
        return file?.isInLocalStorage() == true ? file?.localURLPath() : nil
    }

    @objc public func getLocalPath(forUrlString urlString: String) -> URL? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        let file = APFile(filename: url.lastPathComponent, url: urlString)
        return file.localURLPath()
    }

    @objc public func download(urlString: String, completion: ((_ success: Bool) -> Void)?) {
        guard let url = URL(string: urlString) else {
            completion?(false)
            return
        }
        let file = APFile(filename: url.lastPathComponent, url: urlString)
        download(file: file, completion: completion)
    }

    public func download(file: APFile,
                         completion: ((_ success: Bool) -> Void)?) {
        // There can be only 2 states here, the same file is already been downloaded or not
        if let downloadedFile = self.getFileCompletionFromArray(file: file),
            let completion = completion {
            // Check if file download has already been finshed so we can't add a new completion object
            if downloadedFile.didFinish {
                // Check of file was saved on disk
                let success = file.isInLocalStorage()
                // Send completion on main theard
                DispatchQueue.main.async {
                    completion(success)
                }

            } else {
                downloadedFile.completionArray.append(completion)
            }
        } else {
            // Create a new FileCompletion object
            let fileCompletionObject = APFileLoadingCompletion(file: file, completion: completion)
            // Insert the object to fileCompletionArray
            fileCompletions.append(fileCompletionObject)
            // Start download
            APCacheHelper.download(file: file, completion: { success in

                // Try to get the completion object from the array
                guard let fileCompletion = self.getFileCompletionFromArray(file: file) else {
                    // remember, the method completion closer is optional
                    guard let completion = completion else {
                        return
                    }

                    return completion(file.isInLocalStorage())
                }

                // Close array before notify
                fileCompletion.didFinish = true

                // Notify all registered completion array
                for completion in fileCompletion.completionArray {
                    // Send completion on main theard
                    DispatchQueue.main.async {
                        completion(success || file.isInLocalStorage())
                    }
                }

                // Remove fileCompletionObject
                self.synchronized(lock: self, block: {
                    if let index = self.fileCompletions.firstIndex(of: fileCompletion) {
                        self.fileCompletions.remove(at: index)
                    }
                })

            })
        }
    }

    func synchronized(lock: AnyObject, block: () throws -> Void) rethrows {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }

        try block()
    }

    func getFileCompletionFromArray(file: APFile) -> APFileLoadingCompletion? {
        return fileCompletions.first(where: { $0.file.filename == file.filename && $0.file.url == file.url })
    }
}
