//
//  TokenRequest.swift
//  POD browser
//
//  Created by Warwick McNaughton on 19/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import Foundation



fileprivate let kConfigurationKey = "configuration"
fileprivate let kGrantTypeKey = "grant_type"
fileprivate let kAuthorizationCodeKey = "code"
fileprivate let kClientIDKey = "client_id"
fileprivate let kClientSecretKey = "client_secret"
fileprivate let kRedirectURLKey = "redirect_uri"
fileprivate let kScopeKey = "scope"
fileprivate let kRefreshTokenKey = "refresh_token"
fileprivate let kCodeVerifierKey = "code_verifier"
fileprivate let kAdditionalParametersKey = "additionalParameters"
fileprivate let kGrantTypeAuthorizationCode = "authorization_code"
fileprivate let kPublicKey = "request"   // POP
fileprivate let kTokenType = "token_type"   // POP
fileprivate let kKeyOps = "key_ops"  // POP


struct PayloadClaims: Codable {
    var key: JWKClaims
    var display: String
    var nonce: String
    
    enum CodingKeys: String, CodingKey {
        case key
        case display
        case nonce
    }
}


struct JWKClaims: Codable {
    var alg: String
    var kty: String
    var use: String
    var ext: Bool
    var key_ops: [String]
    var e: String
    var n: String

    
    enum CodingKeys: String, CodingKey {
        case alg
        case kty
        case use
        case ext
        case key_ops
        case e
        case n
    }
}



class TokenRequest: NSObject, Codable {
    
    
    
    /*! @brief The service's configuration.
     @remarks This configuration specifies how to connect to a particular OAuth provider.
     Configurations may be created manually, or via an OpenID Connect Discovery Document.
     */
    private(set) var configuration: ProviderConfiguration?
    /*! @brief The type of token being sent to the token endpoint, i.e. "authorization_code" for the
     authorization code exchange, or "refresh_token" for an access token refresh request.
     @remarks grant_type
     @see https://tools.ietf.org/html/rfc6749#section-4.1.3
     @see https://www.google.com/url?sa=D&q=https%3A%2F%2Ftools.ietf.org%2Fhtml%2Frfc6749%23section-6
     */
    private(set) var grantType: String?
    /*! @brief The authorization code received from the authorization server.
     @remarks code
     @see https://tools.ietf.org/html/rfc6749#section-4.1.3
     */
    private(set) var authorizationCode: String?
    /*! @brief The client's redirect URI.
     @remarks redirect_uri
     @see https://tools.ietf.org/html/rfc6749#section-4.1.3
     */
    private(set) var redirectURL: URL?
    /*! @brief The client identifier.
     @remarks client_id
     @see https://tools.ietf.org/html/rfc6749#section-4.1.3
     */
    private(set) var clientID = ""
    /*! @brief The client secret.
     @remarks client_secret
     @see https://tools.ietf.org/html/rfc6749#section-2.3.1
     */
    private(set) var clientSecret: String?
    /*! @brief The value of the scope parameter is expressed as a list of space-delimited,
     case-sensitive strings.
     @remarks scope
     @see https://tools.ietf.org/html/rfc6749#section-3.3
     */
    private(set) var scope: String?
    /*! @brief The refresh token, which can be used to obtain new access tokens using the same
     authorization grant.
     @remarks refresh_token
     @see https://tools.ietf.org/html/rfc6749#section-5.1
     */
    private(set) var refreshToken: String?
    /*! @brief The PKCE code verifier used to redeem the authorization code.
     @remarks code_verifier
     @see https://tools.ietf.org/html/rfc7636#section-4.3
     */
    private(set) var codeVerifier: String?
    /*! @brief The client's additional token request parameters.
     */
    private(set) var additionalParameters: [String : AnyCodable]?
    
    private(set) var nonce: String?
  //  private var pubKey: String?  // POP
    
    
    convenience init(configuration: ProviderConfiguration?, grantType: String?, authorizationCode code: String?, redirectURL: URL?, clientID: String?, clientSecret: String?, scopes: [String]?, refreshToken: String?, codeVerifier: String?, nonce: String?, additionalParameters: [String : AnyCodable]?) {
        self.init(configuration: configuration, grantType: grantType, authorizationCode: code, redirectURL: redirectURL, clientID: clientID, clientSecret: clientSecret, scope: ScopeUtilities.scopes(withArray: scopes), refreshToken: refreshToken, codeVerifier: codeVerifier, nonce: nonce, additionalParameters: additionalParameters)
    }
    
