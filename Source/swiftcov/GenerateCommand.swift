//
//  GenerateCommand.swift
//  SwiftCov
//
//  Created by JP Simard on 2015-05-20.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Commandant
import Result

struct GenerateCommand: CommandType {
    typealias ClientError = SwiftCovError
    let verb = "generate"
    let function = "Generate test code coverage files for the given .trace bundle"

    func run(mode: CommandMode) -> Result<(), CommandantError<SwiftCovError>> {
        switch mode {
        case let .Arguments:
            println("TODO: \(function)")

        default:
            break
        }
        return .success(())
    }
}
