//
//  IdentityObject.swift
//  SegmentAnalytics
//
//  Created by Alex Zchut on 29/06/2021.
//

struct IdentityObject {
    var identity: String
    var traits: [String: Any]?
    var options: [String: Any]?

    private enum CodingKeys: String {
        case identity, traits, options
    }

    init(identity: String,
         traits: [String: Any]?,
         options: [String: Any]?) {
        self.identity = identity
        self.traits = traits
        self.options = options
    }

    init?(jsonString: String) {
        guard let object = IdentityObject.fromJsonString(jsonString) else {
            return nil
        }
        
        identity = object.identity
        traits = object.traits
        options = object.options
    }

    private init(dictionary: [String: Any]?) {
        identity = dictionary?[CodingKeys.identity.rawValue] as? String ?? ""
        traits = dictionary?[CodingKeys.traits.rawValue] as? [String: Any]
        options = dictionary?[CodingKeys.options.rawValue] as? [String: Any]
    }

    private var dictionary: [String: Any] {
        return [
            CodingKeys.identity.rawValue: identity,
            CodingKeys.traits.rawValue: traits ?? [:],
            CodingKeys.options.rawValue: options ?? [:],
        ]
    }

    func toJsonString(_ options: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary,
                                                      options: options)
            let jsonString = String(data: jsonData,
                                    encoding: .utf8)
            return jsonString
        } catch {
            return nil
        }
    }

    static func fromJsonString(_ jsonString: String) -> IdentityObject? {
        var retValue: IdentityObject?
        guard let data = jsonString.data(using: String.Encoding.utf8) else {
            return retValue
        }

        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            retValue = IdentityObject(dictionary: dictionary)
        } catch {
            print("unable to parse the identity object")
        }
        return retValue
    }
}
