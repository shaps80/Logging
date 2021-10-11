import Foundation

/// A formatted log handler that allows user-configuration
public struct FormattedLogHandler: LogHandler {

    /// All associated data for a specific log event
    public struct Data {
        /// The log level for this event
        public var level: Logger.Level
        /// The label associated with this event
        public var label: String
        /// The message for this event, use `message.description` to get a string interpretation
        public var message: Logger.Message
        /// The metadata associated with this event
        public var metadata: Logger.Metadata
        /// The source of this event
        public var source: String
        /// The file where this event was logged
        public var file: String
        /// The function where this event was logged
        public var function: String
        /// The line of code where this event was logged
        public var line: UInt

        /// Returns an timestamp using the specified format, defaults to `%Y-%m-%d %H:%M:%S`
        /// - Parameter format: The format to return, defaults to `%Y-%m-%d %H:%M:%S` (Example: 2021-10-10 11:22:33)
        public func timestamp(format: String = "%Y-%m-%d %H:%M:%S") -> String {
            var buffer = [Int8](repeating: 0, count: 255)
            var timestamp = time(nil)
            let localTime = localtime(&timestamp)
            strftime(&buffer, buffer.count, format, localTime)
            return buffer.withUnsafeBufferPointer {
                $0.withMemoryRebound(to: CChar.self) {
                    String(cString: $0.baseAddress!)
                }
            }
        }
    }

    public typealias Formatter = (Data) -> String

    public static let defaultFormat: Formatter = {
        var message = $0.message.description
        if !$0.metadata.isEmpty {
            message += " | " + $0.metadata.formatted
        }

        #if DEBUG
        return "\($0.timestamp()) \($0.level.symbol) [\($0.label)] \(message)"
        #else
        let filename = URL(fileURLWithPath: $0.file)
            .deletingPathExtension()
            .lastPathComponent

        return "\($0.timestamp()) [\($0.label)] \($0.level.symbol) \(message) | \(filename), \($0.line)"
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

    /// A log handler with the specified label and minimum log level
    /// - Parameters:
    ///   - label: The associated label for this logger
    ///   - logLevel: The minimum log level to include
    public init(label: String, logLevel: Logger.Level = .trace) {
        self.init(label: label, logLevel: logLevel, formatter: Self.defaultFormat)
    }

    /// A log handler with the specified label, minimum log level and associated formatter
    /// - Parameters:
    ///   - label: The associated label for this logger
    ///   - logLevel: The minimum log level to include
    ///   - formatter: The formatter to use for formatting log data
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

        let options = Data(
            level: level,
            label: label,
            message: message,
            metadata: meta,
            source: source,
            file: file,
            function: function,
            line: line
        )

        print(formatter(options))
    }

}

private extension Logger.Metadata {
    var formatted: String {
        lazy
            .map { "\($0)=\($1)" }
            .joined(separator: " ")
    }
}

public extension Logger.Level {
    var symbol: String {
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
