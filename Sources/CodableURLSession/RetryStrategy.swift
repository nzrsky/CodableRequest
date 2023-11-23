//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

public struct RetryStrategy {
    let maxRetries: Int
    let baseDelay: TimeInterval

    func delay(forAttempt attempt: Int) -> TimeInterval {
        return pow(2.0, Double(attempt)) * baseDelay
    }
}

extension RetryStrategy {
    public static let `default`: Self = .init(maxRetries: 3, baseDelay: 1)
}

class Retrier {
    private let strategy: RetryStrategy
    private var currentAttempt = 0

    init(strategy: RetryStrategy) {
        self.strategy = strategy
    }

    func retry<Response>(
        on retryQueue: DispatchQueue = .global(qos: .default),
        with taskProvider: @escaping (@escaping (Result<Response, Error>) -> Void) -> Void,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        taskProvider { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case let .failure(error as URLError) where error.isNetworkError:
                // Retry only for specific network-related errors
                guard let self, self.currentAttempt < self.strategy.maxRetries else {
                    completion(result)
                    return
                }

                self.currentAttempt += 1
                
                let delay = self.strategy.delay(forAttempt: self.currentAttempt)
                retryQueue.asyncAfter(deadline: .now() + delay) {
                    self.retry(with: taskProvider, completion: completion)
                }
            case .failure:
                completion(result)
            }
        }
    }
}

private extension URLError {
    var isNetworkError: Bool {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut:
            return true
        default:
            return false
        }
    }
}
