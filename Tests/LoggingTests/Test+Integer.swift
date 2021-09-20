import XCTest
@testable import Logging

final class IntegerTests: XCTestCase {

    func testUnsigned() {
        let min: UInt64 = .min
        let max: UInt64 = .max
        let value: UInt64 = 100
        let logging = TestLogging()
        LoggingSystem.bootstrapInternal(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\(min, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(min)")

        logger.debug("\(max, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(max)")

        logger.debug("\(value, format: .decimal(minDigits: 6), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "000100")
    }

    func testSigned() {
        let min: Int64 = .min
        let max: Int64 = .max
        let value: Int64 = -100
        let logging = TestLogging()
        LoggingSystem.bootstrapInternal(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\(min, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(min)")

        logger.debug("\(max, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(max)")

        logger.debug("\(value, format: .decimal(minDigits: 6), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "-00100")
    }

}
