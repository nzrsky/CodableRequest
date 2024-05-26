//
//  Please refer to the LICENSE file for licensing information.
//

/* swiftlint:disable line_length */
import Combine
import Foundation
import os.log

@_exported import CodableRequest
@_exported import URLEncodedFormCodable
@_exported import MultipartFormCodable

open class CodableURLSession: @unchecked Sendable {
    
    public let urlSession: URLSessionProvider
    public let encoder: RequestEncoder

    public init(url: URL, pathPrefix: String? = nil, urlSession: URLSessionProvider = URLSession.shared, retryStrategy: RetryStrategy = .default) {
        self.encoder = .init(baseURL: pathPrefix.map { url.appendingPathComponent($0) } ?? url)
        self.urlSession = urlSession
    }

    // MARK: - Callbacks
    open func send<R: Request>(
        _ request: R,
        on requestQueue: DispatchQueue = .global(qos: .default),
        receiveOn receiveQueue: DispatchQueue? = .main,
        callback: @escaping (Result<R.Response, Error>) -> Void
    ) {
        requestQueue.async {
            do {
                let urlRequest = try self.encoder.encode(request)
                log(request: request, urlRequest)
                self.urlSession.send(urlRequest, receiveOn: receiveQueue, callback: callback)
            } catch {
                receiveQueue?.async {
                    callback(.failure(error))
                }
            }
        }
    }

    open func send<R: JSONRequest>(
        _ request: R,
        on requestQueue: DispatchQueue = .global(qos: .default),
        receiveOn receiveQueue: DispatchQueue? = .main,
        callback: @escaping (Result<R.Response, Error>) -> Void
    ) {
        requestQueue.async {
            do {
                let urlRequest = try self.encoder.encodeJson(request)
                log(request: request, urlRequest)
                self.urlSession.send(urlRequest, receiveOn: receiveQueue, callback: callback)
            } catch {
                receiveQueue?.async {
                    callback(.failure(error))
                }
            }
        }
    }

    open func send<R: PlainRequest>(
        _ request: R,
        on requestQueue: DispatchQueue = .global(qos: .default),
        receiveOn receiveQueue: DispatchQueue? = .main,
        callback: @escaping (Result<R.Response, Error>) -> Void
    ) {
        requestQueue.async {
            do {
                let urlRequest = try self.encoder.encodePlain(request)
                log(request: request, urlRequest)
                self.urlSession.send(urlRequest, receiveOn: receiveQueue, callback: callback)
            } catch {
                receiveQueue?.async {
                    callback(.failure(error))
                }
            }
        }
    }

    open func send<R: FormURLEncodedRequest>(
        _ request: R,
        on requestQueue: DispatchQueue = .global(qos: .default),
        receiveOn receiveQueue: DispatchQueue? = .main,
        callback: @escaping (Result<R.Response, Error>) -> Void
    ) {
        requestQueue.async {
            do {
                let urlRequest = try self.encoder.encodeFormURLEncoded(request)
                log(request: request, urlRequest)
                self.urlSession.send(urlRequest, receiveOn: receiveQueue, callback: callback)
            } catch {
                receiveQueue?.async {
                    callback(.failure(error))
                }
            }
        }
    }

    open func send<R: MultipartFormRequest>(
        _ request: R,
        on requestQueue: DispatchQueue = .global(qos: .default),
        receiveOn receiveQueue: DispatchQueue? = .main,
        callback: @escaping (Result<R.Response, Error>) -> Void
    ) {
        requestQueue.async {
            do {
                let urlRequest = try self.encoder.encodeMultipartForm(request)
                log(request: request, urlRequest)
                self.urlSession.send(urlRequest, receiveOn: receiveQueue, callback: callback)
            } catch {
                receiveQueue?.async {
                    callback(.failure(error))
                }
            }
        }
    }

    // MARK: - Async-Await
    open func send<R: Request>(_ request: R) async throws -> R.Response {
        do {
            let urlRequest = try encoder.encode(request)
            log(request: request, urlRequest)
            return try await self.urlSession.send(urlRequest)
        } catch {
            throw error
        }
    }

    open func send<R: JSONRequest>(_ request: R) async throws -> R.Response {
        do {
            let urlRequest = try encoder.encodeJson(request)
            log(request: request, urlRequest)
            return try await self.urlSession.send(urlRequest)
        } catch {
            throw error
        }
    }

    open func send<R: PlainRequest>(_ request: R) async throws -> R.Response {
        do {
            let urlRequest = try encoder.encodePlain(request)
            log(request: request, urlRequest)
            return try await self.urlSession.send(urlRequest)
        } catch {
            throw error
        }
    }

    open func send<R: FormURLEncodedRequest>(_ request: R) async throws -> R.Response {
        do {
            let urlRequest = try encoder.encodeFormURLEncoded(request)
            log(request: request, urlRequest)
            return try await self.urlSession.send(urlRequest)
        } catch {
            throw error
        }
    }

    open func send<R: MultipartFormRequest>(_ request: R) async throws -> R.Response {
        do {
            let urlRequest = try encoder.encodeMultipartForm(request)
            log(request: request, urlRequest)
            return try await self.urlSession.send(urlRequest)
        } catch {
            throw error
        }
    }

    // MARK: - Combine

