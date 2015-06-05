//
//  SimCtlTests.swift
//  swiftcov
//
//  Created by Kishikawa Katsumi on 2015/06/05.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import XCTest
import SwiftCovFramework

class SimCtlTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCommandWithOption() {
        switch SimCtl().list() {
        case let .Success(output):
            switch SimCtl.parseOutput(output.value) {
            case let .Success(simulators):
                let (deviceTypes, runtimes, devices) = simulators.value

                XCTAssertGreaterThan(deviceTypes.count, 0)
                XCTAssertGreaterThan(runtimes.count, 0)
                XCTAssertGreaterThan(devices.count, 0)
            case let .Failure(error):
                XCTAssertNotEqual(error.value, EXIT_SUCCESS)
                XCTFail("Execution failure")
            }
        case let .Failure(error):
            XCTAssertNotEqual(error.value, EXIT_SUCCESS)
            XCTFail("Execution failure")
        }
    }

}
