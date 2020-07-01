//
//  ZPAppleGenericUniversalLinks.swift
//  ZappAppleGenericUniversalLinks
//
//  Created by Alex Zchut on 05/02/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import ZappCore

class ZPAppleGenericUniversalLinks: NSObject, PluginAdapterProtocol {
    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?

    /// Plugin configuration keys
    struct PluginKeys {
        static let mappingUrl = "mapping_url"
    }

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    public var providerName: String {
        return "Apple Generic Universal Links"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {

            completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    public func fetchAppMappedUrl(for webpageUrl: URL) {

        guard let baseUrl = configurationJSON?[PluginKeys.mappingUrl] as? String,
            let requestUrl = URL(string: baseUrl) else {
                return
        }

        URLSession.shared.dataTask(with: requestUrl, completionHandler: { (data, response, error) in

            guard error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    return
            }

            do {
                let responseData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                guard let urlString = responseData[webpageUrl.absoluteString] as? String,
                    let url =  URL(string: urlString) else {
                    return
                }

                self.openApp(with: url)
            } catch _ as NSError {

            }
        }).resume()
    }

    func openApp(with url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

}

extension ZPAppleGenericUniversalLinks: AppLoadingHookProtocol {
    func executeOnContinuingUserActivity(_ userActivity: NSUserActivity?,
                                         completion: (() -> Void)?) {

        if let webpageURL = userActivity?.webpageURL {
            self.fetchAppMappedUrl(for: webpageURL)
        }

        completion?()
    }
}
