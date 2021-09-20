import Foundation

@frozen public struct LogInterpolation: StringInterpolationProtocol {

    @usableFromInline enum Value {
        case literal(String)
        case string(() -> String, alignment: LogStringAlignment, privacy: LogPrivacy)
        case convertible(() -> CustomStringConvertible, alignment: LogStringAlignment, privacy: LogPrivacy)
        case signedInt(() -> Int64, format: LogIntegerFormatting, alignment: LogStringAlignment, privacy: LogPrivacy)
        case unsignedInt(() -> UInt64, format: LogIntegerFormatting, alignment: LogStringAlignment, privacy: LogPrivacy)
        case float(() -> Float, format: LogFloatFormatting, alignment: LogStringAlignment, privacy: LogPrivacy)
        case double(() -> Double, format: LogFloatFormatting, alignment: LogStringAlignment, privacy: LogPrivacy)
        case bool(() -> Bool, format: LogBoolFormat, privacy: LogPrivacy)
        case object(() -> NSObject, privacy: LogPrivacy)
        case meta(() -> Any.Type, alignment: LogStringAlignment, privacy: LogPrivacy)
    }

    private(set) var storage: [Value] = []
    public init() { }
    public init(literalCapacity: Int, interpolationCount: Int) { }

    /// Appends a literal segment to the interpolation.
    public mutating func appendLiteral(_ literal: String) {
        storage.append(.literal(literal))
    }
}

extension LogInterpolation {
    /// Defines interpolation for expressions of type String.
    public mutating func appendInterpolation(_ argumentString: @autoclosure @escaping () -> String, align: LogStringAlignment = .none, privacy: LogPrivacy = .private) {
        storage.append(.string(argumentString, alignment: align, privacy: privacy))
    }

    /// Defines interpolation for values conforming to CustomStringConvertible. The values
    /// are displayed using the description methods on them.
    public mutating func appendInterpolation<T>(_ value: @autoclosure @escaping () -> T, align: LogStringAlignment = .none, privacy: LogPrivacy = .private) where T: CustomStringConvertible {
        storage.append(.convertible(value, alignment: align, privacy: privacy))
    }
}

extension LogInterpolation {
    /// Defines interpolation for meta-types.
    public mutating func appendInterpolation(_ value: @autoclosure @escaping () -> Any.Type, align: LogStringAlignment = .none, privacy: LogPrivacy = .private) {
        storage.append(.meta(value, alignment: align, privacy: privacy))
    }

    /// Defines interpolation for expressions of type NSObject.
    public mutating func appendInterpolation(_ argumentObject: @autoclosure @escaping () -> NSObject, privacy: LogPrivacy = .private) {
        storage.append(.object(argumentObject, privacy: privacy))
    }
}

extension LogInterpolation {
    /// Defines interpolation for expressions of type Int
    public mutating func appendInterpolation<T: SignedInteger>(_ number: @autoclosure @escaping () -> T, format: LogIntegerFormatting = .decimal, align: LogStringAlignment = .none, privacy: LogPrivacy = .private) {
        storage.append(.signedInt({ Int64(number()) }, format: format, alignment: align, privacy: privacy))
    }

    /// Defines interpolation for expressions of type UInt
    public mutating func appendInterpolation<T: UnsignedInteger>(_ number: @autoclosure @escaping () -> T, format: LogIntegerFormatting = .decimal, align: LogStringAlignment = .none, privacy: LogPrivacy = .private) {
        storage.append(.unsignedInt({ UInt64(number()) }, format: format, alignment: align, privacy: privacy))
    }
}

extension LogInterpolation {
    /// Defines interpolation for expressions of type Float
    public mutating func appendInterpolation(_ number: @autoclosure @escaping () -> Float, format: LogFloatFormatting = .fixed, align: LogStringAlignment = .none, privacy: LogPrivacy = .private) {
        storage.append(.float(number, format: format, alignment: align, privacy: privacy))
    }

    /// Defines interpolation for expressions of type Double
    public mutating func appendInterpolation(_ number: @autoclosure @escaping () -> Double, format: LogFloatFormatting = .fixed, align: LogStringAlignment = .none, privacy: LogPrivacy = .private) {
        storage.append(.double(number, format: format, alignment: align, privacy: privacy))
    }
}

extension LogInterpolation {
    /// Defines interpolation for expressions of type Bool
    public mutating func appendInterpolation(_ boolean: @autoclosure @escaping () -> Bool, format: LogBoolFormat = .truth, privacy: LogPrivacy = .private) {
        storage.append(.bool(boolean, format: format, privacy: privacy))
    }
}

public enum LogBoolFormat {
    /// Displays an interpolated boolean value as true or false.
    case truth
    /// Displays an interpolated boolean value as yes or no.
    case answer
}

public struct LogStringAlignment {
    enum Alignment {
        case none
        case left(columns: () -> Int)
        case right(columns: () -> Int)
    }

    let alignment: Alignment

    public static var none: LogStringAlignment {
        LogStringAlignment(alignment: .none)
    }

    public static func right(columns: @autoclosure @escaping () -> Int) -> LogStringAlignment {
        LogStringAlignment(alignment: .right(columns: columns))
    }

    public static func left(columns: @autoclosure @escaping () -> Int) -> LogStringAlignment {
        LogStringAlignment(alignment: .left(columns: columns))
    }
}

public struct LogFloatFormatting {
    enum Format {
        case fixed(precision: () -> Int, explicitPositiveSign: Bool)
    }

    let format: Format

    public static var fixed: LogFloatFormatting {
        fixed(precision: 6, explicitPositiveSign: false)
    }

    public static func fixed(explicitPositiveSign: Bool = false) -> LogFloatFormatting {
        fixed(precision: 6, explicitPositiveSign: explicitPositiveSign)
    }

    public static func fixed(precision: @autoclosure @escaping () -> Int, explicitPositiveSign: Bool = false) -> LogFloatFormatting {
        LogFloatFormatting(format: .fixed(precision: precision, explicitPositiveSign: explicitPositiveSign))
    }
}

public struct LogIntegerFormatting {
    enum Format {
        case decimal(minDigits: () -> Int, explicitPositiveSign: Bool)
    }

    let format: Format

    public static var decimal: LogIntegerFormatting {
        decimal(explicitPositiveSign: false, minDigits: 0)
    }

    public static func decimal(explicitPositiveSign: Bool = false) -> LogIntegerFormatting {
        decimal(explicitPositiveSign: explicitPositiveSign, minDigits: 0)
    }

    public static func decimal(explicitPositiveSign: Bool = false, minDigits: @autoclosure @escaping () -> Int) -> LogIntegerFormatting {
        LogIntegerFormatting(format: .decimal(minDigits: minDigits, explicitPositiveSign: explicitPositiveSign))
    }
}

@frozen public struct LogPrivacy: Equatable {
    public enum Mask: Equatable {
        case hash
        case none
    }

    public var isPrivate: Bool
    private let mask: Mask?

    public static var `public`: LogPrivacy {
        LogPrivacy(isPrivate: false, mask: nil)
    }

    public static var `private`: LogPrivacy {
        LogPrivacy(isPrivate: true, mask: nil)
    }

    public static func `private`(mask: Mask) -> LogPrivacy {
        LogPrivacy(isPrivate: true, mask: mask)
    }

    internal static let redacted = "<redacted>"
    internal func value(for value: Any) -> String {
        #if DEBUG
        return String(describing: value)
        #else

        switch self {
        case .public:
            return String(describing: value)
        case .private(mask: .hash):
            return "\(String(describing: value).hash)"
        default:
            return Self.redacted
        }
        #endif
    }
}
