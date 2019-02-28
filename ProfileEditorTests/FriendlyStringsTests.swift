//
//  FriendlyStringsTests.swift
//  ProfileEditorTests
//
//  Created by Warwick McNaughton on 23/02/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import XCTest

class FriendlyStringsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let turtleName = "foaf:name"
        let test = NSLocalizedString(turtleName, tableName: "Friendly", bundle: Bundle.main, value: "", comment: "foaf")
        print("Friendly name: \(test)")
        XCTAssertTrue(test == "name")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
