//
//  URLRequestExtension.swift
//  UIKitPaginationDemo
//
//  Created by BERKAY DISLI on 12.02.2025.
//

import Foundation

extension URLRequest {
    init(endpoint: EndPoint) {
        let urlComponents = URLComponents(endpoint: endpoint)

        self.init(url: urlComponents.url!)

        httpMethod = endpoint.method.rawValue

        endpoint.headers?.forEach { key, value in
            addValue(value, forHTTPHeaderField: key)
        }

        if case .requestParameters = endpoint.task, endpoint.parametersEncoding == .json, let parameters = endpoint.parameters {
            httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        } else if case let .uploadMultipart(boundary) = endpoint.task, let media = endpoint.media {
            httpBody = createDataBody(withParameters: endpoint.parameters, media: media, boundary: boundary)
        }
    }

    func createDataBody(withParameters params: Parameters?, media: [Media], boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value as! String + lineBreak)")
            }
        }
        for photo in media {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
            body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
            body.append(photo.data)
            body.append(lineBreak)
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }

    func log() {
        print("\(httpMethod ?? "") \(self)")
        if let allHTTPHeaderFields = allHTTPHeaderFields {
            print("HEADERS \n \(allHTTPHeaderFields)")
        }
        if let body = httpBody?.prettyPrintedJSONString {
            print("BODY \n \(body)")
        }
    }
}

extension URLComponents {
    init(endpoint: EndPoint) {
        var url = endpoint.baseURL
        if !endpoint.path.isEmpty {
            url = url.appendingPathComponent(endpoint.path)
        }

        self.init(url: url, resolvingAgainstBaseURL: false)!

        guard case .requestParameters = endpoint.task, endpoint.parametersEncoding == .url, let parameters = endpoint.parameters else { return }

        var tempQueryItems = [URLQueryItem]()
        for param in parameters {
            if let arrayOfStringsAsValue = param.value as? [String] {
                for string in arrayOfStringsAsValue {
                    tempQueryItems.append(URLQueryItem(name: param.key, value: string))
                }
            } else {
                tempQueryItems.append(URLQueryItem(name: param.key, value: String(describing: param.value)))
            }
        }

        queryItems = tempQueryItems
    }
}
