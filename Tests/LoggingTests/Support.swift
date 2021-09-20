import Foundation
@testable import Logging

struct Mock: CustomStringConvertible {
    var description: String { "mock" }
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

final class Recorder {
    var message: String = ""

    func record(message: Logger.Message) {
        self.message = message.description
    }
}
