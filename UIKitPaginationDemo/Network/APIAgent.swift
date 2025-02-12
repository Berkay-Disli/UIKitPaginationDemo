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

typealias ResultClosure<T> = (CustomResult<T>) -> Void
typealias CustomResult<T> = Result<T?, ErrorResponse>

struct APIAgent {
    static let shared = APIAgent()

    func run<T: Codable>(_ endPoint: EndPoint, _ completion: @escaping ResultClosure<T>) {
        let request = URLRequest(endpoint: endPoint)

        request.log()

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                let error = ErrorResponse(status: 0, errorContext: "", errorCode: "", errorMessage: error.localizedDescription)

                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

            if let response = response, let data = data {
                APIAgent.shared.processDataResponse(response, data, endpoint: endPoint) { result in

                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            }
        }
        .resume()
    }

    func runAudioDownload(_ endPoint: EndPoint, _ completion: @escaping (Result<Data?, ErrorResponse>) -> Void) {
        let request = URLRequest(endpoint: endPoint)

        request.log()

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                let error = ErrorResponse(status: 0, errorContext: "", errorCode: "", errorMessage: error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let response = response, let data = data {
                let httpResponse = response as! HTTPURLResponse

                print("RESPONSE -> \(response.url?.absoluteString ?? "-") [\(httpResponse.statusCode)]")
                print(data.prettyPrintedJSONString ?? "{}")

                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        completion(.success(data))
                    }
                } else {
                    let error = ErrorResponse(status: httpResponse.statusCode, errorContext: "Invalid response", errorCode: "1001", errorMessage: "Unexpected error")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        .resume()
    }

    func processDataResponse<T: Codable>(_ response: URLResponse, _ data: Data, endpoint: EndPoint, completion: @escaping ResultClosure<T>) {
//        debugPrint(data.prettyPrintedJSONString ?? "Response is Nil")

        guard let httpResponse = response as? HTTPURLResponse else {
            let error = ErrorResponse(status: 0, errorContext: "", errorCode: "", errorMessage: "unknown!!")
            completion(.failure(error))
            return
        }

        print("RESPONSE -> \(response.url?.absoluteString ?? "-") [\(httpResponse.statusCode)]")
        print(data.prettyPrintedJSONString ?? "{}")

        switch httpResponse.statusCode {
        case 200 ... 299:
            var errorContext = ""

            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
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
