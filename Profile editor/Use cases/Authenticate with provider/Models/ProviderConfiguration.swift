//
//  ServiceDiscoveryDocument.swift
//  POD browser
//
//  Created by Warwick McNaughton on 18/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import Foundation

/*! Field keys associated with an OpenID Connect Discovery Document. */
fileprivate let kIssuerKey = "issuer" 
fileprivate let kAuthorizationEndpointKey = "authorization_endpoint"
fileprivate let kTokenEndpointKey = "token_endpoint"
fileprivate let kUserinfoEndpointKey = "userinfo_endpoint"
fileprivate let kJWKSURLKey = "jwks_uri"
fileprivate let kRegistrationEndpointKey = "registration_endpoint"
fileprivate let kScopesSupportedKey = "scopes_supported"
fileprivate let kResponseTypesSupportedKey = "response_types_supported"
fileprivate let kResponseModesSupportedKey = "response_modes_supported"
fileprivate let kGrantTypesSupportedKey = "grant_types_supported"
fileprivate let kACRValuesSupportedKey = "acr_values_supported"
fileprivate let kSubjectTypesSupportedKey = "subject_types_supported"
fileprivate let kIDTokenSigningAlgorithmValuesSupportedKey = "id_token_signing_alg_values_supported"
fileprivate let kIDTokenEncryptionAlgorithmValuesSupportedKey = "id_token_encryption_alg_values_supported"
fileprivate let kIDTokenEncryptionEncodingValuesSupportedKey = "id_token_encryption_enc_values_supported"
fileprivate let kUserinfoSigningAlgorithmValuesSupportedKey = "userinfo_signing_alg_values_supported"
fileprivate let kUserinfoEncryptionAlgorithmValuesSupportedKey = "userinfo_encryption_alg_values_supported"
fileprivate let kUserinfoEncryptionEncodingValuesSupportedKey = "userinfo_encryption_enc_values_supported"
fileprivate let kRequestObjectSigningAlgorithmValuesSupportedKey = "request_object_signing_alg_values_supported"
fileprivate let kRequestObjectEncryptionAlgorithmValuesSupportedKey = "request_object_encryption_alg_values_supported"
fileprivate let kRequestObjectEncryptionEncodingValuesSupported = "request_object_encryption_enc_values_supported"
fileprivate let kTokenEndpointAuthMethodsSupportedKey = "token_endpoint_auth_methods_supported"
fileprivate let kTokenEndpointAuthSigningAlgorithmValuesSupportedKey = "token_endpoint_auth_signing_alg_values_supported"
fileprivate let kDisplayValuesSupportedKey = "display_values_supported"
fileprivate let kClaimTypesSupportedKey = "claim_types_supported"
fileprivate let kClaimsSupportedKey = "claims_supported"
fileprivate let kServiceDocumentationKey = "service_documentation"
fileprivate let kClaimsLocalesSupportedKey = "claims_locales_supported"
fileprivate let kUILocalesSupportedKey = "ui_locales_supported"
fileprivate let kClaimsParameterSupportedKey = "claims_parameter_supported"
fileprivate let kRequestParameterSupportedKey = "request_parameter_supported"
fileprivate let kRequestURIParameterSupportedKey = "request_uri_parameter_supported"
fileprivate let kRequireRequestURIRegistrationKey = "require_request_uri_registration"
fileprivate let kOPPolicyURIKey = "op_policy_uri"
fileprivate let kOPTosURIKey = "op_tos_uri"



class ProviderConfiguration: NSObject, Codable {
    
    // MARK: - Properties
    
    var discoveryDictionary: [String : Any]?
    var authorizationEndpoint: URL?
    var tokenEndpoint: URL?
    var issuer: URL?
    var registrationEndpoint: URL?
    var discoveryDocument: ProviderConfiguration?
    
    var userinfoEndpoint: URL? {
        get {
            return URL(string: discoveryDictionary![kUserinfoEndpointKey]! as! String)
        }
    }
    
    var jwksURL: URL? {
        get {
            return URL(string: discoveryDictionary![kJWKSURLKey]! as! String)
        }
    }
    
    var scopesSupported: [String]? {
        get {
            return (discoveryDictionary![kScopesSupportedKey]) as? [String]
        }
    }
    
    var responseTypesSupported: [String]? {
        get {
            return discoveryDictionary![kResponseTypesSupportedKey] as? [String]
        }
    }
    
    var responseModesSupported: [String]? {
        get {
            return discoveryDictionary![kResponseModesSupportedKey] as? [String]
        }
    }
    
