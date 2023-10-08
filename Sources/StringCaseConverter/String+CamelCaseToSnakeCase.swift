//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

extension String {
    public var camelCaseToSnakeCase: String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return processCamelCaseRegex(pattern: acronymPattern)
            .processCamelCaseRegex(pattern: normalPattern)
            .lowercased()
    }

    private func processCamelCaseRegex(pattern: String) -> String {
        let regex = (try? NSRegularExpression(pattern: pattern, options: []))
            ?? { fatalError("Invalid regex \(pattern)") }()
        let range = NSRange(location: 0, length: count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}
