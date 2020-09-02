//
//  ReceiptRefreshQuery.swift
//  IAP
//
//  Created by Roman Karpievich on 4/15/19.
//  Copyright © 2019 Roman Karpievich. All rights reserved.
//

import Foundation
import StoreKit

class ReceiptRefreshQuery: NSObject, SKRequestDelegate {
    
    private let request: SKReceiptRefreshRequest
    private let completion: (ReceiptRefreshResult) -> Void
    
    init(receiptProperties: [String: Any]? = nil,
         completion: @escaping (ReceiptRefreshResult) -> Void) {
        self.request = SKReceiptRefreshRequest(receiptProperties: receiptProperties)
        self.completion = completion
        super.init()
        
        self.request.delegate = self
    }
    
    public func start() {
        request.start()
    }
    
    public func cancel() {
        request.cancel()
    }
    
    // MARK: - SKRequestDelegate methods
    
    func requestDidFinish(_ request: SKRequest) {
        completion(.success)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        completion(.failure(error))
    }
}
