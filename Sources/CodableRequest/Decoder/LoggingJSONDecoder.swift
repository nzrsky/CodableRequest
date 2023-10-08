//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation
import os.log

class LoggingJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
        dateDecodingStrategy = .formatted(.json)
    }

    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do {
            return try super.decode(type, from: data)
        } catch {
            os_log(
                "Failed to decode JSON: %@\nReason: %@\nDetails: %@",
                type: .error,
                String(data: data, encoding: .utf8) ?? "nil",
                error.localizedDescription,
                String(describing: error)
            )
            throw error
        }
    }
}

extension DateFormatter {
    static let json: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return fmt
    }()
}
