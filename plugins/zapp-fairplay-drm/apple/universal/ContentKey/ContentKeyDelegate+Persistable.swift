/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This extension on `ContentKeyDelegate` implements the `AVContentKeySessionDelegate` protocol methods related to persistable content keys.
 */

//  Adopted by Alex Zchut for plugin usage on 24/01/2021.

import AVFoundation
import ZappCore

extension ContentKeyDelegate {
    /*
     Provides the receiver with a new content key request that allows key persistence.
     Will be invoked by an AVContentKeyRequest as the result of a call to
     -respondByRequestingPersistableContentKeyRequest.
     */
    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVPersistableContentKeyRequest) {
        handlePersistableContentKeyRequest(keyRequest: keyRequest)
    }

    /*
     Provides the receiver with an updated persistable content key for a particular key request.
     If the content key session provides an updated persistable content key data, the previous
     key data is no longer valid and cannot be used to answer future loading requests.

     This scenario can occur when using the FPS "dual expiry" feature which allows you to define
     and customize two expiry windows for FPS persistent keys. The first window is the storage
     expiry window which starts as soon as the persistent key is created. The other window is a
     playback expiry window which starts when the persistent key is used to start the playback
     of the media content.

     Here's an example:

     When the user rents a movie to play offline you would create a persistent key with a CKC that
     opts in to use this feature. This persistent key is said to expire at the end of storage expiry
     window which is 30 days in this example. You would store this persistent key in your apps storage
     and use it to answer a key request later on. When the user comes back within these 30 days and
     asks you to start playback of the content, you will get a key request and would use this persistent
     key to answer the key request. At that point, you will get sent an updated persistent key which
     is set to expire at the end of playback experiment which is 24 hours in this example.
     */
    func contentKeySession(_ session: AVContentKeySession,
                           didUpdatePersistableContentKey persistableContentKey: Data,
                           forContentKeyIdentifier keyIdentifier: Any) {
        /*
         The key ID is the URI from the EXT-X-KEY tag in the playlist (e.g. "skd://key65") and the
         asset ID in this case is "key65".
         */
        guard let contentKeyIdentifierString = keyIdentifier as? String,
              let contentKeyIdentifierURL = URL(string: contentKeyIdentifierString),
              let assetIDString = contentKeyIdentifierURL.host
        else {
            logger?.errorLog(message: "Failed to retrieve the assetID from the keyRequest")
            return
        }

        deletePeristableContentKey(withContentKeyIdentifier: assetIDString)
        writePersistableContentKey(contentKey: persistableContentKey, withContentKeyIdentifier: assetIDString)
    }

    // MARK: API.

    /// Handles responding to an `AVPersistableContentKeyRequest` by determining if a key is already available for use on disk.
    /// If no key is available on disk, a persistable key is requested from the server and securely written to disk for use in the future.
    /// In both cases, the resulting content key is used as a response for the `AVPersistableContentKeyRequest`.
    ///
    /// - Parameter keyRequest: The `AVPersistableContentKeyRequest` to respond to.
    func handlePersistableContentKeyRequest(keyRequest: AVPersistableContentKeyRequest) {
        /*
         The key ID is the URI from the EXT-X-KEY tag in the playlist (e.g. "skd://key65") and the
         asset ID in this case is "key65".
         */
        guard let contentKeyIdentifierString = keyRequest.identifier as? String,
              let contentKeyIdentifierURL = URL(string: contentKeyIdentifierString),
              let assetIDString = contentKeyIdentifierURL.host,
              let assetIDData = assetIDString.data(using: .utf8)
        else {
            keyRequest.processContentKeyResponseError(ProcessError.failedToRetrieveContentId)
            return
        }

        do {
            let completionHandler = { (spcData: Data?, error: Error?) in
                if let error = error {
                    keyRequest.processContentKeyResponseError(error)
                    return
                }

                guard let spcData = spcData else { return }

                do {
                    // Send SPC to Key Server and obtain CKC
                    let ckcData = try self.requestContentKeyFromKeySecurityModule(spcData: spcData, assetID: assetIDString)

                    let persistentKey = try keyRequest.persistableContentKey(fromKeyVendorResponse: ckcData, options: nil)

                    self.writePersistableContentKey(contentKey: persistentKey, withContentKeyIdentifier: assetIDString)

                    /*
                     AVContentKeyResponse is used to represent the data returned from the key server when requesting a key for
                     decrypting content.
                     */
                    let keyResponse = AVContentKeyResponse(fairPlayStreamingKeyResponseData: persistentKey)

                    /*
                     Provide the content key response to make protected content available for processing.
                     */
                    keyRequest.processContentKeyResponse(keyResponse)
                    self.processPendingCompletionsForContentKey(for: assetIDString, isReady: true)
                } catch {
                    keyRequest.processContentKeyResponseError(error)
                }
                self.pendingPersistableContentKeyIdentifiers.remove(assetIDString)
            }

            // Check to see if we can satisfy this key request using a saved persistent key file.
            if persistableContentKeyExists(withContentKeyIdentifier: assetIDString) {
                let storageKeyForPersistableKey = storageKeyForPersistableContentKey(withContentKeyIdentifier: assetIDString)

                guard let contentKeyDataString = FacadeConnector.connector?.storage?.keychainStorageValue(for: storageKeyForPersistableKey,
                                                                                                          namespace: contentKeyStorageNamespace),
                    let contentKey = Data(base64Encoded: contentKeyDataString) else {
                    // Error Handling.

                    pendingPersistableContentKeyIdentifiers.remove(assetIDString)

                    /*
                     Key requests should never be left dangling.
                     Attempt to create a new persistable key.
                     */
                    let applicationCertificate = try requestApplicationCertificate()
                    keyRequest.makeStreamingContentKeyRequestData(forApp: applicationCertificate,
                                                                  contentIdentifier: assetIDData,
                                                                  options: [AVContentKeyRequestProtocolVersionsKey: [1]],
                                                                  completionHandler: completionHandler)

                    return
                }

                /*
                 Create an AVContentKeyResponse from the persistent key data to use for requesting a key for
                 decrypting content.
                 */
                let keyResponse = AVContentKeyResponse(fairPlayStreamingKeyResponseData: contentKey)

                // Provide the content key response to make protected content available for processing.
                keyRequest.processContentKeyResponse(keyResponse)

                return
            }

            let applicationCertificate = try requestApplicationCertificate()

            keyRequest.makeStreamingContentKeyRequestData(forApp: applicationCertificate,
                                                          contentIdentifier: assetIDData,
                                                          options: [AVContentKeyRequestProtocolVersionsKey: [1]],
                                                          completionHandler: completionHandler)
        } catch {
            logger?.errorLog(message: "Failure responding to an AVPersistableContentKeyRequest when attemping to determine if key is already available for use on disk.")
        }
    }

    /// Deletes a persistable key for a given content key identifier.
    ///
    /// - Parameter contentKeyIdentifier: The host value of an `AVPersistableContentKeyRequest`. (i.e. "tweleve" in "skd://tweleve").
    func deletePeristableContentKey(withContentKeyIdentifier contentKeyIdentifier: String) {
        guard persistableContentKeyExists(withContentKeyIdentifier: contentKeyIdentifier) else { return }

        let storageKey = storageKeyForPersistableContentKey(withContentKeyIdentifier: contentKeyIdentifier)
        _ = FacadeConnector.connector?.storage?.localStorageRemoveValue(for: storageKey,
                                                                        namespace: contentKeyStorageNamespace)
    }

    /// Returns whether or not a persistable content key exists on disk for a given content key identifier.
    ///
    /// - Parameter contentKeyIdentifier: The host value of an `AVPersistableContentKeyRequest`. (i.e. "tweleve" in "skd://tweleve").
    /// - Returns: `true` if the key exists on disk, `false` otherwise.
    func persistableContentKeyExists(withContentKeyIdentifier contentKeyIdentifier: String) -> Bool {
        guard let _ = FacadeConnector.connector?.storage?.localStorageValue(for: contentKeyIdentifier, namespace: contentKeyStorageNamespace) else {
            return false
        }
        return true
    }

    // MARK: Private APIs

    /// Returns the `URL` for persisting or retrieving a persistable content key.
    ///
    /// - Parameter contentKeyIdentifier: The host value of an `AVPersistableContentKeyRequest`. (i.e. "tweleve" in "skd://tweleve").
    /// - Returns: The fully resolved file URL.
    func storageKeyForPersistableContentKey(withContentKeyIdentifier contentKeyIdentifier: String) -> String {
        return "\(contentKeyIdentifier)-PersistableContentKey"
    }

    /// Writes out a persistable content key to disk.
    ///
    /// - Parameters:
    ///   - contentKey: The data representation of the persistable content key.
    ///   - contentKeyIdentifier: The host value of an `AVPersistableContentKeyRequest`. (i.e. "tweleve" in "skd://tweleve").
    /// - Throws: If an error occurs during the file write process.
    func writePersistableContentKey(contentKey: Data, withContentKeyIdentifier contentKeyIdentifier: String) {
        let key = storageKeyForPersistableContentKey(withContentKeyIdentifier: contentKeyIdentifier)

        _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: key,
                                                                     value: contentKey.base64EncodedString(),
                                                                     namespace: contentKeyStorageNamespace)
    }
}
