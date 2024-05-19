//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation
import os.log

extension JSONDecoder {
    public convenience init(
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    ) {
        self.init()
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
    }
}

public class FailingJSONDecoder: JSONDecoder {
    public struct Provider: ResponseJSONDecoderProvider {
        public static func decoder(
            keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy,
            dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
        ) -> JSONDecoder {
            FailingJSONDecoder(
                keyDecodingStrategy: keyDecodingStrategy,
                dateDecodingStrategy: dateDecodingStrategy
            )
        }
    }

    override public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do {
            return try super.decode(type, from: data)
        } catch {
            let msg = "Failed to decode JSON: \(String(data: data, encoding: .utf8) ?? "nil")\n"
                + "Reason: \(error.localizedDescription)\n"
                + "Details: \(String(describing: error))"

            fatalError(msg)
        }
    }
}

public class LoggingJSONDecoder: JSONDecoder {
    public struct Provider: ResponseJSONDecoderProvider {
        public static func decoder(
            keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy,
            dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
        ) -> JSONDecoder {
            LoggingJSONDecoder(
                keyDecodingStrategy: keyDecodingStrategy,
                dateDecodingStrategy: dateDecodingStrategy
            )
        }
    }

    override public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
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
