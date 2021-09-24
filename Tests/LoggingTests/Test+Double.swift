import XCTest
@testable import Logging

final class DoubleTests: XCTestCase {

    func testDouble() {
        let min: Double = .leastNonzeroMagnitude
        let max: Double = .greatestFiniteMagnitude
        let value: Double = 3.14159265359
        let logging = TestLogging()
        LoggingSystem.bootstrapInternal(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\(min, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, String(format: "%.06f", Double.leastNonzeroMagnitude))

        logger.debug("\(max, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, String(format: "%.06f", Double.greatestFiniteMagnitude))

        logger.debug("\(value, format: .fixed(precision: 2), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "3.14")
    }

}
