//
//  AuthorizationResponse.swift
//  POD browser
//
//  Created by Warwick McNaughton on 19/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import Foundation



fileprivate let kAuthorizationCodeKey = "code"
fileprivate let kStateKey = "state"
fileprivate let kAccessTokenKey = "access_token"
fileprivate let kExpiresInKey = "expires_in"
fileprivate let kTokenTypeKey = "token_type"
fileprivate let kIDTokenKey = "id_token"
fileprivate let kScopeKey = "scope"
fileprivate let kAdditionalParametersKey = "additionalParameters"
fileprivate let kRequestKey = "request"
fileprivate let kTokenExchangeRequestException = """
Attempted to create a token exchange request from an authorization response with no \
authorization code.
"""





class AuthorizationResponse: NSObject, Codable  {
    /*! @brief The request which was serviced.
     */
    private(set) var request: AuthorizationRequest?
    /*! @brief The authorization code generated by the authorization server.
     @discussion Set when the response_type requested includes 'code'.
     @remarks code
     */
    var authorizationCode: String?
    /*! @brief REQUIRED if the "state" parameter was present in the client authorization request. The
     exact value received from the client.
     @remarks state
     */
    var state: String?
    /*! @brief The access token generated by the authorization server.
     @discussion Set when the response_type requested includes 'token'.
     @remarks access_token
     @see http://openid.net/specs/openid-connect-core-1_0.html#ImplicitAuthResponse
     */
    private(set) var accessToken: String?
    
    /*! @brief The approximate expiration date & time of the access token.
     @discussion Set when the response_type requested includes 'token'.
     @remarks expires_in
     @seealso OIDAuthorizationResponse.accessToken
     @see http://openid.net/specs/openid-connect-core-1_0.html#ImplicitAuthResponse
     */
    private(set) var accessTokenExpirationDate: Date?
    /*! @brief Typically "Bearer" when present. Otherwise, another token_type value that the Client has
     negotiated with the Authorization Server.
     @discussion Set when the response_type requested includes 'token'.
     @remarks token_type
     @see http://openid.net/specs/openid-connect-core-1_0.html#ImplicitAuthResponse
     */
    private(set) var tokenType: String?
    /*! @brief ID Token value associated with the authenticated session.
     @discussion Set when the response_type requested includes 'id_token'.
     @remarks id_token
     @see http://openid.net/specs/openid-connect-core-1_0.html#IDToken
     @see http://openid.net/specs/openid-connect-core-1_0.html#ImplicitAuthResponse
     */
    private(set) var idToken: String?
    /*! @brief The scope of the access token. OPTIONAL, if identical to the scopes requested, otherwise,
     REQUIRED.
     @remarks scope
     @see https://tools.ietf.org/html/rfc6749#section-5.1
     */
    private(set) var scope: String?
    /*! @brief Additional parameters returned from the authorization server.
     */
    private(set) var additionalParameters: [String : NSObject]?
    
//
    
    
    // MARK: - Initializers
    init(request: AuthorizationRequest?, parameters: [String : NSObject]?) {
        super.init()
        
        self.request = request
        
        for parameter in parameters! {
            switch parameter.key {
            case kStateKey:
                state = parameters![kStateKey] as? String
            case kAuthorizationCodeKey:
                authorizationCode = parameters![kAuthorizationCodeKey] as? String
            case kAccessTokenKey:
                accessToken = parameters![kAccessTokenKey] as? String
            case kExpiresInKey:
                let rawDate = parameters![kExpiresInKey]
                accessTokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(Int64(truncating: rawDate as! NSNumber)))
            case kTokenTypeKey:
                tokenType = parameters![kTokenTypeKey] as? String
            case kIDTokenKey:
                idToken = parameters![kIDTokenKey] as? String
            case kScopeKey:
                scope = parameters![kScopeKey] as? String
            default:
                additionalParameters![parameter.key] = parameter.value
            }
        }
    }
    
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case request
        case additionalParameters
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(request, forKey: CodingKeys.request)
        let paramData = try NSKeyedArchiver.archivedData(withRootObject: additionalParameters as Any, requiringSecureCoding: true)
        try container.encode(paramData, forKey: .additionalParameters)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        request = try container.decode(AuthorizationRequest.self, forKey: .request)
        let paramData = try container.decode(Data.self, forKey: .additionalParameters)
        additionalParameters = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(paramData) as? [String : NSObject]
    }

    
    // MARK: - NSObject overrides
    func description() -> String? {
        return String(format: """
        <%@: %p, authorizationCode: %@, state: "%@", accessToken: \
        "%@", accessTokenExpirationDate: %@, tokenType: %@, \
        idToken: "%@", scope: "%@", additionalParameters: %@, \
        request: %@>
        """, NSStringFromClass(type(of: self).self), self, authorizationCode!, state!, TokenUtilities.redact(accessToken)!, (accessTokenExpirationDate as CVarArg?)!, tokenType!, TokenUtilities.redact(idToken)!, scope!, additionalParameters!, request!)
    }
    
    // MARK: -
    func tokenExchangeRequest() -> TokenRequest? {
        return tokenExchangeRequest(withAdditionalParameters: nil)
    }
    
    
    func tokenExchangeRequest(withAdditionalParameters additionalParameters: [String : String]?) -> TokenRequest? {
        // TODO: add a unit test to confirm exception is thrown when expected and the request is created
        //       with the correct parameters.
        if authorizationCode == nil {
            fatalError(kTokenExchangeRequestException)
        }
        return nil    //OIDTokenRequest(configuration: request!.configuration, grantType: OIDGrantTypeAuthorizationCode, authorizationCode: authorizationCode, redirectURL: request!.redirectURL, clientID: request!.clientID, clientSecret: request!.clientSecret, scope: nil, refreshToken: nil, codeVerifier: request!.codeVerifier, additionalParameters: additionalParameters)
    }
}