    var grantTypesSupported: [String]? {
        get {
            return discoveryDictionary![kGrantTypesSupportedKey] as? [String]
        }
    }
    
    var acrValuesSupported: [String]? {
        get {
            return discoveryDictionary![kACRValuesSupportedKey] as? [String]
        }
    }
    
    var subjectTypesSupported: [String]? {
        get {
            return discoveryDictionary![kSubjectTypesSupportedKey] as? [String]
        }
    }
    
    var IDTokenSigningAlgorithmValuesSupported: [String]? {
        get {
            return discoveryDictionary![kIDTokenSigningAlgorithmValuesSupportedKey] as? [String]
        }
    }
    
    var IDTokenEncryptionAlgorithmValuesSupported: [String]? {
        get {
            return discoveryDictionary![kIDTokenEncryptionAlgorithmValuesSupportedKey] as? [String]
        }
    }
    
    var IDTokenEncryptionEncodingValuesSupported: [String]? {
        get {
            return discoveryDictionary![kIDTokenEncryptionAlgorithmValuesSupportedKey] as? [String]
        }
    }
    
    var userinfoSigningAlgorithmValuesSupported: [String]? {
        get {
            return discoveryDictionary![kUserinfoSigningAlgorithmValuesSupportedKey] as? [String]
        }
    }
    
    var userinfoEncryptionAlgorithmValuesSupported: [String]? {
        get {
            return discoveryDictionary![kUserinfoEncryptionAlgorithmValuesSupportedKey] as? [String]
        }
    }
    
    var userinfoEncryptionEncodingValuesSupported: [String]? {
        get {
            return discoveryDictionary![kUserinfoEncryptionEncodingValuesSupportedKey] as? [String]
        }
    }
    
    var requestObjectSigningAlgorithmValuesSupported: [String]? {
        get {
            return discoveryDictionary![kRequestObjectSigningAlgorithmValuesSupportedKey] as? [String]
        }
    }
    
    var requestObjectEncryptionAlgorithmValuesSupported: [String]? {
        get {
            return discoveryDictionary![kRequestObjectEncryptionAlgorithmValuesSupportedKey] as? [String]
        }
    }
    
    var requestObjectEncryptionEncodingValuesSupported: [String]? {
        get {
            return discoveryDictionary![kRequestObjectEncryptionEncodingValuesSupported] as? [String]
        }
    }
    
    var tokenEndpointAuthMethodsSupported: [String]? {
        get {
            return discoveryDictionary![kTokenEndpointAuthMethodsSupportedKey] as? [String]
        }
    }
    
    var tokenEndpointAuthSigningAlgorithmValuesSupported: [String]? {
        get {
            return discoveryDictionary![kTokenEndpointAuthSigningAlgorithmValuesSupportedKey] as? [String]
        }
    }
    
    var displayValuesSupported: [String]? {
        get {
            return discoveryDictionary![kDisplayValuesSupportedKey] as? [String]
        }
    }
    
    var claimTypesSupported: [String]? {
        get {
            return discoveryDictionary![kClaimTypesSupportedKey] as? [String]
        }
    }
    
    
    var claimsSupported: [String]? {
        get {
            return discoveryDictionary![kClaimsSupportedKey] as? [String]
        }
    }
    
    
    var serviceDocumentation: URL? {
        get {
            return URL(string: discoveryDictionary![kServiceDocumentationKey] as! String)
        }
    }
    
    var claimsLocalesSupported: [String]? {
        get {
            return discoveryDictionary![kClaimsLocalesSupportedKey] as? [String]
        }
    }
    
    var UILocalesSupported: [String]? {
        get {
            return discoveryDictionary![kUILocalesSupportedKey] as? [String]
        }
    }
    
    var claimsParameterSupported: Bool {
        get {
            return discoveryDictionary![kClaimsParameterSupportedKey] as! Bool
        }
    }
    
    
    var requestParameterSupported: Bool {
        get {
            return discoveryDictionary![kRequestParameterSupportedKey] as! Bool
        }
    }
    
    var requestURIParameterSupported: Bool {
        get {
            if discoveryDictionary![kRequestURIParameterSupportedKey] == nil {
                return true
            }
            return discoveryDictionary![kRequestURIParameterSupportedKey] as! Bool
        }
    }
    
    var requireRequestURIRegistration: Bool {
        get {
            return discoveryDictionary![kRequireRequestURIRegistrationKey] as! Bool
        }
    }
    
