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
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let path =  Bundle.main.path(forResource: "Friendly", ofType: "strings")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let test = NSLocalizedString("foaf:name", tableName: "Friendly", bundle: Bundle.main, value: "", comment: "foaf")
        XCTAssertTrue(test == "name")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
