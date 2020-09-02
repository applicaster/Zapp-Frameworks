//
//  Utils.swift
//  ApplicasterIAP
//
//  Created by Anton Kononenko on 4/13/20.
//  Copyright © 2020 Roman Karpievich. All rights reserved.
//

import Foundation
import StoreKit

public class Utils {
    public struct ReceiptValidation {
        public static let Sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
        public static let Store = "https://buy.itunes.apple.com/verifyReceipt"
    }

    enum RecieptStatusCodes: Int {
        case ok = 0
    }

    class func receiptInBase64String() -> String? {
        guard let receiptData = BillingHelper.sharedInstance.localReceiptData() else {
            return nil
        }
        return receiptData.base64EncodedString(options: [])
    }

    class func validateReceiptRequest(urlString: String) -> URLRequest? {
        guard let serviceUrl = URL(string: urlString),
            let receiptBase64 = receiptInBase64String() else { return nil }
        let parameterDictionary = ["receipt-data": receiptBase64]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json",
                         forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return nil
        }
        request.httpBody = httpBody
        return request
    }

    public class func parseReceiptResponce(data: Data?) -> [String: Any]? {
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let json = json as? [String: Any] {
                    return json
                } else {
                    return nil
                }

            } catch {
                debugPrint(error)
                return nil
            }
        }
        return nil
    }

    public class func validateReceipt(urlString: String = ReceiptValidation.Store,
                                      completion: @escaping (_ receipt: [String: Any]?, _ error: Error?) -> Void) {
        guard let request = validateReceiptRequest(urlString: urlString) else {
            return
        }

        let session = URLSession.shared
        session.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                }

                if let parsedData = parseReceiptResponce(data: data) {
                    if let status = parsedData["status"] as? Int,
                        status == 21007 {
                        validateReceipt(urlString: ReceiptValidation.Sandbox,
                                        completion: completion)
                    } else {
                        completion(parsedData, nil)
                    }
                } else {
                    completion(nil, NSError(domain: "Can not parse an receipt response",
                                            code: -1,
                                            userInfo: nil))
                }
            }
        }.resume()
    }
}
