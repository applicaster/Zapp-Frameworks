//
//  ZPAnalyticsProviderTimedEventsSupportProtocol.swift
//  ZappAnalyticsPluginBase
//
//  Created by Liviu Romascanu on 25/06/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import UIKit

@objc public protocol ZPAnalyticsProviderTimedEventsSupportProtocol {
    /*
     * Start handling timed event.
     * This function adds tracking of timed events as they come in to add the concept of timed event to non timed event provider.
     */
    @objc func registerTimedEvent(_ eventName: String, parameters: [String: NSObject]?)
    /*
     * Proces handling ending of a timed event.
     * This function looks for a registered timed event, ads the event duration and sends the event.
     */
    @objc func processEndTimedEvent(_ eventName: String, parameters: [String: NSObject]?)
}
