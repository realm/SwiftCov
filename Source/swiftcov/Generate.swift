//
//  GenerateCommand.swift
//  SwiftCov
//
//  Created by JP Simard on 2015-05-20.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Commandant
import Result
import SwiftCovFramework

extension NSString {
    /**
    Returns self represented as an absolute path.

    - parameter rootDirectory: Absolute parent path if not already an absolute path.
    */
    public func absolutePathRepresentation(rootDirectory: String = NSFileManager.defaultManager().currentDirectoryPath) -> String {
        if absolutePath {
            return self as String
        }
        return (NSString.pathWithComponents([rootDirectory, self as String]) as NSString).stringByStandardizingPath
    }
}

struct GenerateCommand: CommandType {
    let verb = "generate"
    let function = "Generate test code coverage files for your Swift tests"

    func run(options: GenerateOptions) -> Result<(), SwiftCovError> {
        let arguments = Process.arguments
        if arguments.count < 4 {
            return .Failure(.InvalidArgument(description: "Usage: swiftcov generate [swiftcov options] xcodebuild [xcodebuild options] (-- [swift files])"))
        }
        let requiredArguments = [
            "xcodebuild",
            "test",
            "-configuration",
            "-sdk"
        ]
        for argument in requiredArguments {
            if arguments.indexOf(argument) == nil {
                return .Failure(.InvalidArgument(description: "'\(argument)' argument required"))
            }
        }

        print("Generate test code coverage files")
        print("Loading build settings...")

        let doubleDashSplit = arguments.split("--", maxSplit: Int.max, allowEmptySlices: true)
        let afterDoubleDash = (doubleDashSplit.count == 2 ? true : Optional<Bool>.None).flatMap { _ in Array(doubleDashSplit[1]) }
        let files = afterDoubleDash.map { nonOptionalAfterDoubleDash in
            return nonOptionalAfterDoubleDash.map {
                ($0 as NSString).absolutePathRepresentation()
            }
        }
        let beforeDoubleDash = Array(doubleDashSplit[0])
        let xcodeBuildArguments = Array(beforeDoubleDash.split("xcodebuild", maxSplit: Int.max, allowEmptySlices: true)[1])

        let xcodebuild = Xcodebuild(arguments: xcodeBuildArguments, verbose: options.debug)
        let result = xcodebuild.showBuildSettings()
            .map { BuildSettings(output: $0) }
            .flatMap { buildSettings -> Result<BuildSettings, TerminationStatus> in
                print("Building target...")
                return xcodebuild.buildExecutable().flatMap { _ in
                    return .Success(buildSettings)
                }
            }
            .flatMap { buildSettings -> Result<String, TerminationStatus> in
                print("Generating code coverage...")
                let coverageReporter = CoverageReporter(outputDirectory: options.output, threshold: options.threshold, verbose: options.debug, files: files)
                return coverageReporter.runCoverageReport(buildSettings: buildSettings)
        }

        switch result {
        case .Success:
            return .Success()
        case .Failure(_):
            return .Failure(.GenerateFailed)
        }
    }
}

struct GenerateOptions: OptionsType {
    let output: String
    let threshold: Int
    let debug: Bool

    static func create(output: String)(threshold: Int)(debug: Bool) -> GenerateOptions {
        return self.init(output: output, threshold: threshold, debug: debug)
    }

    static func evaluate(m: CommandMode) -> Result<GenerateOptions, CommandantError<SwiftCovError>> {
        return create
            <*> m <| Option(key: "output", defaultValue: "", usage: "Folder to output the coverage files to")
            <*> m <| Option(key: "threshold", defaultValue: 1, usage: "Threshold value of max hit count (for performance)")
            <*> m <| Option(key: "debug", defaultValue: false, usage: "Output very verbose progress messages")
    }
}
