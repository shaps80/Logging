import XCTest
@testable import Logging

final class PublicTests: XCTestCase {

    func testPublic() {
        let signed = -3.14159265359
        let unsigned = 3.14159265359
        let logging = TestLogging()
        LoggingSystem.bootstrapInternal(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\("name", privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "name")

        logger.debug("\(signed, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(String(format: "%.6f", signed))")
        logger.debug("\(signed, format: .fixed(precision: 0), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "-3")
        logger.debug("\(unsigned, format: .fixed(explicitPositiveSign: true), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "+\(String(format: "%.6f", unsigned))")
        logger.debug("\(unsigned, format: .fixed(precision: 11, explicitPositiveSign: true), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "+\(unsigned)")

        logger.debug("\(signed, format: .fixed, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(String(format: "%.6f", signed))")
        logger.debug("\(signed, format: .fixed(precision: 1), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(String(format: "%.1f", signed))")
        logger.debug("\(unsigned, format: .fixed(explicitPositiveSign: true), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "+\(String(format: "%.6f", unsigned))")
        logger.debug("\(unsigned, format: .fixed(precision: 1, explicitPositiveSign: true), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "+\(String(format: "%.1f", unsigned))")

        logger.debug("\(true, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "true")
        logger.debug("\(true, format: .answer, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "yes")
        logger.debug("\(true, format: .truth, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "true")

        logger.debug("\(Mock(), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "mock")
        logger.debug("\(Mock.self, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, String(describing: Mock.self))

        logger.debug("\(UInt(unsigned), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(UInt(unsigned))")
        logger.debug("\(UInt(unsigned), format: .decimal(minDigits: 2), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, String(format: "%02lu", UInt(unsigned)))
        logger.debug("\(UInt(unsigned), format: .decimal(explicitPositiveSign: true), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "+\(String(format: "%lu", UInt(unsigned)))")
        logger.debug("\(UInt(unsigned), format: .decimal(explicitPositiveSign: true, minDigits: 0), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "+\(String(format: "%0lu", UInt(unsigned)))")
    }

}
