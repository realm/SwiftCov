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
    let function = "Generate test code coverage files for your tests"

    func run(mode: CommandMode) -> Result<(), CommandantError<SwiftCovError>> {
        return GenerateOptions.evaluate(mode).flatMap { options in
            let arguments = Process.arguments
            if arguments.count < 4 {
                return .failure(toCommandantError(.InvalidArgument(description: "Usage: swiftcov [swiftcov options] xcodebuild [xcodebuild options]")))
            }
            if find(arguments, "xcodebuild") == nil {
                return .failure(toCommandantError(.InvalidArgument(description: "requied xcodebuild command")))
            }
            if find(arguments, "test") == nil {
                return .failure(toCommandantError(.InvalidArgument(description: "requied `test` action in xcodebuild command")))
            }
            if find(arguments, "-configuration") == nil {
                return .failure(toCommandantError(.InvalidArgument(description: "requied `-configuration` option in xcodebuild command")))
            }
            if find(arguments, "-sdk") == nil {
                return .failure(toCommandantError(.InvalidArgument(description: "requied `-sdk` option in xcodebuild command")))
            }

            var xcodebuild = Xcodebuild(argments: arguments)
            let result = xcodebuild.showBuildSettings()
                .map { BuildSettingsParser().buildSettingsFromOutput($0) }
                .map { buildSettings -> Result<String, TerminationStatus> in
                    xcodebuild.buildExecutable()
                    return GenerateCommand.runCoverageReport(options: options, settings: buildSettings) }
                .flatMap { $0 }

            switch result {
            case .Success:
                return .success()
            case let .Failure(error):
                return .failure(toCommandantError(.InvalidArgument(description: "Failed to execute xcode build command")))
            }
        }
    }

    static func runCoverageReport(#options: GenerateOptions, settings: BuildSettings) -> Result<String, TerminationStatus> {
        if let sdkName = settings.executable.buildSettings["SDK_NAME"],
            let sdkroot = settings.executable.buildSettings["SDKROOT"],
            let builtProductsDir = settings.testingBundles.first?.buildSettings["BUILT_PRODUCTS_DIR"],
            let fullProductName = settings.testingBundles.first?.buildSettings["FULL_PRODUCT_NAME"],
            let srcroot = settings.executable.buildSettings["SRCROOT"],
            let objectFileDirNormal = settings.executable.buildSettings["OBJECT_FILE_DIR_normal"],
            let currentArch = settings.executable.buildSettings["CURRENT_ARCH"],
            let scriptPath = NSBundle(forClass: Shell.self).pathForResource("coverage", ofType: "py") {
                let targetPath = builtProductsDir.stringByAppendingPathComponent(fullProductName)
                let outputDir: String
                if count(options.output) > 0 {
                    let fileManager = NSFileManager()
                    var isDirectory = ObjCBool(false)
                    if !fileManager.fileExistsAtPath(options.output, isDirectory: &isDirectory) || !isDirectory {
                        fileManager.createDirectoryAtPath(options.output, withIntermediateDirectories: true, attributes: nil, error: nil)
                    }
                    outputDir = options.output
                } else {
                    outputDir = objectFileDirNormal.stringByAppendingPathComponent(currentArch)
                }

                return Shell(commandPath: "/usr/bin/xcode-select", arguments: ["--print-path"]).output()
                    .map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
                    .map { xcodePath -> Result<String, TerminationStatus> in
                        let dyldFallbackFrameworkPath = "/Library/Frameworks:/Network/Library/Frameworks:/System/Library/Frameworks:\(xcodePath)/Platforms/iPhoneSimulator.platform/Developer/Library/PrivateFrameworks:\(xcodePath)/Library/PrivateFrameworks:\(xcodePath)/../OtherFrameworks:\(xcodePath)/../SharedFrameworks:\(xcodePath)/Library/Frameworks:\(xcodePath)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks"
                        let dyldFallbackLibraryPath = "\(xcodePath)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib"

                        var env = [String: String]()
                        env["SWIFTCOV_SDK_NAME"] = sdkName
                        env["SWIFTCOV_DYLD_FRAMEWORK_PATH"] = builtProductsDir
                        env["SWIFTCOV_DYLD_LIBRARY_PATH"] = builtProductsDir
                        env["SWIFTCOV_DYLD_FALLBACK_FRAMEWORK_PATH"] = dyldFallbackFrameworkPath
                        env["SWIFTCOV_DYLD_FALLBACK_LIBRARY_PATH"] = dyldFallbackLibraryPath
                        env["SWIFTCOV_DYLD_ROOT_PATH"] = sdkroot
                        env["SWIFTCOV_HIT_COUNT"] = "\(options.threshold)"

                        return Shell(commandPath: "/usr/bin/python", arguments: [scriptPath, targetPath, srcroot, outputDir], environment: env).run() }
                    .flatMap { $0 }
        }

        return Result(error: -1)
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
