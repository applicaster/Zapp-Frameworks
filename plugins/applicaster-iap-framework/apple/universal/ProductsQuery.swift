//
//  ProductsQuery.swift
//  IAP
//
//  Created by Roman Karpievich on 4/9/19.
//  Copyright © 2019 Roman Karpievich. All rights reserved.
//

import Foundation
import StoreKit

class ProductsQuery: NSObject, SKProductsRequestDelegate {
    
    private let request: SKProductsRequest
    private let completion: (ProductsQueryResult) -> Void
    
    init(identifiers: Set<String>, completion: @escaping (ProductsQueryResult) -> Void) {
        self.request = SKProductsRequest(productIdentifiers: identifiers)
        self.completion = completion
        
        super.init()
        
        request.delegate = self
    }
    
    public func start() {
        request.start()
    }
    
    public func cancel() {
        request.cancel()
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let invalidIdentifiers = response.invalidProductIdentifiers
        let products = response.products
        let result = ProductsQueryResult.success((products, invalidIdentifiers))
        completion(result)
    }
    
    func requestDidFinish(_ request: SKRequest) {
        
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        let result = ProductsQueryResult.failure(error)
        completion(result)
    }
}
