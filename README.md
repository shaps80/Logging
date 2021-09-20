![ios](https://img.shields.io/badge/iOS-13-green)
![tv](https://img.shields.io/badge/tvOS-13-green)
![watch](https://img.shields.io/badge/watchOS-6-green)
![mac](https://img.shields.io/badge/macOS-10.15-green)

# Logging

A version of Apple's [SwiftLog](https://github.com/apple/swift-log) that adds some improved formatting for app development and includes OSLog-ish string interpolation.

> Note: the performance characteristics of this library should be similar or faster than general `print` statements.

__Feature List__

- [x] ~~Privacy (public, private and masked)~~
- [x] ~~Log levels~~
- [x] ~~FormattedLogHandler~~
- [x] ~~Boolean formats~~
- [ ] Column formats
- [ ] Exponential formats
- [ ] Hexadecimal formats

> I've also added many tests to ensure the string interpolation and privacy features are working as expected. However, I have not included any of SwiftLog's tests since the library is simply a _direct copy_ (see below).

## Examples

```swift
// Somewhere in your code, define your log handler(s)
LoggingSystem.bootstrap { label in 
	FormattedLogHandler(label: label)
}

// Then in a framework or subsystem, define a logger
let logger = Logger(label: "com.benkau.logging")
logger.debug("Hello, world!")
```

Similar to OSLog, all interpolated values default to a `private` scope (in a non-`DEBUG`) environment, with their values redacted.

```swift
logger.debug("Logged in as \(user, privacy: .private)")
// Logged in as <redacted>
```

In addition to allow for simplied lookup of like-values, we can use another OSLog API:

```swift
logger.debug("Fetching data from \(url, privacy: .private(.hash))")
// Fetching data from 210237823
```

OSLog also provides convenience around printing numerical values, while the entire API is not _yet_ supported (contributions welcome), the most common ones are:

```swift
logger.debug("Pi is \(3.14159265359, format: .fixed(precision: 2))")
// Pi is 3.14
```

## Formatting

The library includes a custom `FormattedLogHandler` that you're free to use or create your own. The provided handler uses SFSymbols to improve readability and clarity in the console, as well as providing a simple closure based formatter so you can make it your own.

```swift
FormattedLogHandler { options in 
	// simply return your formatted log
	FormattedLogHandler(label: label) { data in
        "\(data.timestamp()) [\(data.label)] \(data.level.symbol) \(data.message)"
    }
}
```

> Obviously you can always use your own `LogHandler` as you can directly with SwiftLog.

## SwiftLog

The actual logging framework is a _direct copy_ of Apple's own SwiftLog. The reason I didn't include it as a dependency is because there was no way for me to _extend_ it to include string interpolation that I could see. If anyone has ideas on how to make this work, I would love to hear about them. Please open an Issue so we can discuss it as this would allow me to properly attribute and pin to a dependency version etc...

## Installation

The code is packaged as a framework. You can install manually (by copying the files in the `Sources` directory) or using Swift Package Manager (**preferred**)

To install using Swift Package Manager, add this to the `dependencies` section of your `Package.swift` file:

`.package(url: "https://github.com/shaps80/Logging.git", .upToNextMinor(from: "1.0.0"))`