    private func sendPublisher<R: Request>(
        _ request: R,
        encoding: @escaping (R) throws -> URLRequest,
        on requestQueue: DispatchQueue = .global(qos: .default)
    ) -> AnyPublisher<R.Response, Error> {
        Future { promise in
            requestQueue.async {
                do {
                    let urlRequest = try encoding(request)
                    log(request: request, urlRequest)
                    promise(.success(urlRequest))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .flatMap{ self.urlSession.send($0) }
        .eraseToAnyPublisher()
    }

    open func sendPublisher<R: Request>(
        _ request: R,
        on requestQueue: DispatchQueue = .global(qos: .default)
    ) -> AnyPublisher<R.Response, Error> {
        sendPublisher(
            request,
            encoding: { try self.encoder.encode($0) },
            on: requestQueue
        )
    }

    open func sendPublisher<Request: JSONRequest>(
        _ request: Request,
        on requestQueue: DispatchQueue = .global(qos: .default)
    ) -> AnyPublisher<Request.Response, Error> {
        sendPublisher(
            request,
            encoding: { try self.encoder.encodeJson($0) },
            on: requestQueue
        )
    }

    open func sendPublisher<Request: PlainRequest>(
        _ request: Request,
        on requestQueue: DispatchQueue = .global(qos: .default)
    ) -> AnyPublisher<Request.Response, Error> {
        sendPublisher(
            request,
            encoding: { try self.encoder.encodePlain($0) },
            on: requestQueue
        )
    }

    open func sendPublisher<Request: FormURLEncodedRequest>(
        _ request: Request,
        on requestQueue: DispatchQueue = .global(qos: .default)
    ) -> AnyPublisher<Request.Response, Error> {
        sendPublisher(
            request,
            encoding: { try self.encoder.encodeFormURLEncoded($0) },
            on: requestQueue
        )
    }

    open func sendPublisher<Request: MultipartFormRequest>(
        _ request: Request,
        on requestQueue: DispatchQueue = .global(qos: .default)
    ) -> AnyPublisher<Request.Response, Error> {
        sendPublisher(
            request,
            encoding: { try self.encoder.encodeMultipartForm($0) },
            on: requestQueue
        )
    }
}

private extension URLSessionProvider {
    @discardableResult
    func send<Response: Decodable, TLD: AnyTopLevelDecoder>(
        _ urlRequest: URLRequest,
        using decoderType: TLD.Type = DefaultResponseTopLevelDecoder.self,
        receiveOn receiveQueue: DispatchQueue?,
        callback: @escaping (Result<Response, Error>) -> Void
    ) -> URLSessionDataTask where TLD.Input == (data: Data, response: HTTPURLResponse) {

        send(urlRequest: urlRequest, completion: { data, response, error in
            var syncBlock: () -> Void
            do {
                if let response = response as? HTTPURLResponse, let data {
                    let decoded = try decoderType.init().decode(Response.self, from: (data: data, response: response))
                    syncBlock = {
                        callback(.success(decoded))
                    }
                } else {
                    syncBlock = { callback(.failure(error ?? CodableURLSessionError.invalidResponse)) }
                }
            } catch {
                syncBlock = {
                    callback(.failure(error))
                }
            }

            if let queue = receiveQueue {
                queue.async(execute: syncBlock)
            } else {
                syncBlock()
            }
        })
    }

    func send<Response: Decodable, TLD: AnyTopLevelDecoder>(
        _ urlRequest: URLRequest,
        using decoderType: TLD.Type = DefaultResponseTopLevelDecoder.self
    ) async throws -> Response where TLD.Input == (data: Data, response: HTTPURLResponse) {
        let (data, response) = try await send(urlRequest: urlRequest)

        guard let response = response as? HTTPURLResponse else {
            throw CodableURLSessionError.invalidResponse
        }

        let decoder = decoderType.init()
        return try decoder.decode(Response.self, from: (data: data, response: response))
    }

    func send<Response: Decodable, TLD: AnyTopLevelDecoder>(
        _ urlRequest: URLRequest,
        using decoderType: TLD.Type = DefaultResponseTopLevelDecoder.self
    ) -> AnyPublisher<Response, Error> where TLD.Input == (data: Data, response: HTTPURLResponse) {
        send(urlRequest: urlRequest)
            .tryMap { (data: Data, response: URLResponse) in
                guard let response = response as? HTTPURLResponse else {
                    throw CodableURLSessionError.invalidResponse
                }
                return (data: data, response: response)
            }
            .decode(type: Response.self, decoder: decoderType.init())
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
    os_log(
        .debug,
        "[%@] Sending request of type %@ to URL: %@",
        urlRequest.httpMethod ?? "UNKNOWN",
        String(describing: type(of: request)),
        urlRequest.url?.absoluteString ?? ""
    )
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
    let HTTPMethod = urlRequest.httpMethod ?? "?"
    let requestUrl = urlRequest.url?.absoluteString ?? "?"
    os_log(.debug, "Received HTTP status %s with %s as response for HTTP %s %s", responseStatus, dataCount, HTTPMethod, requestUrl)
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

public protocol AnyTopLevelDecoder: TopLevelDecoder {
    init()
}

public class DefaultResponseTopLevelDecoder: AnyTopLevelDecoder {
    required public init() {}

    public func decode<T>(_ type: T.Type, from: (data: Data, response: HTTPURLResponse)) throws -> T where T: Decodable {
        let decoder = ResponseDecoding<LoggingJSONDecoder.Provider>(response: from.response, data: from.data)
        return try T(from: decoder)
    }
}
