//
//  Please refer to the LICENSE file for licensing information.
//

/* swiftlint:disable line_length */
import Combine
import Foundation
import os.log
import CodableRequest

open class RESTClient {
    public private(set) var session: URLSessionProvider
    public var url: URL

    public init(url: URL, pathPrefix: String? = nil, session: URLSessionProvider = URLSession.shared) {
        self.url = pathPrefix.map { url.appendingPathComponent($0) } ?? url
        self.session = session
    }

    // MARK: - Callbacks
    open func send<R: Request>(_ request: R, receiveOn queue: DispatchQueue? = nil, callback: @escaping (Result<R.Response, Error>) -> Void) {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encode(request)
            log(request: request, urlRequest)
            session.send(urlRequest, receiveOn: queue, callback: callback)
        } catch {
            callback(.failure(error))
        }
    }

    open func send<R: JSONRequest>(_ request: R, receiveOn queue: DispatchQueue? = nil, callback: @escaping (Result<R.Response, Error>) -> Void) {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encodeJson(request: request)
            log(request: request, urlRequest)
            session.send(urlRequest, receiveOn: queue, callback: callback)
        } catch {
            callback(.failure(error))
        }
    }

    open func send<R: PlainRequest>(_ request: R, receiveOn queue: DispatchQueue? = nil, callback: @escaping (Result<R.Response, Error>) -> Void) {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encodePlain(request: request)
            log(request: request, urlRequest)
            session.send(urlRequest, receiveOn: queue, callback: callback)
        } catch {
            callback(.failure(error))
        }
    }


    // MARK: - Async-Await
    open func send<R: Request>(_ request: R) async throws -> R.Response {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encode(request)
            log(request: request, urlRequest)
            return try await session.send(urlRequest)
        } catch {
            throw error
        }
    }

    open func send<R: JSONRequest>(_ request: R) async throws -> R.Response {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encodeJson(request: request)
            log(request: request, urlRequest)
            return try await session.send(urlRequest)
        } catch {
            throw error
        }
    }

    open func send<R: PlainRequest>(_ request: R) async throws -> R.Response {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encodePlain(request: request)
            log(request: request, urlRequest)
            return try await session.send(urlRequest)
        } catch {
            throw error
        }
    }

    // MARK: - Combine

    open func send<R: Request>(_ request: R) -> AnyPublisher<R.Response, Error> {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encode(request)
            log(request: request, urlRequest)
            return session.send(urlRequest)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    open func send<Request: JSONRequest>(_ request: Request) -> AnyPublisher<Request.Response, Error> {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encodeJson(request: request)
            log(request: request, urlRequest)
            return session.send(urlRequest)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    open func send<Request: PlainRequest>(_ request: Request) -> AnyPublisher<Request.Response, Error> {
        do {
            let encoder = RequestEncoder(baseURL: url)
            let urlRequest = try encoder.encodePlain(request: request)
            log(request: request, urlRequest)
            return session.send(urlRequest)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

private extension URLSessionProvider {
    @discardableResult
    func send<Response: Decodable>(_ urlRequest: URLRequest, receiveOn queue: DispatchQueue?, callback: @escaping (Result<Response, Error>) -> Void) -> URLSessionDataTask {
        send(urlRequest: urlRequest, completion: { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else {
                return callback(.failure(RESTClientError.invalidResponse))
            }
            
            var syncBlock: () -> Void
            do {
                let decoder = ResponseDecoder()
                let decoded = try decoder.decode(Response.self, from: (data: data, response: response))
                syncBlock = {
                    callback(.success(decoded))
                }
            } catch {
                syncBlock = {
                    callback(.failure(error))
                }
            }
            
            if let queue = queue {
                queue.async(execute: syncBlock)
            } else {
                syncBlock()
            }
        })
    }

    func send<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response {
        let (data, response) = try await send(urlRequest: urlRequest)
        
        guard let response = response as? HTTPURLResponse else {
            throw RESTClientError.invalidResponse
        }
        
        let decoder = ResponseDecoder()
        return try decoder.decode(Response.self, from: (data: data, response: response))
    }

    func send<Response: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<Response, Error> {
        send(urlRequest: urlRequest)
            .tryMap { (data: Data, response: URLResponse) in
                guard let response = response as? HTTPURLResponse else {
                    throw RESTClientError.invalidResponse
                }
                return (data: data, response: response)
            }
            .decode(type: Response.self, decoder: ResponseDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK: - Logging

/// Logs an `Request` and the generated `URLRequest`
///
/// - Parameters:
///   - request: request conforming to the `Request` protocol
///   - urlRequest: generated `urlRequest` with is sent to the endpoint
private func log<Request>(request: Request, _ urlRequest: URLRequest) {
    os_log(.debug, "[%@] Sending request of type %@ to URL: %@", urlRequest.httpMethod!, String(describing: type(of: request)), urlRequest.url!.absoluteString)
}

/// Logs a request with the received response and data
///
/// - Parameters:
///   - urlRequest: `URLRequest` sent to the remote endpoint
///   - response: `URLResponse` received from the remote endpoint
///   - data: `Data` received from the remote endpoint
private func log(urlRequest: URLRequest, response: URLResponse, data: Data) {
    let responseStatus = (response as? HTTPURLResponse)?.statusCode.description ?? "?"
    let dataCount = data.count.description
    let requestHttpMethod = urlRequest.httpMethod ?? "?"
    let requestUrl = urlRequest.url?.absoluteString ?? "?"
    os_log(.debug, "Received HTTP status %s with %s as response for HTTP %s %s", responseStatus, dataCount, requestHttpMethod, requestUrl)
}

/// Strips sensitive headers
///
/// Sensitive headers include:
///
///     - Authorization
///
/// - Parameter headers: HTTP header key-value pairs
/// - Returns: sanitized header HTTP key-value pairs
private func strippedSensitiveHeaders(headers: [String: String]) -> [String: String] {
    let sensitiveHeaderKeys = [
        "Authorization"
    ]

    var headers = headers
    for key in headers.keys where sensitiveHeaderKeys.contains(where: { $0.compare(key, options: .caseInsensitive) == .orderedSame }) {
        headers[key] = "REDACTED"
    }
    return headers
}
