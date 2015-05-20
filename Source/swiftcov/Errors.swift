//
//  Errors.swift
//  SwiftCov
//
//  Created by JP Simard on 2015-05-20.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Commandant
import Result
import Box

/// Possible errors within SwiftCov.
enum SwiftCovError: Printable {
    /// One or more argument was invalid.
    case InvalidArgument(description: String)

    /// Failed to read a file at the given path.
    case ReadFailed(path: String)

    /// Failed to generate test code coverage files.
    case GenerateFailed

    /// An error message corresponding to this error.
    var description: String {
        switch self {
        case let .InvalidArgument(description):
            return description
        case let .ReadFailed(path):
            return "Failed to read file at '\(path)'."
        case let .GenerateFailed:
            return "Failed to generate test code coverage files."
        }
    }
}

func toCommandantError(sourceKittenError: SwiftCovError) -> CommandantError<SwiftCovError> {
    return .CommandError(Box(sourceKittenError))
}
