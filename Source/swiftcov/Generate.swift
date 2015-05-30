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

struct GenerateCommand: CommandType {
    typealias ClientError = SwiftCovError
    let verb = "generate"
    let function = "Generate test code coverage files for your Swift tests"

    func run(mode: CommandMode) -> Result<(), CommandantError<SwiftCovError>> {
        return GenerateOptions.evaluate(mode).flatMap { options in
            let arguments = Process.arguments
            if arguments.count < 4 {
                return .failure(.UsageError(description: "Usage: swiftcov generate [swiftcov options] xcodebuild [xcodebuild options]"))
            }
            let requiredArguments = [
                "xcodebuild",
                "test",
                "-configuration",
                "-sdk"
            ]
            for argument in requiredArguments {
                if find(arguments, argument) == nil {
                    return .failure(.UsageError(description: "'\(argument)' argument required"))
                }
            }

            println("Generate test code coverage files")
            println("Loading build settings...")

            var xcodebuild = Xcodebuild(argments: arguments)
            let result = xcodebuild.showBuildSettings()
                .map { BuildSettings(output: $0) }
                .flatMap { buildSettings -> Result<BuildSettings, TerminationStatus> in
                    println("Building target...")
                    return xcodebuild.buildExecutable().flatMap { _ in
                        return .success(buildSettings)
                    }
                }
                .flatMap { buildSettings -> Result<String, TerminationStatus> in
                    println("Generating code coverage...")
                    return GenerateCommand.runCoverageReport(options: options, settings: buildSettings)
            }

            switch result {
            case .Success:
                return .success()
            case let .Failure(error):
                return .failure(toCommandantError(.GenerateFailed))
            }
        }
    }

    static func runCoverageReport(#options: GenerateOptions, settings: BuildSettings) -> Result<String, TerminationStatus> {
        func buildSetting(key: String) -> String? {
            return settings.executable.buildSettings[key]
        }

        func testBundleBuildSetting(key: String) -> String? {
            return settings.testingBundles.first?.buildSettings[key]
        }

        if let sdkName = buildSetting("SDK_NAME"),
            let sdkroot = buildSetting("SDKROOT"),
            let builtProductsDir = testBundleBuildSetting("BUILT_PRODUCTS_DIR"),
            let fullProductName = testBundleBuildSetting("FULL_PRODUCT_NAME"),
            let srcroot = buildSetting("SRCROOT"),
            let objectFileDirNormal = buildSetting("OBJECT_FILE_DIR_normal"),
            let currentArch = buildSetting("CURRENT_ARCH"),
            let scriptPath = NSBundle(forClass: Shell.self).pathForResource("coverage", ofType: "py") {
                let targetPath = builtProductsDir.stringByAppendingPathComponent(fullProductName)
                let outputDir: String
                if options.output.isEmpty {
                    outputDir = objectFileDirNormal.stringByAppendingPathComponent(currentArch)
                } else {
                    let fileManager = NSFileManager.defaultManager()
                    var isDirectory: ObjCBool = false
                    if !fileManager.fileExistsAtPath(options.output, isDirectory: &isDirectory) || !isDirectory {
                        fileManager.createDirectoryAtPath(options.output, withIntermediateDirectories: true, attributes: nil, error: nil)
                    }
                    outputDir = options.output
                }

                return Shell(commandPath: "/usr/bin/xcode-select", arguments: ["--print-path"]).output()
                    .map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
                    .flatMap { xcodePath -> Result<String, TerminationStatus> in
                        let dyldFallbackFrameworkPath = "/Library/Frameworks:/Network/Library/Frameworks:/System/Library/Frameworks:\(xcodePath)/Platforms/iPhoneSimulator.platform/Developer/Library/PrivateFrameworks:\(xcodePath)/Library/PrivateFrameworks:\(xcodePath)/../OtherFrameworks:\(xcodePath)/../SharedFrameworks:\(xcodePath)/Library/Frameworks:\(xcodePath)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks"
                        let dyldFallbackLibraryPath = "\(xcodePath)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib"

                        let env = [
                            "SWIFTCOV_SDK_NAME": sdkName,
                            "SWIFTCOV_DYLD_FRAMEWORK_PATH": builtProductsDir,
                            "SWIFTCOV_DYLD_LIBRARY_PATH": builtProductsDir,
                            "SWIFTCOV_DYLD_FALLBACK_FRAMEWORK_PATH": dyldFallbackFrameworkPath,
                            "SWIFTCOV_DYLD_FALLBACK_LIBRARY_PATH": dyldFallbackLibraryPath,
                            "SWIFTCOV_DYLD_ROOT_PATH": sdkroot,
                            "SWIFTCOV_HIT_COUNT": "\(options.threshold)"
                        ]

                        return Shell(commandPath: "/usr/bin/python", arguments: [scriptPath, targetPath, srcroot, outputDir], environment: env).run()
                }
        }

        return Result(error: EXIT_FAILURE)
    }
}

struct GenerateOptions: OptionsType {
    let output: String
    let threshold: Int

    static func create(output: String)(threshold: Int) -> GenerateOptions {
        return self(output: output, threshold: threshold)
    }

    static func evaluate(m: CommandMode) -> Result<GenerateOptions, CommandantError<SwiftCovError>> {
        return create
            <*> m <| Option(key: "output", defaultValue: "", usage: "Folder to output the coverage files to")
            <*> m <| Option(key: "threshold", defaultValue: 0, usage: "Threshold value of max hit count (for performance)")
    }
}
