//
//  Xcodebuild.swift
//  swiftcov
//
//  Created by Kishikawa Katsumi on 2015-05-26.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import Result

public struct Xcodebuild {
    public var arguments: [String]

    public init(argments args: [String]) {
        arguments = Array(split(args, allowEmptySlices: true) { $0 == "xcodebuild" }[1])
    }

    public mutating func exchangeArgumentAtIndex(index: Int, argument: String) {
        arguments[index] = argument
    }

    public mutating func addArgument(argument: String) {
        arguments.append(argument)
    }

    public func showBuildSettings() -> Result<String, TerminationStatus> {
        let command = Shell(commandPath: "/usr/bin/xcrun", arguments: ["xcodebuild", "-showBuildSettings"] + arguments)
        return command.output()
    }

    public func buildExecutable() -> Result<String, TerminationStatus> {
        let command = Shell(commandPath: "/usr/bin/xcrun", arguments: ["xcodebuild", "SWIFT_OPTIMIZATION_LEVEL=-Onone", "ONLY_ACTIVE_ARCH=NO"] + arguments)
        return command.output()
    }
}
