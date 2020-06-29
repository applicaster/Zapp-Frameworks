//
//  PipesDataModelHelper.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 8/27/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

public struct PipesDataModelHelper {
    public let pipesObject: [AnyHashable: Any]
    public init(pipesDataDict: [AnyHashable: Any]) {
        pipesObject = pipesDataDict
    }

    public var identifier: String? {
        var retVal: String?
        if let identifier = pipesObject["id"] as? Int {
            retVal = String(identifier)
        } else if let identifier = pipesObject["id"] as? String {
            retVal = identifier
        }
        return retVal
    }

    public var screenType: String? {
        return pipesObject["screen_type"] as? String
    }

    public lazy var extensions: PipesDataModelHelperExtensions = {
        PipesDataModelHelperExtensions(extensionsDict: pipesObject["extensions"] as? [AnyHashable: Any])
    }()

    public var title: String? {
        return pipesObject["title"] as? String
    }

    public var subtitle: String? {
        return pipesObject["subtitle"] as? String
    }

    public var summary: String? {
        return pipesObject["summary"] as? String
    }

    public var updated: String? {
        return pipesObject["updated"] as? String
    }

    public var published: String? {
        return pipesObject["published"] as? String
    }

    public var link: String? {
        guard let link = pipesObject["link"] as? [String: String],
            let href = link["href"] else {
            return nil
        }
        return href
    }

    public var author: String? {
        return pipesObject["author"] as? String
    }

    public var category: String? {
        return pipesObject["category"] as? String
    }

    public lazy var content: PipesDataModelHelperContent = {
        PipesDataModelHelperContent(contentDict: pipesObject["content"] as? [AnyHashable: String])
    }()

    public var advertisment: [AnyHashable: Any]? {
        return pipesObject["advertisement"] as? [AnyHashable: Any]
    }

    public var type: String? {
        guard let applicasterType = pipesObject["type"] as? [String: String],
            let modelType = applicasterType["value"] else {
            return nil
        }
        return modelType
    }

    public lazy var mediaGroups: PipesDataModelHelperMediaGroups = {
        PipesDataModelHelperMediaGroups(mediaGroupsArray: pipesObject["media_group"] as? [[AnyHashable: Any]])
    }()
}
