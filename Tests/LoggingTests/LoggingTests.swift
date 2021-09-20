import XCTest
@testable import Logging

final class TFFoundationTests: XCTestCase {

    func testPrivacy() {
        let logging = TestLogging()
        LoggingSystem.bootstrap(logging.make)

        var logger = Logger(label: "test")
        logger.logLevel = .trace

        logger.debug("\("name")")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(0)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(0, format: .decimal(minDigits: 0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(0, format: .decimal(explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(0, format: .decimal(explicitPositiveSign: true, minDigits: 0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(0.0)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(0.0, format: .fixed)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(0.0, format: .fixed(precision: 1))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(0.0, format: .fixed(explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(0.0, format: .fixed(precision: 1, explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(true)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(true, format: .answer)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(true, format: .truth)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(true, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "true")
        logger.debug("\(true, format: .answer, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "yes")
        logger.debug("\(true, format: .truth, privacy: .public)")
        XCTAssertEqual(logging.recorder.message, "true")

        logger.debug("\(Mock())")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(Mock.self)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(NSObject())")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(UInt(0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(UInt(0), format: .decimal(minDigits: 0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(UInt(0), format: .decimal(explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(UInt(0), format: .decimal(explicitPositiveSign: true, minDigits: 0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)

        logger.debug("\(Double(0.0))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(Double(0.0), format: .fixed)")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(Double(0.0), format: .fixed(precision: 1))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(Double(0.0), format: .fixed(explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
        logger.debug("\(Double(0.0), format: .fixed(precision: 1, explicitPositiveSign: true))")
        XCTAssertEqual(logging.recorder.message, LogPrivacy.redacted)
    }

}

struct Mock: CustomStringConvertible {
    var description: String { "secret" }
}

extension LoggingSystem {
    static func bootstrapTest(_ factory: @escaping (String) -> LogHandler) {
        bootstrap(factory)
    }
}

struct TestLogHandler: LogHandler {
    var metadata = Logger.Metadata()
    var logLevel: Logger.Level = .trace
    var label: String

    private let recorder: Recorder

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }

    init(label: String, recorder: Recorder) {
        self.label = label
        self.recorder = recorder
    }

    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        recorder.record(message: message)
    }
}

struct TestLogging {
    let recorder = Recorder()

    func make(label: String) -> LogHandler {
        TestLogHandler(label: label, recorder: recorder)
    }
}

class Recorder {
    var message: String = ""

    func record(message: Logger.Message) {
        self.message = message.description
    }
}
