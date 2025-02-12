//
//  UserEndpoint.swift
//  UIKitPaginationDemo
//
//  Created by BERKAY DISLI on 12.02.2025.
//

import Foundation

enum UserEndpoint: EndPoint {
    case getUsers(page: Int)
    
    var baseURL: URL {
        return URL(string: "https://gorest.co.in")!
    }
    
    var path: String {
        switch self {
        case .getUsers:
            return "public/v2/users"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        switch self {
        case .getUsers(let page):
            return ["page": page]
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var task: NetworkTask {
        return .requestParameters
    }
    
    var parametersEncoding: ParametersEncoding? {
        return .url
    }
    
    var media: [Media]? {
        return nil
    }
}