    init(configuration: ProviderConfiguration?, grantType: String?, authorizationCode code: String?, redirectURL: URL?, clientID: String?, clientSecret: String?, scope: String?, refreshToken: String?, codeVerifier: String?, nonce: String?, additionalParameters: [String : AnyCodable]?) {
        super.init()
        
        self.configuration = configuration
        self.grantType = grantType!
        authorizationCode = code
        self.redirectURL = redirectURL
        self.clientID = clientID!
        self.clientSecret = clientSecret
        self.scope = scope
        self.refreshToken = refreshToken
        self.codeVerifier = codeVerifier
        self.nonce = nonce
        self.additionalParameters = additionalParameters // copyItems: true
        // Additional validation for the authorization_code grant type
        if self.grantType == kGrantTypeAuthorizationCode {
            // redirect URI must not be nil
            if self.redirectURL == nil {
                fatalError(OIDOAuthExceptionInvalidTokenRequestNullRedirectURL)
                //             NSException.raise(OIDOAuthExceptionInvalidTokenRequestNullRedirectURL, format: "%@", OIDOAuthExceptionInvalidTokenRequestNullRedirectURL, nil)
            }
        }
    }
    
    
    // MARK: - Codable
    
    
    enum CodingKeys: String, CodingKey {
        case configuration
        case grantType
        case authorizationCode
        case redirectURL
        case clientID
        case clientSecret
        case scope
        case refreshToken
        case codeVerifier
        case additionalParameters
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configuration, forKey: CodingKeys.configuration)
        try container.encode(grantType, forKey: CodingKeys.grantType)
        try container.encode(authorizationCode, forKey: .authorizationCode)
        try container.encode(redirectURL, forKey: CodingKeys.redirectURL)
        try container.encode(clientID, forKey: .clientID)
        try container.encode(clientSecret, forKey: .clientSecret)
        try container.encode(scope, forKey: .scope)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(codeVerifier, forKey: .codeVerifier)
        try container.encode(additionalParameters, forKey: .additionalParameters)
    }
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        configuration = try values.decode(ProviderConfiguration.self, forKey: .configuration)
        grantType = try values.decode(String.self, forKey: .grantType)
        authorizationCode = try values.decode(String.self, forKey: .authorizationCode)
        redirectURL = try values.decode(URL.self, forKey: .redirectURL)
        clientID = try values.decode(String.self, forKey: .clientID)
        clientSecret = try values.decode(String.self, forKey: .clientSecret)
        scope = try? values.decode(String.self, forKey: .scope)
        refreshToken = try? values.decode(String.self, forKey: .refreshToken)
        codeVerifier = try? values.decode(String.self, forKey: .codeVerifier)
        additionalParameters = try? values.decode([String : AnyCodable].self, forKey: .additionalParameters)
    }
    
    
    func description(request: URLRequest) -> String? {
        let request = request  
        var requestBody: String? = nil
        if let aBody = request.httpBody {
            requestBody = String(data: aBody, encoding: .utf8)
        }
        if let anURL = request.url {
            return String(format: "<%@: %p, request: <URL: %@, HTTPBody: %@>>", NSStringFromClass(type(of: self).self), self, anURL as CVarArg, requestBody ?? "")
        }
        return nil
    }
    
    func urlRequest()-> URLRequest {
        let kHTTPPost = "POST"
        let kHTTPContentTypeHeaderKey = "Content-Type"
        let kHTTPContentTypeHeaderValue = "application/x-www-form-urlencoded; charset=UTF-8"
        let tokenRequestURL = self.tokenRequestURL()
        var URLRequestA = URLRequest(url: tokenRequestURL)
        URLRequestA.httpMethod = kHTTPPost
        URLRequestA.setValue(kHTTPContentTypeHeaderValue, forHTTPHeaderField: kHTTPContentTypeHeaderKey)
        let bodyParameters = tokenRequestBody()
        var httpHeaders = [String : String]()
        if clientSecret != nil {
            // The client id and secret are encoded using the "application/x-www-form-urlencoded"
            // encoding algorithm per RFC 6749 Section 2.3.1.
            // https://tools.ietf.org/html/rfc6749#section-2.3.1
            let encodedClientID = TokenUtilities.formUrlEncode(clientID)
            let encodedClientSecret = TokenUtilities.formUrlEncode(clientSecret)
            let credentials = "\(encodedClientID):\(encodedClientSecret)"
            let plainData = credentials.data(using: .utf8)!
            let basicAuth = plainData.base64EncodedString(options: [])
            let authValue = "Basic \(basicAuth)"
            httpHeaders["Authorization"] = authValue
        } else {
            bodyParameters.addParameter(kClientIDKey, value: clientID)
        }
        // Constructs request with the body string and headers.
        let bodyString = bodyParameters.urlEncodedParameters()
        let body: Data? = bodyString.data(using: .utf8)
        URLRequestA.httpBody = body!
        for header in httpHeaders {
            URLRequestA.setValue(httpHeaders[header.key], forHTTPHeaderField: header.key)
        }
        return URLRequestA
    }
    
    
    /*! @brief Constructs the request URI.
     @return A URL representing the token request.
     @see https://tools.ietf.org/html/rfc6749#section-4.1.3
     */
    func tokenRequestURL() -> URL {
        return configuration!.tokenEndpoint!
    }
    
    /*! @brief Constructs the request body data by combining the request parameters using the
     "application/x-www-form-urlencoded" format.
     @return The data to pass to the token request URL.
     @see https://tools.ietf.org/html/rfc6749#section-4.1.3
     */
    func tokenRequestBody() -> QueryUtilities {
        let query = QueryUtilities()
        // Add parameters, as applicable.
        if grantType != nil {
            query.addParameter(kGrantTypeKey, value: grantType)
        }
        if scope != nil {
            query.addParameter(kScopeKey, value: scope)
        }
        if redirectURL != nil {
            query.addParameter(kRedirectURLKey, value: redirectURL!.absoluteString)
        }
        if refreshToken != nil {
            query.addParameter(kRefreshTokenKey, value: refreshToken)
        }
        if authorizationCode != nil {
            query.addParameter(kAuthorizationCodeKey, value: authorizationCode)
        }
        if codeVerifier != nil {
            query.addParameter(kCodeVerifierKey, value: codeVerifier)
        }
        
        // JWK
        // Header
        var publicKeyHeader = [String : String]()
        publicKeyHeader["alg"] = "none"
        let json = try? JSONEncoder().encode(publicKeyHeader)
        let publicKeyHeaderEncoded = TokenUtilities.encodeBase64urlNoPadding(json)
        // Payload
        let publicKeyPayloadEncoded = createKeysForPOP()
        // Combined
        let publicKeyEncoded = publicKeyHeaderEncoded! + "." + publicKeyPayloadEncoded! + "."
        query.addParameter(kPublicKey, value: publicKeyEncoded)
        query.addParameter(kTokenType, value: "pop")
    
        // Add any additional parameters the client has specified.
        query.addParameters(additionalParameters)
        return query
    }

    
    // POP
    func createKeysForPOP()-> String? {
        var privateKey: SecKey
        let tag = "com.wm.POD-browser".data(using: .utf8)!
//        deleteKeysInKeychain(tag: tag)
        
        // Check if stored in keychain
        let query: [String: Any] =
            [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: tag,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecReturnRef as String: true
            ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            privateKey = item as! SecKey
        }
        else {
            // Generate a private key
            let attributes: [String: Any] =
                [
                    kSecAttrKeyType as String:  kSecAttrKeyTypeRSA,
                    kSecAttrKeySizeInBits as String: 2048,
                    kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: true, kSecAttrApplicationTag as String: tag]
                ]
            var error: Unmanaged<CFError>?
            privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error)!
            if error != nil {
                print(error!.takeRetainedValue() as Error)
                return nil
            }
        }
        
        let publicKey = SecKeyCopyPublicKey(privateKey)
        
        print("Public Key: \(publicKey!)")
        print("Private Key: \(privateKey)")
        
        let algClaim = "RS256"
        let keyTypeClaim = "RSA"
        let useClaim = "sig"
        let extClaim = true
        let keyopsClaim = ["verify"]
        let eClaim = "AQAB"
        
        // Get public key modulus.  Used https://stackoverflow.com/a/43225656
        let pubKeyAtts = SecKeyCopyAttributes(publicKey!) as! [String : Any]
        let keySize = pubKeyAtts[kSecAttrKeySizeInBits as String] as! Int
        let pubKeyData = pubKeyAtts[kSecValueData as String] as! Data
        var modulus = pubKeyData.subdata(in: 8..<(pubKeyData.count - 5))
        if modulus.count > keySize / 8 {
            modulus.removeFirst(1)
        }
        let nClaim = TokenUtilities.encodeBase64urlNoPadding(modulus)
        
        let jwkClaims = JWKClaims(alg: algClaim, kty: keyTypeClaim, use: useClaim, ext: extClaim, key_ops: keyopsClaim, e: eClaim, n: nClaim!)
        let jwkEncoded = try? JSONEncoder().encode(jwkClaims)
        let jwkDecoded = try? JSONDecoder().decode(JWKClaims.self,from: jwkEncoded!)
        
        let keyClaim = jwkDecoded
        let nonceClaim = nonce
        let displayClaim = "page"
        
        let payload = PayloadClaims(key: keyClaim!, display: displayClaim, nonce: nonceClaim!)
        let json = try? JSONEncoder().encode(payload)
        return TokenUtilities.encodeBase64urlNoPadding(json)
    }
    
    
    /*
     Only used in development to clean out keychain
     */
    func deleteKeysInKeychain(tag: Data) {
        let query: [String: Any] =
            [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: tag,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            ]
        
        let status = SecItemDelete(query as CFDictionary)
        print("Removed keys from keychain status: \(status)")
    }
}

