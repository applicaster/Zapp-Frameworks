//
//  APCacheHelper.swift
//  Pods
//
//  Created by Lior Azi & Avi Levin on 08/07/2017.
//
//

import Foundation

class APCacheHelper: NSObject {
    
    class func download(file: APFile,
                        completion:@escaping (_ success:Bool) -> Void) {
        guard let request = file.request else {
            return completion(false)
        }
        
        //Request Header configuration:
        let configuration = URLSessionConfiguration.default
        
        //Set download cache
        configuration.urlCache = APCacheManager.urlCache
        
        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: request) { (data, response, error) in
            var success = false
            if let data = data,
                let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                   
                    if file.getCachedData() == nil || data != file.getCachedData() {
                        success = file.saveToStorage(data: data)
                    } else if file.isInLocalStorage() {
                        success = true
                    }
                }
            } else if let error = error {
                debugPrint("Failed to load with error: \(error.localizedDescription)")
            }
            
            completion(success)
        }
        
        task.resume()
    }
  
}

