import Foundation

public struct DebugLogHandler: LogHandler {

    public struct Options {
        public var level: Logger.Level
        public var message: Logger.Message
        public var metadata: Logger.Metadata
        public var source: String
        public var file: String
        public var function: String
        public var line: UInt
    }

    public typealias Formatter = (Options) -> String

    public static let defaultFormat: Formatter = {
        var message = $0.message.description
        if !$0.metadata.isEmpty {
            message += " | " + $0.metadata.formatted
        }

        #if DEBUG
        return "\($0.level.formatted) \(message)"
        #else
        let filename = URL(fileURLWithPath: $0.file)
            .deletingPathExtension()
            .lastPathComponent

        return "\($0.level.formatted) \(message) | \(filename), \($0.line)"
        #endif
    }

    private let label: String
    private let formatter: Formatter
    public var logLevel: Logger.Level = .info
    public var metadata = Logger.Metadata()

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }

    public init(label: String, logLevel: Logger.Level = .trace) {
        self.init(label: label, logLevel: logLevel, formatter: Self.defaultFormat)
    }

    public init(label: String, logLevel: Logger.Level = .trace, formatter: @escaping Formatter) {
        self.label = label
        self.formatter = formatter
        self.logLevel = logLevel
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        var meta = self.metadata

        if let additional = metadata {
            meta.merge(additional) { $1 }
        }

        let options = Options(
            level: level,
            message: message,
            metadata: meta,
            source: source,
            file: file,
            function: function,
            line: line
        )

        print("\(timestamp()) [\(label)] \(formatter(options))")
    }

    private func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%Y-%m-%d %H:%M:%S", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }

}

private extension Logger.Metadata {
    var formatted: String {
        lazy
            .map { "\($0)=\($1)" }
            .joined(separator: " ")
    }
}

private extension Logger.Level {
    var formatted: String {
        switch self {
        case .trace:    return "􀁼"
        case .debug:    return "􀍷"
        case .info:     return "􀅴"
        case .notice:   return "􀒴"
        case .warning:  return "􀞟"
        case .error:    return "􀁠"
        case .critical: return "􀋧"
        }
    }
}
