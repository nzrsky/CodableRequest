//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation
import Combine

public protocol URLSessionProvider {
    func send(urlRequest request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>
    func send(urlRequest request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func send(urlRequest request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProvider {
    public func send(urlRequest request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        dataTaskPublisher(for: request).eraseToAnyPublisher()
    }

    public func send(urlRequest request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }

    public func send(urlRequest request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}

public extension ResponseJSONDecoderProvider {
    static func decoder(
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    ) -> JSONDecoder {
        LoggingJSONDecoder(
            keyDecodingStrategy: keyDecodingStrategy,
            dateDecodingStrategy: dateDecodingStrategy
        )
    }
}
