//
//  Endpoint.swift
//  SnapReel
//
//

import Foundation

public typealias Parameters = [String: Any]
public typealias HTTPHeaders = [String: String]

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
    case put = "PUT"
}

enum NetworkTask {
    case requestPlain
    case requestParameters
    case uploadMultipart(boundary: String)
}

enum ParametersEncoding {
    case url
    case json
}

protocol EndPoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var task: NetworkTask { get }
    var parametersEncoding: ParametersEncoding? { get }
    var media: [Media]? { get }
}

enum NetworkError: Error {
    case decodingError
    case httpError(Int)
    case unknown
}
