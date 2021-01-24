/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The `ContentKeyManager` class configures the instance of `AVContentKeySession` to use for requesting content keys
 securely for playback or offline use.
 */

//  Adopted by Alex Zchut for plugin usage on 21/01/2021.

import AVFoundation
import XrayLogger

class ContentKeyManager {
    // MARK: Types.

    /// The singleton for `ContentKeyManager`.
    static let shared: ContentKeyManager = ContentKeyManager()

    // MARK: Properties.

    /// The instance of `AVContentKeySession` that is used for managing and preloading content keys.
    let contentKeySession: AVContentKeySession

    /**
     The instance of `ContentKeyDelegate` which conforms to `AVContentKeySessionDelegate` and is used to respond to content key requests from
     the `AVContentKeySession`
     */
    fileprivate let contentKeyDelegate: ContentKeyDelegate

    /// The DispatchQueue to use for delegate callbacks.
    fileprivate let contentKeyDelegateQueue = DispatchQueue(label: "com.applicaster.drm.ContentKeyDelegateQueue")

    // MARK: Initialization.

    private init() {
        contentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)
        contentKeyDelegate = ContentKeyDelegate()

        contentKeySession.setDelegate(contentKeyDelegate, queue: contentKeyDelegateQueue)
    }

    var logger: Logger? {
        didSet {
            contentKeyDelegate.logger = logger
        }
    }

    func setContentKeyRequestParams(_ params: ContentKeyRequestParams) {
        contentKeyDelegate.contentKeyRequestParams = params
    }
    
    func setContentKeyStorageNamespace(_ namespace: String?) {
        contentKeyDelegate.contentKeyStorageNamespace = namespace
    }
    
    func requestPersistableContentKeys(for contentKeyRequestParams: ContentKeyRequestParams, completion: ((_ isReady: Bool) -> Void)?) {
        contentKeyDelegate.requestPersistableContentKeys(for: contentKeyRequestParams, completion: completion)
    }
}
