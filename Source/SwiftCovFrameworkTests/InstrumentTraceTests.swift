//
//  SyntaxTests.swift
//  SwiftCov
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import SwiftCovFramework
import XCTest

class InstrumentTraceTests: XCTestCase {
    func testInitialize() {
        let trace = InstrumentTrace(file: "/dev/null")
        XCTAssert(trace == nil, "InstrumentTrace shouldn't initialize with a path with no .trace bundle")
    }
}
