//
//  IntegrationTests.swift
//  swiftcov
//
//  Created by Kishikawa Katsumi on 2015/05/31.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import XCTest
import SwiftCovFramework

class CoverageReporterTests: XCTestCase {
    let reportFilenames = ["Calculator.swift.gcov", "Networking.swift.gcov"]
    var fixtureFilePaths: [String] {
        return reportFilenames.map { "./Examples/ExampleFramework/results/" + $0 }
    }

    func testGenerateCoverageReportIOS() {
        let temporaryDirectory = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(NSProcessInfo().globallyUniqueString)
        _ = try? NSFileManager().createDirectoryAtPath(temporaryDirectory, withIntermediateDirectories: true, attributes: nil)

        let reporter = CoverageReporter(outputDirectory: temporaryDirectory, threshold: 0)

        NSFileManager.defaultManager().changeCurrentDirectoryPath((((__FILE__ as NSString).stringByDeletingLastPathComponent as NSString).stringByDeletingLastPathComponent as NSString).stringByDeletingLastPathComponent)
        let xcodebuild = Xcodebuild(arguments: ["test",
                                                "-project", "./Examples/ExampleFramework/ExampleFramework.xcodeproj",
                                                "-scheme", "ExampleFramework-iOS",
                                                "-configuration", "Release",
                                                "-sdk", "iphonesimulator",
                                                "-derivedDataPath", temporaryDirectory])
        switch xcodebuild.showBuildSettings() {
        case let .Success(output):
            let buildSettings = BuildSettings(output: output)

            switch xcodebuild.buildExecutable() {
            case .Success:
                switch reporter.runCoverageReport(buildSettings: buildSettings) {
                case .Success:
                    Array(zip(reportFilenames, fixtureFilePaths))
                        .map { (reportFilename, fixtureFilePath) -> (String, String) in
                            return ((temporaryDirectory as NSString).stringByAppendingPathComponent(reportFilename), fixtureFilePath)
                        }
                        .forEach { (reportFilePath, fixtureFilePath) in
                            XCTAssertEqual(
                                ((try! NSString(contentsOfFile: reportFilePath, encoding: NSUTF8StringEncoding)) as String).characters.split { $0 == "\n" }.map { String($0) }.dropFirst(),
                                ((try! NSString(contentsOfFile: fixtureFilePath, encoding: NSUTF8StringEncoding)) as String).characters.split { $0 == "\n" }.map { String($0) }.dropFirst())
                    }
                case let .Failure(error):
                    XCTAssertNotEqual(error, EXIT_SUCCESS)
                    XCTFail("Execution failure")
                }
            case let .Failure(error):
                XCTAssertNotEqual(error, EXIT_SUCCESS)
                XCTFail("Execution failure")
            }
        case let .Failure(error):
            XCTAssertNotEqual(error, EXIT_SUCCESS)
            XCTFail("Execution failure")
        }
    }

    func testGenerateCoverageReportOSX() {
        let temporaryDirectory = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(NSProcessInfo().globallyUniqueString)
        _ = try? NSFileManager().createDirectoryAtPath(temporaryDirectory, withIntermediateDirectories: true, attributes: nil)

        let reporter = CoverageReporter(outputDirectory: temporaryDirectory, threshold: 0)

        NSFileManager.defaultManager().changeCurrentDirectoryPath((((__FILE__ as NSString).stringByDeletingLastPathComponent as NSString).stringByDeletingLastPathComponent as NSString).stringByDeletingLastPathComponent)
        let xcodebuild = Xcodebuild(arguments: ["test",
                                                "-project", "./Examples/ExampleFramework/ExampleFramework.xcodeproj",
                                                "-scheme", "ExampleFramework-Mac",
                                                "-configuration", "Release",
                                                "-sdk", "macosx",
                                                "-derivedDataPath", temporaryDirectory])
        switch xcodebuild.showBuildSettings() {
        case let .Success(output):
            let buildSettings = BuildSettings(output: output)
            
            switch xcodebuild.buildExecutable() {
            case .Success:
                switch reporter.runCoverageReport(buildSettings: buildSettings) {
                case .Success:
                    Array(zip(reportFilenames, fixtureFilePaths))
                        .map { (reportFilename, fixtureFilePath) -> (String, String) in
                            return ((temporaryDirectory as NSString).stringByAppendingPathComponent(reportFilename), fixtureFilePath)
                        }
                        .forEach { (reportFilePath, fixtureFilePath) in
                            XCTAssertEqual(
                                ((try! NSString(contentsOfFile: reportFilePath, encoding: NSUTF8StringEncoding)) as String).characters.split { $0 == "\n" }.map { String($0) }.dropFirst(),
                                ((try! NSString(contentsOfFile: fixtureFilePath, encoding: NSUTF8StringEncoding)) as String).characters.split { $0 == "\n" }.map { String($0) }.dropFirst())
                    }
                case let .Failure(error):
                    XCTAssertNotEqual(error, EXIT_SUCCESS)
                    XCTFail("Execution failure")
                }
            case let .Failure(error):
                XCTAssertNotEqual(error, EXIT_SUCCESS)
                XCTFail("Execution failure")
            }
        case let .Failure(error):
            XCTAssertNotEqual(error, EXIT_SUCCESS)
            XCTFail("Execution failure")
        }
    }

}
