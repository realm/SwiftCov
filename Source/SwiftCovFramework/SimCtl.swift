//
//  SimCtl.swift
//  swiftcov
//
//  Created by Kishikawa Katsumi on 2015/06/04.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import Result

public struct SimCtl {
    private let verbose: Bool

    public init(verbose: Bool = false) {
        self.verbose = verbose
    }

    public func list() -> Result<String, TerminationStatus> {
        let command = Shell(commandPath: "/usr/bin/xcrun", arguments: ["simctl", "list"], verbose: verbose)
        return command.output()
    }

    public static func parseOutput(output: String) -> Result<([DeviceType], [Runtime], [Device]), TerminationStatus> {
        let whitespaceAndNewlineCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let lines: [String] = {
            var lines = [String]()
            output.enumerateLines { line, _ in
                lines.append(line.stringByTrimmingCharactersInSet(whitespaceAndNewlineCharacterSet))
            }
            return lines.filter { !$0.isEmpty }
            }()

        enum Mode {
            case DeviceType
            case Runtime
            case Device
        }

        var deviceTypes = [DeviceType]()
        var runtimes = [Runtime]()
        var devices = [Device]()

        var mode = Mode.DeviceType

        var target: String?
        var settings = [String: String]()
        for line in lines {
            switch line {
            case "== Device Types ==":
                mode = Mode.DeviceType
                continue
            case "== Runtimes ==":
                mode = Mode.Runtime
                continue
            case "== Devices ==":
                mode = Mode.Device
                continue
            default:
                break
            }

            switch mode {
            case .DeviceType:
                if let deviceType = DeviceType.parseLine(line) {
                    deviceTypes.append(deviceType)
                }
            case .Runtime:
                if let runtime = Runtime.parseLine(line) {
                    runtimes.append(runtime)
                }
            case .Device:
                if let device = Device.parseLine(line) {
                    devices.append(device)
                }
            }
        }

        return Result(value: (deviceTypes, runtimes, devices))
    }
}

public struct DeviceType {
    public let name: String
    public let identifier: String

    internal static func parseLine(line: String) -> DeviceType? {
        let regex = NSRegularExpression(pattern: "^(.+) \\((.+)\\)$", options: nil, error: nil)!
        let matches = regex.matchesInString(line, options: nil, range: NSRange(location: 0, length: (line as NSString).length))
        if matches.count == 1 {
            for match in matches {
                if let match = match as? NSTextCheckingResult {
                    let name = (line as NSString).substringWithRange(match.rangeAtIndex(1))
                    let identifier = (line as NSString).substringWithRange(match.rangeAtIndex(2))

                    return DeviceType(name: name, identifier: identifier)
                }
            }
        }
        return nil
    }
}

public struct Runtime {
    public let name: String
    public let build: String
    public let identifier: String

    internal static func parseLine(line: String) -> Runtime? {
        let regex = NSRegularExpression(pattern: "^(.+) \\((.+)\\) \\((.+)\\)$", options: nil, error: nil)!
        let matches = regex.matchesInString(line, options: nil, range: NSRange(location: 0, length: (line as NSString).length))
        if matches.count == 1 {
            for match in matches {
                if let match = match as? NSTextCheckingResult {
                    let name = (line as NSString).substringWithRange(match.rangeAtIndex(1))
                    let build = (line as NSString).substringWithRange(match.rangeAtIndex(2))
                    let identifier = (line as NSString).substringWithRange(match.rangeAtIndex(3))

                    return Runtime(name: name, build: build, identifier: identifier)
                }
            }
        }
        return nil
    }
}

public struct Device {
    public let iOSVersion: String
    public let UDID: String
    public let booted: Bool

    internal static func parseLine(line: String) -> Device? {
        let regex = NSRegularExpression(pattern: "^(.+) \\((.+)\\) \\((.+)\\)$", options: nil, error: nil)!
        let matches = regex.matchesInString(line, options: nil, range: NSRange(location: 0, length: (line as NSString).length))
        if matches.count == 1 {
            for match in matches {
                if let match = match as? NSTextCheckingResult {
                    let iOSVersion = (line as NSString).substringWithRange(match.rangeAtIndex(1))
                    let UDID = (line as NSString).substringWithRange(match.rangeAtIndex(2))
                    let state = (line as NSString).substringWithRange(match.rangeAtIndex(3))

                    return Device(iOSVersion: iOSVersion, UDID: UDID, booted: state == "Booted")
                }
            }
        }
        return nil
    }
}
