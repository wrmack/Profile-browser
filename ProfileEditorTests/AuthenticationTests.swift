//
//  AuthenticationTests.swift
//  ProfileEditorTests
//
//  Created by Warwick McNaughton on 1/03/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import XCTest
@testable import Profile_editor


class AuthenticationTests: XCTestCase {
    var authVC: AuthenticateWithProviderViewController?
    var configuration: ProviderConfiguration?
    
    override func setUp() {
        super.setUp()
        authVC = AuthenticateWithProviderViewController()
    }

    override func tearDown() {
//        super.tearDown()
    }

    
    func testGetProviderConfiguration() {
        let issuer = "https://inrupt.com"
        let webId = "https://wrmack.inrupt.net"
        let promise = expectation(description: "Wait for configuration")
        let request = AuthenticateWithProvider.FetchConfiguration.Request(issuer: issuer, webid: webId)
        authVC!.interactor?.fetchProviderConfiguration(request: request, callback: { configuration, errorString in
            promise.fulfill()
            XCTAssert(errorString == nil, errorString!)
            if configuration != nil {
                self.configuration = configuration
                print("Provider configuration: \(configuration!.description())")
            }
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    func testRegisterWithProvider() {
        let issuer = "https://inrupt.net"
        let webId = "https://wrmack.inrupt.net"
        let promise = expectation(description: "Wait for configuration")
        let request = AuthenticateWithProvider.FetchConfiguration.Request(issuer: issuer, webid: webId)
        authVC!.interactor?.fetchProviderConfiguration(request: request, callback: { configuration, errorString in
            XCTAssert(errorString == nil, errorString!)
            if configuration != nil {
                self.configuration = configuration
                print("Provider configuration: \(configuration!.description())")
                let request = AuthenticateWithProvider.RegisterClient.Request(configuration: configuration)
                self.authVC!.interactor?.registerClient(request: request, callback: { configuration, response, errorString in
                    promise.fulfill()
                    XCTAssert(errorString == nil, errorString!)
                    if response != nil {
                        print("Registration response: \(response!.description())")
                    }
                })
            }
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
