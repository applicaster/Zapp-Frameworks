//
//  APFileCompletion.swift
//  ApplicasterSDK
//
//  Created by Avi Levin on 14/11/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import Foundation

class APFileLoadingCompletion: NSObject {
    let file: APFile
    var completionArray: [((_ success:Bool) -> Void)]
    var didFinish: Bool
    
    init(file: APFile) {
        self.file = file
        self.completionArray = []
        self.didFinish = false
    }
    
    convenience init(file: APFile, completion: ((_ success:Bool) -> Void)?) {
        self.init(file: file)
        if let completion = completion {
            completionArray.append(completion)
        }
    }
}
