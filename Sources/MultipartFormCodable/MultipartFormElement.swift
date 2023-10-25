//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

public enum MultipartFormElement {
    public struct File: Encodable {
        let filename: String
        let contentType: String
        let content: Data

        public init(filename: String, contentType: String, content: Data) {
            self.filename = filename
            self.contentType = contentType
            self.content = content
        }
    }

    case text(String)
    case file(File)
}
