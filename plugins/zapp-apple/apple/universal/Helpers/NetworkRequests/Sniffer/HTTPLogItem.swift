//
//  HTTPLogItem.swift
//  Sniffer
//
//  Created by Kofktu on 2020/12/29.
//  Copyright © 2020 Kofktu. All rights reserved.
//
//  Modified by Alex Zchut on 23/02/2021.

import Foundation

public final class HTTPLogItem {
    var url: URL { urlRequest.url! }

    private var urlRequest: URLRequest
    private var urlResponse: URLResponse?
    private var data: Data?
    private var error: Error?

    private var startDate: Date
    private var duration: TimeInterval?

    init(request: URLRequest) {
        assert(request.url != nil)

        urlRequest = request
        startDate = Date()

        logRequest()
    }

    func didReceive(response: URLResponse) {
        urlResponse = response
        data = Data()
    }

    func didReceive(data: Data) {
        self.data?.append(data)
    }

    func didCompleteWithError(_ error: Error?) {
        self.error = error
        duration = fabs(startDate.timeIntervalSinceNow)

        logDidComplete()
    }
}

private extension HTTPLogItem {
    struct Params {
        static let method = "method"
        static let url = "url"
        static let httpHeaderFieldsDescription = "httpHeaderFieldsDescription"
        static let bodyDescription = "bodyDescription"
        static let duration = "duration"
        static let response = "response"
        static let statusCode = "statusCode"
        static let localisedStatus = "localisedStatus"
        static let contentType = "contentType"
        static let body = "body"
        static let description = "description"
        static let reason = "reason"
        static let suggestion = "suggestion"
    }

    func log(_ value: [String: Any], type: Sniffer.LogType) {
        if let logger = Sniffer.onLogger {
            logger(type, value)
        } else {
            print(value)
        }
    }

    func logRequest() {
        var result: [String: Any] = [:]

        if let method = urlRequest.httpMethod {
            result[Params.method] = method
            result[Params.url] = url.absoluteString
        }

        result[Params.httpHeaderFieldsDescription] = urlRequest.httpHeaderFieldsDescription
        result[Params.bodyDescription] = urlRequest.bodyDescription

        log(result, type: .request)
    }

    func logDidComplete() {
        var result: [String: Any] = [:]
        result[Params.url] = url.absoluteString

        if let duration = duration {
            result[Params.duration] = "\(duration)"
        }

        result[Params.response] = error != nil ? logErrorResponse() : logResponse()

        log(result, type: .response)
    }

    func logResponse() -> [String: Any] {
        var result: [String: Any] = [:]

        guard let response = urlResponse else {
            return result
        }

        var contentType = "application/octet-stream"

        if let httpResponse = response as? HTTPURLResponse {
            let localisedStatus = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode).capitalized
            result[Params.statusCode] = "\(httpResponse.statusCode)"
            result[Params.localisedStatus] = "\(localisedStatus)"
            result[Params.httpHeaderFieldsDescription] = httpResponse.httpHeaderFieldsDescription

            if let type = httpResponse.allHeaderFields["Content-Type"] as? String {
                contentType = type
                result[Params.contentType] = contentType
            }
        }

        if let body = data,
           let deserialize = Sniffer.find(deserialize: contentType)?.deserialize(body: body) ?? PlainTextBodyDeserializer().deserialize(body: body) {
            result[Params.body] = deserialize
        }

        return result
    }

    func logErrorResponse() -> [String: Any] {
        var result: [String: Any] = [:]

        guard let error = error else {
            return result
        }

        let nsError = error as NSError

        result[Params.statusCode] = "\(nsError.code)"
        result[Params.description] = "\(nsError.localizedDescription)"

        if let reason = nsError.localizedFailureReason {
            result[Params.reason] = "\(reason)"
        }
        if let suggestion = nsError.localizedRecoverySuggestion {
            result[Params.suggestion] = "\(suggestion)"
        }

        return result
    }
}

private extension URLRequest {
    var httpHeaderFieldsDescription: [String: Any] {
        var result: [String: Any] = [:]

        guard let headers = allHTTPHeaderFields, !headers.isEmpty else {
            return result
        }

        for (key, value) in headers {
            result["\(key)"] = value
        }
        return headers
    }

    var bodyData: Data? {
        httpBody ?? httpBodyStream.flatMap { stream in
            let data = NSMutableData()
            stream.open()
            while stream.hasBytesAvailable {
                var buffer = [UInt8](repeating: 0, count: 1024)
                let length = stream.read(&buffer, maxLength: buffer.count)
                data.append(buffer, length: length)
            }
            stream.close()
            return data as Data
        }
    }

    var bodyDescription: [String: Any] {
        var result: [String: Any] = [:]

        guard let body = bodyData else {
            return [:]
        }

        let contentType = value(forHTTPHeaderField: "Content-Type") ?? "application/octet-stream"

        if let deserialized = Sniffer.find(deserialize: contentType)?.deserialize(body: body) {
            result = deserialized
        }

        return result
    }
}

private extension HTTPURLResponse {
    var httpHeaderFieldsDescription: [String: Any] {
        var result: [String: Any] = [:]

        guard !allHeaderFields.isEmpty else {
            return result
        }

        for (key, value) in allHeaderFields {
            result["\(key)"] = value
        }
        return result
    }
}
