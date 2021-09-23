import Foundation

extension Logger {
    public struct Message: ExpressibleByStringInterpolation, ExpressibleByStringLiteral, CustomStringConvertible {
        public var interpolation: LogInterpolation

        public init(stringLiteral value: String) {
            interpolation = LogInterpolation()
            interpolation.appendLiteral(value)
        }

        public init(stringInterpolation: LogInterpolation) {
            interpolation = stringInterpolation
        }

        public var description: String {
            var message = ""

            for value in interpolation.storage {
                switch value {
                case let .literal(value):
                    message.append(value)
                case let .bool(value, format, privacy):
                    switch format {
                    case .answer:
                        message.append(privacy.value(for: value() ? "yes" : "no"))
                    case .truth:
                        message.append(privacy.value(for: value() ? "true" : "false"))
                    }
                case let .convertible(value, _, privacy):
                    message.append(privacy.value(for: value().description))
                case let .double(value, format, _, privacy):
                    switch format.format {
                    case let .fixed(precision, explicitPositiveSign):
                        let value = value()
                        let string = String(format: "\(explicitPositiveSign ? "+" : "")%.0\(precision())f", value)
                        message.append(privacy.value(for: string))
                    }
                case let .float(value, format, _, privacy):
                    switch format.format {
                    case let .fixed(precision, explicitPositiveSign):
                        let value = value()
                        let string = String(format: "\(explicitPositiveSign ? "+" : "")%.0\(precision())f", value)
                        message.append(privacy.value(for: string))
                    }
                case let .cgfloat(value, format, _, privacy):
                    switch format.format {
                    case let .fixed(precision, explicitPositiveSign):
                        let value = value()
                        let string = String(format: "\(explicitPositiveSign ? "+" : "")%.0\(precision())f", value)
                        message.append(privacy.value(for: string))
                    }
                case let .signedInt(value, format, _, privacy):
                    switch format.format {
                    case let .decimal(minDigits, explicitPositiveSign):
                        let value = value()
                        let string = String(format: "\(explicitPositiveSign ? "+" : "")%0\(minDigits())ld", value)
                        message.append(privacy.value(for: string))
                    }
                case let .unsignedInt(value, format, _, privacy):
                    switch format.format {
                    case let .decimal(minDigits, explicitPositiveSign):
                        let value = String(format: "\(explicitPositiveSign ? "+" : "")%0\(minDigits())lu", value())
                        message.append(privacy.value(for: value))
                    }
                case let .meta(value, _, privacy):
                    message.append(privacy.value(for: String(describing: value())))
                case let .object(value, privacy):
                    message.append(privacy.value(for: value()))
                case let .string(value, _, privacy):
                    message.append(privacy.value(for: value()))
                }
            }

            return message
        }

    }
}
