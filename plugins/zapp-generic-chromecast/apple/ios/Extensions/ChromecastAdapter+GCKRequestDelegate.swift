//  ChromecastAdapter+GCKRequestDelegate.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast
import ZappCore

extension ChromecastAdapter: GCKRequestDelegate {
    public func requestDidComplete(_ request: GCKRequest) {
        let message = "GCKRequest \(Int(request.requestID)) completed"
        print(message)

        NotificationCenter.default.post(name: .chromecastStartedPlaying, object: nil)
        //send event of starting playback
        if let castDidStartMediaSession = castDidStartMediaSession {
            castDidStartMediaSession(true)
            self.castDidStartMediaSession = nil
        }
    }
    
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        let message = "request \(Int(request.requestID)) failed with error \(error)"
        print(message)

        
        //close mini player view controller
        self.updateVisibilityOfMiniPlayerViewController()
        
        if let triggeredChromecastButton = self.triggeredChromecastButton {
            ChromecastAnalytics.sendChromecastErrorReportEvent(triggeredChromecastButton: triggeredChromecastButton,
                                                               request: request,
                                                               error: error)
        }
        
        //send event of error in playback
        if let castDidStartMediaSession = castDidStartMediaSession {
            castDidStartMediaSession(false)
            self.castDidStartMediaSession = nil
        }
        NotificationCenter.default.post(name: .chromecastPlayingError, object: nil)
    }
    
}
