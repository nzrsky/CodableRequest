//
//  Please refer to the LICENSE file for licensing information.
//

class RequestSingleValueEncodingContainer: SingleValueEncodingContainer {
    let encoder: RequestEncoding
    var codingPath: [CodingKey]

    init(encoder: RequestEncoding, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }

    func encodeNil() throws {
        fatalError("not supported")
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        fatalError("not supported")
    }
}
