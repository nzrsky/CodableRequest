//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

extension String {
    public var camelCaseToSnakeCase: String {
        processCamelCaseRegex(pattern: "([A-Z]+)([A-Z][a-z]|[0-9])")
            .processCamelCaseRegex(pattern: "([a-z0-9])([A-Z])")
            .lowercased()
    }

    private func processCamelCaseRegex(pattern: StaticString) -> String {
        NSRegularExpression(pattern: pattern).stringByReplacingMatches(
            in: self,
            options: [],
            range: .init(location: 0, length: count),
            withTemplate: "$1_$2"
        )
    }
}

private extension NSRegularExpression {
    convenience init(pattern: StaticString, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: String(describing: pattern), options: options)
        } catch {
            fatalError("Invalid regex \(pattern). Error: \(error)")
        }
    }
}
