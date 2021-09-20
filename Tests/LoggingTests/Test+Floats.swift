import XCTest
@testable import Logging

final class FloatTests: XCTestCase {

    func testFloats() {
        let min: CGFloat = .leastNonzeroMagnitude
        let max: CGFloat = .greatestFiniteMagnitude
        let value: CGFloat = 3.14159265359
        let logging = TestLogging()
        LoggingSystem.bootstrapInternal(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\(min, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(CGFloat.leastNonzeroMagnitude)")

        logger.debug("\(max, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "\(CGFloat.greatestFiniteMagnitude)")

        logger.debug("\(value, format: .fixed(precision: 2), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "3.14")
    }

}
