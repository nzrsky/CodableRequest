//
//  Please refer to the LICENSE file for licensing information.
//

public extension ErrorBody {
    typealias Status400 = ErrorBodyWrapper<Body, ValidateStatus400ErrorBodyStrategy>
    typealias Status401 = ErrorBodyWrapper<Body, ValidateStatus401ErrorBodyStrategy>
    typealias Status403 = ErrorBodyWrapper<Body, ValidateStatus403ErrorBodyStrategy>
    typealias Status404 = ErrorBodyWrapper<Body, ValidateStatus404ErrorBodyStrategy>
    typealias Status410 = ErrorBodyWrapper<Body, ValidateStatus410ErrorBodyStrategy>
    typealias Status422 = ErrorBodyWrapper<Body, ValidateStatus422ErrorBodyStrategy>
}
