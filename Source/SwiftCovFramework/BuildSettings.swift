//
//  BuildSettings.swift
//  swiftcov
//
//  Created by Kishikawa Katsumi on 2015-05-26.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation

public struct BuildSettings {
    public let executable: Executable
    public let testingBundles: [TestingBundle]
}

public struct Executable {
    public let name: String
    public let buildSettings: [String: String]
}

public struct TestingBundle {
    public let name: String
    public let buildSettings: [String: String]
}

public class BuildSettingsParser {

    public init() { }

    public func buildSettingsFromOutput(output: String) -> BuildSettings {
        var executable: Executable = Executable(name: "", buildSettings: [String: String]())
        var bundles = [TestingBundle]()

        for (target, settings) in parseOutput(output) {
            if let productType = settings["PRODUCT_TYPE"] {
                if productType == "com.apple.product-type.bundle.unit-test" {
                    bundles.append(TestingBundle(name: target, buildSettings: settings))
                } else {
                    executable = Executable(name: target, buildSettings: settings)
                }
            }
        }

        return BuildSettings(executable: executable, testingBundles: bundles)
    }

    private func parseOutput(output: String) -> [String: [String: String]] {
        let lines = split(output) { $0 == "\n" }
            .map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }

        var target: String?
        var settings = [String: [String: String]]()
        for line in lines {
            let regex = NSRegularExpression(pattern: "^Build settings for action .+ and target (.+):$", options: nil, error: nil)!
            let matches = regex.matchesInString(line, options: nil, range: NSRange(location: 0, length: (line as NSString).length))
            if matches.count == 1 {
                for match in matches {
                    if let match = match as? NSTextCheckingResult {
                        target = (line as NSString).substringWithRange(match.rangeAtIndex(1))
                        if let target = target {
                            settings[target] = [String: String]()
                        }
                    }
                }
            } else {
                if let target = target {
                    let kv = split(line, allowEmptySlices: true) { $0 == "=" }
                    let key = kv[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    let value = kv[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    if var s = settings[target] {
                        s[key] = value
                        settings[target] = s
                    }
                }
            }
        }
        
        return settings
    }
}
