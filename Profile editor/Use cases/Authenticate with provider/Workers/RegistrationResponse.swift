//
//  RegistrationResponse.swift
//  POD browser
//
//  Created by Warwick McNaughton on 18/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import Foundation


let kResponseTypeCode = "code"
let kResponseTypeToken = "token"
let kResponseTypeIDToken = "id_token";






class RegistrationResponse: NSObject {
    
    let ClientIDParam = "client_id"
    let ClientIDIssuedAtParam = "client_id_issued_at"
    let ClientSecretParam = "client_secret"
    let ClientSecretExpirestAtParam = "client_secret_expires_at"
    let RegistrationAccessTokenParam = "registration_access_token"
    let RegistrationClientURIParam = "registration_client_uri"
    private let kRequestKey = "request"
    //private let kAdditionalParametersKey = "additionalParameters"
    
    
    var request: RegistrationRequest?
    var clientID: String?
    var clientIDIssuedAt: Date?
    var clientSecret: String?
    var clientSecretExpiresAt: Date?
    var registrationAccessToken: String?
    var registrationClientURI: URL?
    var tokenEndpointAuthenticationMethod: String?
    var additionalParameters = [String : Any]()
    
    
    
    init(request: RegistrationRequest, parameters: [String : Any]) {
        super.init()
        self.request = request
        for parameter in parameters {
            switch parameter.key {
            case ClientIDParam:
                clientID = parameters[ClientIDParam] as? String
            case ClientIDIssuedAtParam:
                let rawDate = parameters[ClientIDIssuedAtParam]
                clientIDIssuedAt = Date(timeIntervalSince1970: TimeInterval(Int64(truncating: rawDate as! NSNumber)))
            case ClientSecretParam:
                clientSecret = parameters[ClientSecretParam] as? String
            case ClientSecretExpirestAtParam :
                let rawDate = parameters[ClientSecretExpirestAtParam]
                clientSecretExpiresAt = Date(timeIntervalSinceNow: TimeInterval(Int64(truncating: rawDate as! NSNumber)))
            case RegistrationAccessTokenParam:
                registrationAccessToken = parameters[RegistrationAccessTokenParam] as? String
            case RegistrationClientURIParam:
                registrationClientURI = URL(string: parameters[RegistrationClientURIParam] as! String) 
            case RegistrationAccessTokenParam:
                tokenEndpointAuthenticationMethod = parameters[RegistrationAccessTokenParam] as? String
            default:
                additionalParameters[parameter.key] = parameter.value
            }
        }
        //let additionalParameters = OIDFieldMapping.remainingParameters(withMap: RegistrationResponse.sharedFieldMap, parameters: parameters, instance: self)
        //self.additionalParameters = additionalParameters
        // If client_secret is issued, client_secret_expires_at is REQUIRED,
        // and the response MUST contain "[...] both a Client Configuration Endpoint
        // and a Registration Access Token or neither of them"
        if (clientSecret != nil && clientSecretExpiresAt == nil) {return}
        
        if (!(registrationClientURI != nil && registrationAccessToken != nil) && !(registrationClientURI == nil && registrationAccessToken == nil)) {
            return
        }
    }
    
    // TODO: - Implement Codable -
    
    
    func description() -> String {
        //        return String(format: """
        //    <%@: %p, clientID: "%@", clientIDIssuedAt: %@, \
        //    clientSecret: %@, clientSecretExpiresAt: "%@", \
        //    registrationAccessToken: "%@", \
        //    registrationClientURI: "%@", \
        //    additionalParameters: %@, request: %@>
        //    """, NSStringFromClass(type(of: self).self), self, clientID!, clientIDIssuedAt! as CVarArg, OIDTokenUtilities.redact(clientSecret)!, clientSecretExpiresAt! as CVarArg, OIDTokenUtilities.redact(registrationAccessToken)!, registrationClientURI! as CVarArg, additionalParameters!, request as! CVarArg)
        
        let d =  "\n=============\nOIDRegistrationResponse \nclientID: \(clientID!) \nclientIDIssuedAt: \(clientIDIssuedAt!) \nclientSecret: \(TokenUtilities.redact(clientSecret)!) \nclientSecretExpiresAt: \(clientSecretExpiresAt!) \nregistrationAccessToken: \(TokenUtilities.redact(registrationAccessToken)!) \nregistrationClientURI: \(registrationClientURI!) \nadditionalParameters: \(additionalParameters) \nrequest: \(request!.description)\n============="
        return d
    }
    
}
