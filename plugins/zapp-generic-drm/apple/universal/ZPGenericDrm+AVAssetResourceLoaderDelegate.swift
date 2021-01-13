//
//  ZPGenericDrm+AVAssetResourceLoaderDelegate.swift
//  ZappGenericDrm
//
//  Created by Alex Zchut on 12/01/2021.
//

import AVKit
import Foundation

let errorDomain = "com.zapp.generic.drm.error"

extension ZPGenericDrm: AVAssetResourceLoaderDelegate {

    struct ErrorCodes {
        static let unableToReadRequestUrl = -1
        static let unableToReadCertificateData = -2
        static let requestUrlSchemeIsNotValid = -3
        static let unableToReadSPCdata = -4
        static let licenseServerUrlIsNotProvided = -5
        static let unableToFetchCKC = -6
    }

    // swiftlint:disable:next function_body_length
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        // 1. Generate the SPC
        //      - handle shouldWaitForLoadingOfRequestResource: for key requests
        //      - call [AVAssetResourceLoadingRequest streamingContentKeyRequestDataForApp: contentIdentifier: options: err: ] to produce SPC
        // 2. Send SPC request to your Key Server
        // 3. Provide CKC response (or error) to AVAssetResourceLoadingRequest

        // check if the url is set in the manifest
        guard let url = loadingRequest.request.url else {
            logger?.debugLog(message: "Unable to read the URL/HOST data")

            loadingRequest.finishLoading(with: NSError(domain: errorDomain, code: ErrorCodes.unableToReadRequestUrl, userInfo: nil))
            return false
        }

        logger?.verboseLog(message: "Printing the url",
                           data: ["url" : url.absoluteString])

        // load the certificate from the server
        guard let certificateUrlString = configurationJSON?[PluginKeys.certificateUrl] as? String,
              let certificateUrl = URL(string: certificateUrlString),
              let certificateData = try? Data(contentsOf: certificateUrl) else {
            logger?.debugLog(message: "Unable to read the certificate data")

            loadingRequest.finishLoading(with: NSError(domain: errorDomain, code: ErrorCodes.unableToReadCertificateData, userInfo: nil))
            return false
        }

        //        #EXTM3U
        //        #EXT-X-VERSION:5
        //        ## Created with Unified Streaming Platform(version=1.7.18)
        //        #EXT-X-MEDIA-SEQUENCE:0
        //        #EXT-X-PLAYLIST-TYPE:VOD
        //        #EXT-X-INDEPENDENT-SEGMENTS
        //        #EXT-X-TARGETDURATION:8
        //        #EXT-X-KEY:METHOD=SAMPLE-AES,URI="skd://5dc60e94-a10c-1822-7b0c-914773242c94",KEYFORMAT="com.apple.streamingkeydelivery",KEYFORMATVERSIONS="1"
        //        #EXTINF:8, no desc

        // request the Server Playback Context (SPC)
        guard url.scheme == "skd",
              let contentId = url.host, let contentIdData = contentId.data(using: .utf8) else {
            logger?.debugLog(message: "Request url scheme is not valid")
            loadingRequest.finishLoading(with: NSError(domain: errorDomain, code: ErrorCodes.requestUrlSchemeIsNotValid, userInfo: nil))
            return false
        }

        var spcData: Data?
        do {
            spcData = try loadingRequest.streamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdData, options: nil)
        } catch let err {
            logger?.debugLog(message: "Error in Content Key Request",
                             data: ["errorDescription" : err.localizedDescription])
        }

        guard
            //            let contentIdData = "com.apple.fps.1_0".data(using: .utf8),
            //            let contentIdData = stream.licenseToken.data(using: .utf8),
            //            let contentIdData = "com.apple.streamingkeydelivery".data(using: .utf8),
            let spcDataOutput = spcData,
            let dataRequest = loadingRequest.dataRequest else {
            logger?.debugLog(message: "Unable to read the SPC data")
            loadingRequest.finishLoading(with: NSError(domain: errorDomain, code: ErrorCodes.unableToReadSPCdata, userInfo: nil))
            return false
        }

        logger?.verboseLog(message: "Printing spcData",
                         data: ["spc" : spcDataOutput.base64EncodedString()])
        
        // request the content key context from the server
        guard let licenseServerUrlString = configurationJSON?[PluginKeys.licenseServerUrl] as? String,
              let licenseServerUrl = URL(string: licenseServerUrlString) else {
            logger?.debugLog(message: "License server url is not provided")
            loadingRequest.finishLoading(with: NSError(domain: errorDomain, code: ErrorCodes.licenseServerUrlIsNotProvided, userInfo: nil))
            return false
        }

        var request = URLRequest(url: licenseServerUrl)
        request.httpMethod = "POST"
        request.httpBody = spcDataOutput
        let session = URLSession(configuration: .default)
        //        let task = session.dataTask(with: request) { data, response, error in}
        let task = session.dataTask(with: request) { data, response, error in
            print("response: \(String(describing: response))")
            print("data: \(String(describing: data))")
            print("error: \(String(describing: error?.localizedDescription))")

            if let data = data {
                // The CKC is correctly returned and is now send to the `AVPlayer` instance so we
                // can continue to play the stream.
                self.logger?.debugLog(message: "Success fetching the CKC")

                dataRequest.respond(with: data)
                loadingRequest.finishLoading()
            } else {
                self.logger?.debugLog(message: "Unable to fetch the CKC")
                loadingRequest.finishLoading(with: NSError(domain: errorDomain, code: ErrorCodes.unableToFetchCKC, userInfo: nil))
            }
        }
        task.resume()

        // tell the AVPlayer instance to wait
        return true
    }
}
