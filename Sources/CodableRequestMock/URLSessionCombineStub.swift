//
//  Please refer to the LICENSE file for licensing information.
//

import Combine
import Foundation
import CodableREST

public class URLSessionCombineStub: URLSessionProvider {
    private var result: Result<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>
    private var urlRequestHandler: (URLRequest) -> Void

    public init(response: URLSession.DataTaskPublisher.Output, urlRequestHandler: @escaping (URLRequest) -> Void = { _ in }) {
        self.result = .success(response)
        self.urlRequestHandler = urlRequestHandler
    }

    public init(throwsError error: URLSession.DataTaskPublisher.Failure, urlRequestHandler: @escaping (URLRequest) -> Void = { _ in }) {
        self.result = .failure(error)
        self.urlRequestHandler = urlRequestHandler
    }

    public func send(urlRequest request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        urlRequestHandler(request)
        return Future { promise in
            switch self.result {
            case let .success(output):
                promise(.success(output))
            case let .failure(error):
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    @discardableResult
    public func send(urlRequest _: URLRequest, completion _: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError("not available")
    }

    public func send(urlRequest _: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("not available")
    }
}
