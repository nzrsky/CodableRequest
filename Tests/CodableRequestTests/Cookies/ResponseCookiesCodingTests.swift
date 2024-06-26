//
//  Please refer to the LICENSE file for licensing information.
//

// swiftlint:disable force_unwrapping

@testable import CodableRequest
import XCTest

private struct Response: Decodable {
    @ResponseCookies var cookies
}

class ResponseCookiesCodingTests: XCTestCase {
    let response = HTTPURLResponse(url: URL(string: "https://example.local")!, statusCode: 200, httpVersion: nil, headerFields: [
        // swiftlint:disable:next line_length
        "Set-Cookie": "UserSession=xyz123; Domain=example.local; Path=/some/path; Expires=Wed, 06 Dec 2023 09:38:21 GMT; Max-Age=3600; Secure; HttpOnly; SameSite=Strict"
    ])!
    let cookie = HTTPCookie(properties: [
        .version: "0",
        .name: "UserSession",
        .value: "xyz123",
        .domain: "example.local",
        .path: "/some/path",

        .expires: Date(timeIntervalSince1970: 1_701_859_806),
        .maximumAge: "3600",

        .secure: true,
        .sameSitePolicy: "Strict"
    ])!

    func testDecoding_defaultStrategy_shouldDecodeCaseInSensitiveResponseHeaders() {
        let decoder = TestResponseDecoder()
        guard let decoded = try checkNoThrow(decoder.decode(Response.self, from: (Data(), response))) else {
            return
        }
        XCTAssertEqual(decoded.cookies.first?.name, "UserSession")
        XCTAssertEqual(decoded.cookies.first?.value, "xyz123")
    }
}

// swiftlint:enable force_unwrapping
