//
//  NetworkingTests.swift
//  ExampleFramework
//
//  Created by kishikawakatsumi on 2015/06/04.
//  Copyright (c) 2015年 kishikawakatsumi. All rights reserved.
//

import XCTest
import ExampleFramework

class NetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAsyncNetworking() {
        let expectation = expectationWithDescription("networking")

        let networking = Networking(URL: NSURL(string: "http://www.google.com")!)
        networking.request { (data, response, error) -> Void in
            if let response = response as? NSHTTPURLResponse {
                XCTAssertEqual(response.statusCode, 200)
            } else {
                XCTFail("Request failed")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: { (error) -> Void in
            if let error = error {
                XCTFail("Connection timeout")
            }
        })
    }

}
