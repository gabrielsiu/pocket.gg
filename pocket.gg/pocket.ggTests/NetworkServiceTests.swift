//
//  NetworkServiceTests.swift
//  pocket.ggTests
//
//  Created by Gabriel Siu on 2020-02-03.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import XCTest
@testable import pocket_gg

class NetworkServiceTests: XCTestCase {
    
    var sut: NetworkService!

    override func setUp() {
        super.setUp()
        sut = NetworkService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
