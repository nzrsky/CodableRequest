//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import StringCaseConverter

// swiftlint:disable:next type_name
final class String_CamelCaseFromSnakeCaseTests: XCTestCase {

    func testConversion_leadingUnderscore_shouldBePreserved() {
        XCTAssertEqual("_one_two_three".camelCaseFromSnakeCase, "_oneTwoThree")
    }

    func testConversion_multipleLeadingUnderscores_shouldBePreserved() {
        XCTAssertEqual("___one_two_three".camelCaseFromSnakeCase, "___oneTwoThree")
    }

    func testConversion_trailingUnderscore_shouldBePreserved() {
        XCTAssertEqual("one_two_three_".camelCaseFromSnakeCase, "oneTwoThree_")
    }

    func testConversion_multipleTrailingUnderscore_shouldBePreserved() {
        XCTAssertEqual("one_two_three___".camelCaseFromSnakeCase, "oneTwoThree___")
    }

    func testConversion_leadingTrailingUnderscore_shouldBePreserved() {
        XCTAssertEqual("_one_two_three_".camelCaseFromSnakeCase, "_oneTwoThree_")
    }

    func testConversion_multipleLeadingTrailingUnderscore_shouldBePreserved() {
        XCTAssertEqual("___one_two_three___".camelCaseFromSnakeCase, "___oneTwoThree___")
    }

    func testConversion_noUnderscores_shouldBeginLowercased() {
        XCTAssertEqual("Word".camelCaseFromSnakeCase, "word")
    }

    func testConversion_shouldBeginLowercasedCamel() {
        XCTAssertEqual("one_two_three".camelCaseFromSnakeCase, "oneTwoThree")
    }

    func testSpeed_camelCaseFromSnakeCase() {
        measure {
            XCTAssertEqual("1234_this_is_a_test1234_this_is_a_test1234_this_is_a_test1234_this_is_a_test_sdlm_dmsdd_ssdsd_ddd_dsds_ffff_fsdsds_sds_msm_mmm_ss".camelCaseFromSnakeCase,
                           "1234ThisIsATest1234ThisIsATest1234ThisIsATest1234ThisIsATestSdlmDmsddSsdsdDddDsdsFfffFsdsdsSdsMsmMmmSs")
        }
    }
}
