//
//  Sniffer.swift
//  ZappApple
//
//  Created by Alex Zchut on 24/02/2021.
//

import Foundation

class Sniffer: URLProtocol {
    public enum LogType: String {
        case request, response
    }

    private enum Keys {
        static let request = "Sniffer.request"
    }

    private static var bodyDeserializers: [String: BodyDeserializer] = [
        "application/x-www-form-urlencoded": PlainTextBodyDeserializer(),
        "*/json": JSONBodyDeserializer(),
        "image/*": UIImageBodyDeserializer(),
        "text/plain": PlainTextBodyDeserializer(),
        "*/html": HTMLBodyDeserializer(),
        "multipart/form-data; boundary=*": MultipartFormDataDeserializer(),
    ]

    public static var onLogger: ((URL, LogType, [String: Any]) -> Void)? // If the handler is registered, the log inside the Sniffer will not be output.
    private static var ignoreDomains: [String]?
    private static var ignoreExtensions: [String]?

    var session: URLSession?
    var sessionTask: URLSessionDataTask?
    private var urlTask: URLSessionDataTask?
    var logItem: HTTPLogItem?

    public class func start() {
        URLSessionConfiguration.setupSwizzledSessionConfiguration()
    }

    public class func ignore(domains: [String]) {
        ignoreDomains = domains
    }

    public class func ignore(extensions: [String]) {
        ignoreExtensions = extensions
    }

    static func find(deserialize contentType: String) -> BodyDeserializer? {
        for (pattern, deserializer) in Sniffer.bodyDeserializers {
            do {
                let regex = try NSRegularExpression(pattern: pattern.replacingOccurrences(of: "*", with: "[a-z]+"))
                let results = regex.matches(in: contentType, range: NSRange(location: 0, length: contentType.count))

                if !results.isEmpty {
                    return deserializer
                }
            } catch {
                continue
            }
        }

        return nil
    }

    private class func shouldIgnoreDomain(with url: URL) -> Bool {
        guard let ignoreDomains = ignoreDomains, !ignoreDomains.isEmpty,
              let host = url.host else {
            return false
        }
        return ignoreDomains.first { $0.range(of: host) != nil } != nil
    }

    private class func shouldIgnoreExtensions(with url: URL) -> Bool {
        guard let ignoreExtensions = ignoreExtensions,
              !ignoreExtensions.isEmpty else {
            return false
        }

        return ignoreExtensions.contains(url.pathExtension.lowercased()) || url.pathExtension.isEmpty
    }

    // MARK: - URLProtocol

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)

        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }

    override public class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url, let scheme = url.scheme else { return false }
        guard !shouldIgnoreDomain(with: url) else { return false }
        guard !shouldIgnoreExtensions(with: url) else { return false }

        return ["http", "https"].contains(scheme) && property(forKey: Keys.request, in: request) == nil
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        guard let urlRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest, logItem == nil else { return }

        logItem = HTTPLogItem(request: urlRequest as URLRequest)
        Sniffer.setProperty(true, forKey: Keys.request, in: urlRequest)
        sessionTask = session?.dataTask(with: urlRequest as URLRequest)
        sessionTask?.resume()
    }

    override public func stopLoading() {
        sessionTask?.cancel()
        DispatchQueue.main.async {
            self.session?.invalidateAndCancel()
        }
    }
}
