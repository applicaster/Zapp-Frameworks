//
//  NetworkService.swift
//  CopaAmericaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

typealias networkServiceCompletionHandler = (_ success: Bool, _ json: JSON?) -> Void

struct NetworkService {
    static func makeRequest(_ request: NetworkURLRequestConvertible, completion: @escaping (networkServiceCompletionHandler)) {
        var fullURL: URL?

        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.last {
            fullURL = url.appendingPathComponent("\(request.cacheKey).json")
        }

        AF.request(request).responseJSON { response in
            if let json = response.value {
                saveToCache(url: fullURL, json: json)
                completion(true, JSON(json))
            } else if let url = fullURL,
                      FileManager.default.fileExists(atPath: url.path),
                      let cachedJSONData = try? Data(contentsOf: url),
                      let cachedJSON = String(data: cachedJSONData, encoding: .utf8) {
                completion(true, JSON(parseJSON: cachedJSON))
            } else {
                completion(false, nil)
            }
        }
    }

    static func saveToCache(url: URL?, json: Any) {
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []),
           let url = url {
            do {
                try data.write(to: url, options: [.atomic])
            } catch {
                print("Could not save cached file")
            }
        }
    }
}
