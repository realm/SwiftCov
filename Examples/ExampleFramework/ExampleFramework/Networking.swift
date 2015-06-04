//
//  Networking.swift
//  ExampleFramework
//
//  Created by Kishikawa Katsumi on 2015/06/04.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation

public class Networking {
    let requesetURL: NSURL

    public init() {
        if let URL = NSURL(string: "http://www.google.com") {
            requesetURL = URL
        } else {
            fatalError("Unknown error occurred")
        }
    }

    public init(URL: NSURL) {
        requesetURL = URL
    }

    public func request(completion:(data: NSData?, response: NSURLResponse, error: NSError?) -> Void) -> Void {
        var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var request = NSMutableURLRequest(URL: requesetURL)

        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            completion(data: data, response: response, error: error)
        }).resume()
    }

}
