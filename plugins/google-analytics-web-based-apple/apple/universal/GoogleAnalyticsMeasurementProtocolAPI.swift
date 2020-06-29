//
//  GoogleAnalyticsMeasurementProtocolAPI.swift
//  ZappAnalyticsPluginGAtvOS
//
//  Created by Anton Kononenko on 1/15/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation

let baseURL = "https://www.google-analytics.com/collect?"
let mesurementProtocolVersion = "1"
let dataSourceKey = "app"

/// This structure describes all keys that MeasurementProtocolManager is using
///
/// [Dev Guide:](https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide)
/// This document describes how to send common hits to the Measurement Protocol
///
/// [Parameters:](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters)
/// This document lists all of the parameters for the Measurement Protocol.
///
/// [Hit Builder:](https://ga-dev-tools.appspot.com/hit-builder)
/// This tools allows you to construct and validate Measurement Protocol hits
/// using the Measurement Protocol Validation Server.
struct MeasurementProtocolKeys {
    /// Keys that availible for all hits in Google Analytics Measurement Protocol.
    struct All {
        /// This will only change when there are changes made that are not backwards compatible.
        /// - Note:
        ///     - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#v)
        /// - Example:
        /// ````
        /// v=1
        /// ````
        static let protocolVersion = "v"

        ///  The format is UA-XXXX-Y. All collected data is associated by this ID.
        /// - Note:
        ///   - [Tracking ID / Web Property ID](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#tid)
        /// - Example:
        /// ````
        /// tid=UA-XXXX-Y
        /// ````
        static let trackingID = "tid"

        /// Indicates the data source of the hit.
        /// Hits sent from analytics.js will have data source set to 'web'; hits sent from
        /// one of the mobile SDKs will have data source set to 'app'.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ds)
        /// - Example:
        /// ````
        /// ds=app
        /// ````
        static let dataSource = "ds"

        /// This field is required if User ID (uid) is not specified in the request.
        /// This anonymously identifies a particular user, device, or browser instance.
        /// For the web, this is generally stored as a first-party cookie with a two-year expiration.
        /// For mobile apps, this is randomly generated for each particular instance of an application install.
        /// The value of this field should be a random UUID (version 4) as described in documentation
        /// - Note:
        ///     - [Client ID](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cid)
        ///     - [UUID Documentation](http://www.ietf.org/rfc/rfc4122.txt)
        /// - Example:

        /// ````
        /// cid=35009a79-1a05-49d7-b876-2b884d0f825b
        /// ````
        static let clientID = "cid"

        ///  Specifies the screen resolution.
        /// - Note:
        /// [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#sr)
        /// - Example:
        /// ````
        /// sr=800x600
        /// ````
        static let screenResolution = "sr"

        /// Specifies the language.
        /// - Note:
        /// [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ul)
        /// - Example:
        /// ````
        /// ul=en-us
        /// ````
        static let userLanguage = "ul"

        /// The type of hit.
        /// - Note:
        /// [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t)
        /// - Example:
        /// ````
        /// t=pageview
        /// ````
        static let hitType = "t"

        struct HitType {
            static let pageView = "pageview"
            static let screenView = "screenview"
            static let event = "event"
            static let transaction = "transaction"
            static let item = "item"
            static let social = "social"
            static let exception = "exception"
            static let timing = "timing"
        }

        /// [Custom Dimension](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cd)
        /// Each custom dimension has an associated index.
        /// There is a maximum of 20 custom dimensions (200 for Analytics 360 accounts).
        /// The dimension index must be a positive integer between 1 and 200, inclusive.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cd)
        /// - Example:
        /// ````
        /// cd1=Sports
        /// cd2=Cooking
        /// ````
        static let customDimension = "cd"
    }

    /// Keys that availible for Screen View hit in Google Analytics Measurement Protocol.
    struct ScreenView {
        /// This parameter is optional on web properties, and required on mobile properties for screenview hits,
        /// where it is used for the 'Screen Name' of the screenview hit.
        /// On web properties this will default to the unique URL of the page by either using t
        /// he &dl parameter as-is or assembling it from &dh and &dp.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cd)
        /// - Example:
        /// ````
        /// cd=High%20Scores
        /// ````
        static let screenName = "cd"
    }

    /// Keys that availible for App Tracking hit in Google Analytics Measurement Protocol.
    struct AppTracking {
        /// Specifies the application name.
        /// This field is required for any hit that has app related data
        /// (i.e., app version, app ID, or app installer ID).
        /// For hits sent to web properties, this field is optional.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#an)
        /// - Example:
        /// ````
        /// an=My%20App
        /// ````
        static let applicationName = "an"

        /// Application bundle identifier.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#aid)
        /// - Example:
        /// ````
        /// aid=com.company.app
        /// ````
        static let bundleIdentifier = "aid"

        /// Specifies the application version.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#av)
        /// - Example:
        /// ````
        /// av=1.2
        /// ````
        static let applicationVersion = "av"
    }

    /// Keys that availible for Event Tracking hit in Google Analytics Measurement Protocol.
    struct EventTracking {
        /// Specifies the event category. Must not be empty.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ec)
        /// - Example:
        /// ````
        /// ec=Category
        /// ````
        static let category = "ec"

        /// Specifies the event action. Must not be empty.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ea)
        /// - Example:
        /// ````
        /// ea=Action
        /// ````
        static let action = "ea"

        /// Specifies the event label..
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#el)
        /// - Example:
        /// ````
        /// el=Label
        /// ````
        static let label = "el"

        /// Specifies the event value. Values must be non-negative.
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ev)
        /// - Example:
        /// ````
        /// ev=55
        /// ````
        static let value = "ev"
    }

    /// Keys that availible for Exceptions Tracking hit in Google Analytics Measurement Protocol.
    struct ExceptionsTracking {
        /// Specifies the description of an exception
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#exd)
        /// - Example:
        /// ````
        /// exd=DatabaseError
        /// ````
        static let exceptionDescription = "exd"

        /// Specifies whether the exception was fatal. Bool value
        /// - Note:
        ///   - [Documentation](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#exf)
        /// - Example:
        /// ````
        /// exd=DatabaseError
        /// ````
        static let exceptionFatal = "exf=0"
    }
}
