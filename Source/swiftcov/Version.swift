//
//  VersionCommand.swift
//  SwiftCov
//
//  Created by JP Simard on 2015-05-20.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Commandant
import Result
import let SwiftCovFramework.SwiftCovFrameworkBundleIdentifier

struct VersionCommand: CommandType {
    let verb = "version"
    let function = "Display the current version of SwiftLint"

    func run(options: NoOptions<SwiftCovError>) -> Result<(), SwiftCovError> {
        let version = NSBundle(identifier: SwiftCovFrameworkBundleIdentifier)?.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        print(version!)
        return .Success()
    }
}