    var OPPolicyURI: URL? {
        get {
            return URL(string: discoveryDictionary![kOPPolicyURIKey] as! String)
        }
    }
    
    var OPTosURI: URL? {
        get {
            return URL(string: discoveryDictionary![kOPTosURIKey] as! String)
        }
    }
    
    // MARK: - Object lifecycle
    
    convenience init(JSON: String, error: NSError?) {
        let jsonData = JSON.data(using: .utf8)
        self.init(JSONData: jsonData!, error: error)
    }
    
    convenience init(JSONData: Data, error: NSError?) {
        var jsonError: NSError?
        var json: [String : Any]?
        do {
            json = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as? [String : Any]
        }
        catch {
            jsonError = ErrorUtilities.error(code: ErrorCode.JSONDeserializationError, underlyingError: jsonError, description: jsonError?.localizedDescription)
        }
        
        self.init(serviceDiscoveryDictionary: json!, error: jsonError)
    }
    
    convenience init(serviceDiscoveryDictionary: [String : Any], error: NSError?) {
        self.init()
        var error = error
        if ProviderConfiguration.dictionaryHasRequiredFields(dictionary: serviceDiscoveryDictionary, error: &error) == false {  
            return
        }
        
        self.discoveryDictionary = serviceDiscoveryDictionary
        authorizationEndpoint = URL(string: discoveryDictionary![kAuthorizationEndpointKey]! as! String)
        tokenEndpoint = URL(string: discoveryDictionary![kTokenEndpointKey]! as! String)
        issuer = URL(string: discoveryDictionary![kIssuerKey]! as! String)
        registrationEndpoint = URL(string: discoveryDictionary![kRegistrationEndpointKey]! as! String)
    }
    
    override init() {
        super.init()
    }
    
    
    // MARK: - Codable
    
    
    enum CodingKeys: String, CodingKey {
        case discoveryDictionary
        case authorizationEndpoint
        case tokenEndpoint
        case issuer
        case registrationEndpoint
    }
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
  //      discoveryDictionary = try? values.decode([String : Any].self, forKey: .discoveryDictionary)    // Need to handle Any in Codable!!!!!
        authorizationEndpoint = try? values.decode(URL.self, forKey: .authorizationEndpoint)
        tokenEndpoint = try? values.decode(URL.self, forKey: .tokenEndpoint)
        issuer = try? values.decode(URL.self, forKey: .issuer)
        registrationEndpoint = try? values.decode(URL.self, forKey: .registrationEndpoint)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(discoveryDictionary, forKey: CodingKeys.discoveryDictionary)
        try container.encode(authorizationEndpoint, forKey: CodingKeys.authorizationEndpoint)
        try container.encode(tokenEndpoint, forKey: .tokenEndpoint)
        try container.encode(issuer, forKey: CodingKeys.issuer)
        try container.encode(registrationEndpoint, forKey: .registrationEndpoint)
    }
    
    
    // MARK: - Utilities
    
    static func dictionaryHasRequiredFields(dictionary: [String : Any], error: inout NSError?)-> Bool {
        
        let requiredFields = [
            kIssuerKey,
            kAuthorizationEndpointKey,
            kTokenEndpointKey,
            kJWKSURLKey,
            kResponseTypesSupportedKey,
            kSubjectTypesSupportedKey,
            kIDTokenSigningAlgorithmValuesSupportedKey
        ]
        
        for field in requiredFields {
            if dictionary[field] == nil {
                if error != nil {
                    let errorText = "Missing field: \(field)"
                    error = ErrorUtilities.error(code: ErrorCode.InvalidDiscoveryDocument, underlyingError: nil, description: errorText)
                }
                return false
            }
        }
        
        let requiredURLFields = [
            kIssuerKey,
            kTokenEndpointKey,
            kJWKSURLKey
        ]
        
        for field in requiredURLFields {
            if URL(string: dictionary[field] as! String) == nil {
                if error != nil {
                    let errorText = "Invalid URL: \(field)"
                    error = ErrorUtilities.error(code: ErrorCode.InvalidDiscoveryDocument, underlyingError: nil, description: errorText)
                }
                return false
            }
        }
        return true
    }
    
    

    
    func description()->String {
        return "===========\nProviderConfiguration \nauthorizationEndpoint: \(authorizationEndpoint!), \ntokenEndpoint: \(tokenEndpoint!), \nregistrationEndpoint: \(registrationEndpoint!), \ndiscoveryDictionary: \(discoveryDictionary!)\n============="
    }
    
}
