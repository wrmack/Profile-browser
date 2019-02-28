//
//  AuthenticateWithProviderModels.swift
//  POD browser
//
//  Created by Warwick McNaughton on 9/12/18.
//  Copyright (c) 2018 Warwick McNaughton. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum AuthenticateWithProvider {
  // MARK: Use cases
  
    enum DisplayMessages {
        struct Request {
            var message: [String : Any]?
        }
        struct Response {
            var message: [String : Any]?
        }
        struct ViewModel {
            var status: NSAttributedString?
            var message: NSAttributedString?
        }
    }
    
    
    enum FetchConfiguration {
        struct Request {
            var issuer: String?
            var webid: String?
        }
        struct Response {

        }
        struct ViewModel {

        }
    }
    enum RegisterClient {
        struct Request {
            var configuration: ProviderConfiguration?
        }
        struct Response {

        }
        struct ViewModel {

        }
    }
    enum Authenticate {
        struct Request {
            var configuration: ProviderConfiguration?
            var clientID: String?
            var clientSecret: String?
        }
        struct Response {
            
        }
        struct ViewModel {
            
        }
    }
    
    enum UserInfo {
        struct Request {

        }
        struct Response {
            
        }
        struct ViewModel {
            
        }
    }
    
}
