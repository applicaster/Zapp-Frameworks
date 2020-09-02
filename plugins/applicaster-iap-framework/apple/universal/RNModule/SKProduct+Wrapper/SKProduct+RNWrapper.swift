import Foundation
import StoreKit

struct SKProductWrapperKeys {
    static let localizedDescription = "description"
    static let localizedTitle = "title"
    static let price = "price"
    static let productIdentifier = "productIdentifier"
    static let isDownloadable = "isDownloadable"
    static let downloadContentLengths = "downloadContentLengths"
    static let contentVersion = "contentVersion"
    static let downloadContentVersion = "downloadContentVersion"
    static let subscriptionPeriod = "subscriptionPeriod"
    static let productType = "productType"

}

extension SKProduct {
    class func wrappProducts(products: [SKProduct]) -> [[String: Any]] {
        return products.map({ wrappProductToDictionary(product: $0) })
    }

    class func wrappProductToDictionary(product: SKProduct) -> [String: Any] {
        var retVal: [String: Any] = [:]

        retVal[SKProductWrapperKeys.localizedDescription] = product.localizedDescription
        retVal[SKProductWrapperKeys.localizedTitle] = product.localizedTitle
        retVal[SKProductWrapperKeys.price] = product.localizedPrice()
        retVal[SKProductWrapperKeys.productIdentifier] = product.productIdentifier
        retVal[SKProductWrapperKeys.isDownloadable] = product.isDownloadable
        retVal[SKProductWrapperKeys.downloadContentLengths] = product.downloadContentLengths
        retVal[SKProductWrapperKeys.contentVersion] = product.contentVersion
        retVal[SKProductWrapperKeys.downloadContentVersion] = product.downloadContentVersion

        return retVal
    }

    func localizedPrice() -> String? {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = priceLocale
        return priceFormatter.string(from: price)
    }
}
