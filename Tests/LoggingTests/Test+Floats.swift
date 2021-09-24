import XCTest
@testable import Logging

final class FloatTests: XCTestCase {

    func testCGFloats() {
        let min: CGFloat = .leastNonzeroMagnitude
        let max: CGFloat = .greatestFiniteMagnitude
        let value: CGFloat = 3.14159265359
        let logging = TestLogging()
        LoggingSystem.bootstrapInternal(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\(min, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, String(format: "%.06f", CGFloat.leastNonzeroMagnitude))

        logger.debug("\(max, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, String(format: "%.06f", CGFloat.greatestFiniteMagnitude))

        logger.debug("\(value, format: .fixed(precision: 2), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "3.14")
    }

    func testFloats() {
        let min: Float = .leastNonzeroMagnitude
        let max: Float = .greatestFiniteMagnitude
        let value: Float = 3.14159265359
        let logging = TestLogging()
        LoggingSystem.bootstrapInternal(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\(min, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, String(format: "%.06f", Float.leastNonzeroMagnitude))

        logger.debug("\(max, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, String(format: "%.06f", Float.greatestFiniteMagnitude))

        logger.debug("\(value, format: .fixed(precision: 2), privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "3.14")
    }

}
