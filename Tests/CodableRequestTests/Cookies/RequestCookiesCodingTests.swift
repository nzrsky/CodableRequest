//
//  Please refer to the LICENSE file for licensing information.
//

// swiftlint:disable force_unwrapping
@testable import CodableRequest
import XCTest

class CookiesCodingTests: XCTestCase {
    let baseURL = URL(string: "https://local.url")!
    let cookies = [
        HTTPCookie(properties: [
            .domain: "local.url",
            .path: "/some/path",
            .name: "key",
            .value: "value"
        ])!
    ]

    func testEncoding_cookies_shouldBeSetInHeaders() {
        struct Req: Request {
            typealias Response = EmptyResponse
            @Cookies var cookies
        }

        var request = Req()
        request.cookies = cookies

        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encode(request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.value(forHTTPHeaderField: "Cookie"), "key=value")
    }

    func testEncoding_emptyCookiesCustomHeader_shouldNotAffectExistingCookieHeaders() {
        struct Req: Request {
            typealias Response = EmptyResponse
            @Cookies var cookies
            @Header(name: "Cookie") var cookieHeader
        }

        var request = Req()
        request.cookieHeader = "some header"

        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encode(request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.value(forHTTPHeaderField: "Cookie"), "some header")
    }

    func testEncoding_cookiesAndCustomHeaders_shouldBeMergedIntoHeaders() {
        struct Req: Request {
            typealias Response = EmptyResponse
            @Cookies var cookies
            @Header(name: "Some-Header") var someHeader
        }

        var request = Req()
        request.cookies = cookies
        request.someHeader = "some header"

        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encode(request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.value(forHTTPHeaderField: "Cookie"), "key=value")
        XCTAssertEqual(encoded.value(forHTTPHeaderField: "Some-Header"), "some header")
    }

    func testEncoding_cookiesCustomHeader_shouldBeOverwrittenByCustomHeaders() {
        struct Req: Request {
            typealias Response = EmptyResponse
            @Cookies var cookies
            @Header(name: "Cookie") var cookieHeader
        }

        var request = Req()
        request.cookies = cookies
        request.cookieHeader = "some header"

        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encode(request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.value(forHTTPHeaderField: "Cookie"), "some header")
    }
}

// swiftlint:enable force_unwrapping
