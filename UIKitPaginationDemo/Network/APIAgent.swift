//
//  APIService.swift
//  SnapReel
//
//

import Combine
import Foundation

struct ErrorResponse: Codable, Error {
    var status: Int
    var errorContext: String
    var errorCode: String
    var errorMessage: String

    static let sample = ErrorResponse(status: 0, errorContext: "", errorCode: "", errorMessage: "")
}

struct APIResponse<T: Codable> {
    let data: T?
    let totalPages: Int?
    
    init(data: T?, totalPages: Int?) {
        self.data = data
        self.totalPages = totalPages
    }
}

typealias ResultClosure<T: Codable> = (CustomResult<APIResponse<T>>) -> Void
typealias CustomResult<T> = Result<T?, ErrorResponse>

struct APIAgent {
    static let shared = APIAgent()
    
    private let paginationPagesHeaderKey: String = "x-pagination-pages"

    func run<T: Codable>(_ endPoint: EndPoint, _ completion: @escaping ResultClosure<T>) {
        let request = URLRequest(endpoint: endPoint)
        request.log()

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                let error = ErrorResponse(status: 0, errorContext: "", errorCode: "", errorMessage: error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

            if let response, let data {
                APIAgent.shared.processDataResponse(response, data, endpoint: endPoint) { result in
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            }
        }
        .resume()
    }

    func processDataResponse<T: Codable>(_ response: URLResponse, _ data: Data, endpoint: EndPoint, completion: @escaping ResultClosure<T>) {
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = ErrorResponse(status: 0, errorContext: "", errorCode: "", errorMessage: "unknown!!")
            completion(.failure(error))
            return
        }

        print("RESPONSE -> \(response.url?.absoluteString ?? "-") [\(httpResponse.statusCode)]")
        print(data.prettyPrintedJSONString ?? "{}")
        
        let totalPages = httpResponse.value(forHTTPHeaderField: paginationPagesHeaderKey).flatMap { Int($0) }
        
        switch httpResponse.statusCode {
        case 200 ... 299:
            var errorContext = ""

            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                let apiResponse = APIResponse(data: model, totalPages: totalPages)
                completion(.success(apiResponse))
                return
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
                errorContext = context.debugDescription
            } catch let DecodingError.keyNotFound(key, context) {
                errorContext = "Key '\(key)' not found: \(context.debugDescription)"
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                errorContext = "Value '\(value)' not found: \(context.debugDescription)"
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context) {
                errorContext = "Type '\(type)' mismatch: \(context.debugDescription)"
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                errorContext = error.localizedDescription
                print("error: ", error)
            }

            let error = ErrorResponse(status: httpResponse.statusCode, errorContext: errorContext, errorCode: "1001", errorMessage: "Unexpected Error: 1001")
            completion(.failure(error))
            return

        case 401:
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                completion(.failure(errorResponse))

            } catch {
                let error = ErrorResponse(status: httpResponse.statusCode, errorContext: error.localizedDescription, errorCode: "", errorMessage: "Unexpected Error: 1001")
                completion(.failure(error))
                return
            }

        default:

            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                completion(.failure(errorResponse))

            } catch  {
                let error = ErrorResponse(status: httpResponse.statusCode, errorContext: error.localizedDescription, errorCode: "", errorMessage: "Unexpected Error: 1001")
                completion(.failure(error))
                return
            }
        }
    }
}
