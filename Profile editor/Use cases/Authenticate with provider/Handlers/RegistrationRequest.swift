//
//  RegistrationRequest.swift
//  POD browser
//
//  Created by Warwick McNaughton on 18/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import Foundation


fileprivate let kConfigurationKey = "configuration"
fileprivate let kInitialAccessToken = "initial_access_token"
fileprivate let kRedirectURIsKey = "redirect_uris"
fileprivate let kResponseTypesKey = "response_types"
fileprivate let kGrantTypesKey = "grant_types"
fileprivate let kSubjectTypeKey = "subject_type"
fileprivate let kAdditionalParametersKey = "additionalParameters"
fileprivate let kApplicationTypeNative = "native"

fileprivate let kTokenEndpointAuthenticationMethodParam = "token_endpoint_auth_method"
fileprivate let kApplicationTypeParam = "application_type"
fileprivate let kRedirectURIsParam = "redirect_uris"
fileprivate let kResponseTypesParam = "response_types"
fileprivate let kGrantTypesParam = "grant_types"
fileprivate let kSubjectTypeParam = "subject_type"


class RegistrationRequest: NSObject {
    
    
    /*! @brief The service's configuration.
     @remarks This configuration specifies how to connect to a particular OAuth provider.
     Configurations may be created manually, or via an OpenID Connect Discovery Document.
     */
    private(set) var configuration: ProviderConfiguration?
    /*! @brief The initial access token to access the Client Registration Endpoint
     (if required by the OpenID Provider).
     @remarks OAuth 2.0 Access Token optionally issued by an Authorization Server granting
     access to its Client Registration Endpoint. This token (if required) is
     provisioned out of band.
     @see Section 3 of OpenID Connect Dynamic Client Registration 1.0
     https://openid.net/specs/openid-connect-registration-1_0.html#ClientRegistration
     */
    private(set) var initialAccessToken: String?
    /*! @brief The application type to register, will always be 'native'.
     @remarks application_type
     @see https://openid.net/specs/openid-connect-registration-1_0.html#ClientMetadata
     */
    private(set) var applicationType = ""
    /*! @brief The client's redirect URI's.
     @remarks redirect_uris
     @see https://tools.ietf.org/html/rfc6749#section-3.1.2
     */
    private(set) var redirectURIs: [URL] = []
    /*! @brief The response types to register for usage by this client.
     @remarks response_types
     @see http://openid.net/specs/openid-connect-core-1_0.html#Authentication
     */
    private(set) var responseTypes: [String]?
    /*! @brief The grant types to register for usage by this client.
     @remarks grant_types
     @see https://openid.net/specs/openid-connect-registration-1_0.html#ClientMetadata
     */
    private(set) var grantTypes: [String]?
    /*! @brief The subject type to to request.
     @remarks subject_type
     @see http://openid.net/specs/openid-connect-core-1_0.html#SubjectIDTypes
     */
    private(set) var subjectType: String?
    /*! @brief The client authentication method to use at the token endpoint.
     @remarks token_endpoint_auth_method
     @see http://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication
     */
    private(set) var tokenEndpointAuthenticationMethod: String?
    /*! @brief The client's additional token request parameters.
     */
    private(set) var additionalParameters: [String : String]?
    
    
    convenience init(configuration: ProviderConfiguration?, redirectURIs: [URL]?, responseTypes: [String]?, grantTypes: [String]?, subjectType: String?, tokenEndpointAuthMethod tokenEndpointAuthenticationMethod: String?, additionalParameters: [String : String]?) {
        self.init(configuration: configuration, redirectURIs: redirectURIs, responseTypes: responseTypes, grantTypes: grantTypes, subjectType: subjectType, tokenEndpointAuthMethod: tokenEndpointAuthenticationMethod, initialAccessToken: nil, additionalParameters: additionalParameters)
    }
    
    
    init(configuration: ProviderConfiguration?, redirectURIs: [URL]?, responseTypes: [String]?, grantTypes: [String]?, subjectType: String?, tokenEndpointAuthMethod tokenEndpointAuthenticationMethod: String?, initialAccessToken: String?, additionalParameters: [String : String]?) {
        super.init()
        
        self.configuration = configuration
        self.initialAccessToken = initialAccessToken
        self.redirectURIs = redirectURIs!
        self.responseTypes = responseTypes
        self.grantTypes = grantTypes
        self.subjectType = subjectType
        self.tokenEndpointAuthenticationMethod = tokenEndpointAuthenticationMethod
        self.additionalParameters = additionalParameters
        applicationType = kApplicationTypeNative
    }
    
     
    func urlRequest() -> URLRequest? {
        let kHTTPPost = "POST"
        let kBearer = "Bearer"
        let kHTTPContentTypeHeaderKey = "Content-Type"
        let kHTTPContentTypeHeaderValue = "application/json"
        let kHTTPAuthorizationHeaderKey = "Authorization"
        
        let postBody: Data? = JSONString()
        if postBody == nil {
            return nil
        }
        let registrationRequestURL: URL? = configuration!.registrationEndpoint
        var URLRequestA: URLRequest? = nil
        if let anURL = registrationRequestURL {
            URLRequestA = URLRequest(url: anURL)
        }
        URLRequestA?.httpMethod = kHTTPPost
        URLRequestA?.setValue(kHTTPContentTypeHeaderValue, forHTTPHeaderField: kHTTPContentTypeHeaderKey)
        if initialAccessToken != nil {
            let value = "\(kBearer) \(initialAccessToken!)"
            URLRequestA?.setValue(value, forHTTPHeaderField: kHTTPAuthorizationHeaderKey)
        }
        URLRequestA?.httpBody = postBody
        return URLRequestA
    }
    
    
    func JSONString() -> Data? {
        // Dictionary with several key/value pairs and the above array of arrays
        var dict: [AnyHashable : Any] = [:]
        var redirectURIStrings = [String]()
        for obj in redirectURIs {
            redirectURIStrings.append(obj.absoluteString)
        }
        dict[kRedirectURIsParam] = redirectURIStrings
        dict[kApplicationTypeParam] = applicationType
        if additionalParameters != nil {
            // Add any additional parameters first to allow them
            // to be overwritten by instance values
            for (k, v) in additionalParameters! { dict[k] = v }
        }
        if responseTypes != nil {
            dict[kResponseTypesParam] = responseTypes
        }
        if grantTypes != nil {
            dict[kGrantTypesParam] = grantTypes
        }
        if subjectType != nil {
            dict[kSubjectTypeParam] = subjectType
        }
        if tokenEndpointAuthenticationMethod != nil {
            dict[kTokenEndpointAuthenticationMethodParam] = tokenEndpointAuthenticationMethod
        }
        
        let json: Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
        return json
    }
}
