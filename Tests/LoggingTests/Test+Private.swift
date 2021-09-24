import XCTest
@testable import Logging

final class PrivateTests: XCTestCase {

    func testPrivate() {
        #if DEBUG
        XCTFail("\n\n   *** Tests for Redaction must be run in release build.  Use `swift test -c release` from the command line.\n")
        #endif
        
        let signed = -3.14159265359
        let unsigned = 3.14
        let logging = TestLogging()
        LoggingSystem.bootstrapInternal(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\("name")")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(signed, privacy: .private)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(signed, format: .fixed(precision: 0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(signed, format: .fixed(explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(signed, format: .fixed(precision: 0, explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(signed)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(signed, format: .fixed)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(signed, format: .fixed(precision: 1))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(signed, format: .fixed(explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(signed, format: .fixed(precision: 1, explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(true)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(true, format: .answer)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(true, format: .truth)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(Mock())")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(Mock.self)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(NSObject())")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(UInt(unsigned))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(UInt(unsigned), format: .decimal(minDigits: 0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(UInt(unsigned), format: .decimal(explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(UInt(unsigned), format: .decimal(explicitPositiveSign: true, minDigits: 0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
    }

}
