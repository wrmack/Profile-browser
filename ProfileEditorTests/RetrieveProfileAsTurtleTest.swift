//
//  RetrieveProfileAsTurtleTest.swift
//  ProfileEditorTests
//
//  Created by Warwick McNaughton on 23/02/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import XCTest



class RetrieveProfileAsTurtleTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }

    
    override func tearDown() {
        super.tearDown()
    }
    

    func testMimeTypeOfResponse() {
//        let webid = "https://wrmack.inrupt.net/profile/card#me"
//        let webid = "https://www.w3.org/People/Berners-Lee/card#i"
        let webid = "https://ruben.verborgh.org/profile/#me"
        
        
        let url = URL(string: webid)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let promise = expectation(description: "Response received")
        let task = session.dataTask(with: url!) { data, response, error in
            
            promise.fulfill()
            if let error = error {
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print((response as? HTTPURLResponse)?.allHeaderFields as! [String : Any] )
                    return
            }
            let mimeType = httpResponse.mimeType

            XCTAssertTrue(mimeType == "text/turtle" || mimeType == "text/n3")
            
            let string = String(data: data!, encoding: .utf8)
            print("\nTurtle text: \n\(string!)")
        }
        task.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
