//
//  AuthState.swift
//  POD browser
//
//  Created by Warwick McNaughton on 19/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import Foundation



protocol AuthStateChangeDelegate: NSObjectProtocol {
    func didChange(state: AuthState?)
}



@objc protocol AuthStateErrorDelegate: NSObjectProtocol {
    func authState(state: AuthState?, didEncounterAuthorizationError: NSError?)
    @objc optional func authState(state: AuthState?, didEncounterTransientError: NSError?)
}



private let kRefreshTokenKey = "refreshToken"
private let kNeedsTokenRefreshKey = "needsTokenRefresh"
private let kScopeKey = "scope"
private let kLastAuthorizationResponseKey = "lastAuthorizationResponse"
private let kLastTokenResponseKey = "lastTokenResponse"
private let kAuthorizationErrorKey = "authorizationError"
private let kRefreshTokenRequestException = "Attempted to create a token refresh request from a token response with no refresh token."
private let kGrantTypeRefreshToken = "refresh_token"

//typealias OIDAuthStateAction = (String?, String?, Error?) -> Void
//typealias OIDAuthStateAuthorizationCallback = (OIDAuthState?, Error?) -> Void

private let kAuthStateKey: String = "authState"



class AuthStatePendingAction: NSObject {
    
    
    private(set) var action: ((String?, String?, Error?) -> Void?)?
    private(set) var dispatchQueue: DispatchQueue?
    
    
    init(action: @escaping (String?, String?, Error?) -> Void, andDispatchQueue dispatchQueue: DispatchQueue) {
        super.init()
        
        self.action = action
        self.dispatchQueue = dispatchQueue
    }
}

class AuthState: NSObject, Codable {
    /*! @brief The access token generated by the authorization server.
     @discussion Rather than using this property directly, you should call
     @c OIDAuthState.withFreshTokenPerformAction:.
     */
    var accessToken: String? {
        get {
            if authorizationError != nil {
                return nil
            }
            return (lastTokenResponse != nil) ? lastTokenResponse!.accessToken : lastAuthorizationResponse!.accessToken
        }
    }
    
    var tokenType: String? {
        get {
            if authorizationError != nil {
                return nil
            }
            return (lastTokenResponse != nil) ? lastTokenResponse!.tokenType : lastAuthorizationResponse!.tokenType
        }
    }
    
    /*! @brief The approximate expiration date & time of the access token.
     @discussion Rather than using this property directly, you should call
     @c OIDAuthState.withFreshTokenPerformAction:.
     */
    var accessTokenExpirationDate: Date? {
        get {
            if authorizationError != nil {
                return nil
            }
            return (lastTokenResponse != nil) ? lastTokenResponse!.accessTokenExpirationDate : lastAuthorizationResponse!.accessTokenExpirationDate
        }
    }
    
    /*! @brief ID Token value associated with the authenticated session.
     @discussion Rather than using this property directly, you should call
     OIDAuthState.withFreshTokenPerformAction:.
     */
    var idToken: String? {
        get {
            if authorizationError != nil {
                return nil
            }
            return (lastTokenResponse != nil) ? lastTokenResponse!.idToken : lastAuthorizationResponse!.idToken
        }
    }
    
    /*! @brief Array of pending actions (use @c _pendingActionsSyncObject to synchronize access).
     */
    var pendingActions: [AnyHashable]? = []
    /*! @brief Object for synchronizing access to @c pendingActions.
     */
    var pendingActionsSyncObject: Any?
    /*! @brief If YES, tokens will be refreshed on the next API call regardless of expiry.
     */
    var needsTokenRefresh = false
    
    /*! @brief The most recent refresh token received from the server.
     @discussion Rather than using this property directly, you should call
     @c OIDAuthState.performActionWithFreshTokens:.
     @remarks refresh_token
     @see https://tools.ietf.org/html/rfc6749#section-5.1
     */
    private(set) var refreshToken: String?
    /*! @brief The scope of the current authorization grant.
     @discussion This represents the latest scope returned by the server and may be a subset of the
     scope that was initially granted.
     @remarks scope
     */
    private(set) var scope: String?
    /*! @brief The most recent authorization response used to update the authorization state. For the
     implicit flow, this will contain the latest access token.
     */
    private(set) var lastAuthorizationResponse: AuthorizationResponse?
    /*! @brief The most recent token response used to update this authorization state. This will
     contain the latest access token.
     */
    private(set) var lastTokenResponse: TokenResponse?
    /*! @brief The most recent registration response used to update this authorization state. This will
     contain the latest client credentials.
     */
    private(set) var lastRegistrationResponse: RegistrationResponse?
    /*! @brief The authorization error that invalidated this @c OIDAuthState.
     @discussion The authorization error encountered by @c OIDAuthState or set by the user via
     @c OIDAuthState.updateWithAuthorizationError: that invalidated this @c OIDAuthState.
     Authorization errors from @c OIDAuthState will always have a domain of
     @c ::OIDOAuthAuthorizationErrorDomain or @c ::OIDOAuthTokenErrorDomain. Note: that after
     unarchiving the @c OIDAuthState object, the \NSError_userInfo property of this error will
     be nil.
     */
    private(set) var authorizationError: Error?
    /*! @brief Returns YES if the authorization state is not known to be invalid.
     @discussion Returns YES if no OAuth errors have been received, and the last call resulted in a
     successful access token or id token. This does not mean that the access is fresh - just
     that it was valid the last time it was used. Note that network and other transient errors
     do not invalidate the authorized state.  If NO, you should authenticate the user again,
     using a fresh authorization request. Invalid @c OIDAuthState objects may still be useful in
     that case, to hint at the previously authorized user and streamline the re-authentication
     experience.
     */
    private var isAuthorized: Bool {
        get {
            return  (self.authorizationError == nil) && (self.accessToken != nil || self.idToken != nil || self.refreshToken != nil);
        }
    }
    /*! @brief The @c OIDAuthStateChangeDelegate delegate.
     @discussion Use the delegate to observe state changes (and update storage) as well as error
     states.
     */
    weak var stateChangeDelegate: AuthStateChangeDelegate?
    /*! @brief The @c OIDAuthStateErrorDelegate delegate.
     @discussion Use the delegate to observe state changes (and update storage) as well as error
     states.
     */
    weak var errorDelegate: AuthStateErrorDelegate?
    
    

    
    // MARK: - Object lifecycle
    
    /*! @brief Creates an auth state from an authorization response.
     @param authorizationResponse The authorization response.
     */
    convenience init(authorizationResponse: AuthorizationResponse?) {
        self.init(authorizationResponse: authorizationResponse, tokenResponse: nil)
    }
    /*! @brief Designated initializer.
     @param authorizationResponse The authorization response.
     @discussion Creates an auth state from an authorization response and token response.
     */
    convenience init(authorizationResponse: AuthorizationResponse?, tokenResponse: TokenResponse?) {
        self.init(authorizationResponse: authorizationResponse, tokenResponse: tokenResponse, registrationResponse: nil)
    }
    /*! @brief Creates an auth state from an registration response.
     @param registrationResponse The registration response.
     */
    convenience init(registrationResponse: RegistrationResponse?) {
        self.init(authorizationResponse: nil, tokenResponse: nil, registrationResponse: registrationResponse)
    }
    init(authorizationResponse: AuthorizationResponse?, tokenResponse: TokenResponse?, registrationResponse: RegistrationResponse?) {
        super.init()
        
        pendingActionsSyncObject = NSObject()
        if registrationResponse != nil {
            update(withRegistrationResponse: registrationResponse)
        }
        if authorizationResponse != nil {
            update(withAuthorizationResponse: authorizationResponse, error: nil)
        }
        if tokenResponse != nil {
            update(withTokenResponse: tokenResponse, error: nil)
        }
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case lastAuthorizationResponse
        case lastTokenResponse
        case refreshToken
        case authorizationError
        case scope
        case needsTokenRefresh
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastAuthorizationResponse, forKey: CodingKeys.lastAuthorizationResponse)
        try container.encode(lastTokenResponse, forKey: CodingKeys.lastTokenResponse)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(authorizationError?.localizedDescription, forKey: CodingKeys.authorizationError)
        try container.encode(scope, forKey: .scope)
        try container.encode(needsTokenRefresh, forKey: .needsTokenRefresh)
    }
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lastAuthorizationResponse = try values.decode(AuthorizationResponse.self, forKey: .lastAuthorizationResponse)
        lastTokenResponse = try values.decode(TokenResponse.self, forKey: .lastTokenResponse)
        refreshToken = try values.decode(String.self, forKey: .refreshToken)
        scope = try values.decode(String.self, forKey: .scope)
        needsTokenRefresh = try values.decode(Bool.self, forKey: .needsTokenRefresh)
    }
    
    
    func description() -> String? {
        return String(format: """
        <%@: %p, isAuthorized: %@, refreshToken: "%@", \
        scope: "%@", accessToken: "%@", \
        accessTokenExpirationDate: %@, idToken: "%@", \
        lastAuthorizationResponse: %@, lastTokenResponse: %@, \
        lastRegistrationResponse: %@, authorizationError: %@>
        """, NSStringFromClass(type(of: self).self), self, (isAuthorized) ? "YES" : "NO", TokenUtilities.redact(refreshToken)!, scope!, TokenUtilities.redact(accessToken)!, accessTokenExpirationDate! as CVarArg, TokenUtilities.redact(idToken)!, lastAuthorizationResponse!, lastTokenResponse!, lastRegistrationResponse!, authorizationError! as CVarArg)
    }
    
    
    func getAccessToken() -> String? {
        if (authorizationError != nil) {
            return nil
        }
        return lastTokenResponse != nil  ? lastTokenResponse!.accessToken : lastAuthorizationResponse!.accessToken
    }
    
    
    func getTokenType() -> String? {
        if (authorizationError != nil) {
            return nil
        }
        return (lastTokenResponse != nil) ? lastTokenResponse!.tokenType : lastAuthorizationResponse!.tokenType
    }
    
    
    func getAccessTokenExpirationDate() -> Date? {
        if (authorizationError != nil) {
            return nil
        }
        return lastTokenResponse != nil ? lastTokenResponse!.accessTokenExpirationDate : lastAuthorizationResponse!.accessTokenExpirationDate
    }
    
    
    func getIdToken() -> String? {
        if (authorizationError != nil) {
            return nil
        }
        return lastTokenResponse != nil ? lastTokenResponse!.idToken : lastAuthorizationResponse!.idToken
    }
    
    func getIsAuthorized() -> Bool {
        return authorizationError == nil && ((accessToken != nil) || (idToken != nil) || (refreshToken != nil))
    }
    
    // MARK: - Updating the state
    func update(withRegistrationResponse response: RegistrationResponse?) {
        lastRegistrationResponse = response
        refreshToken = nil
        scope = nil
        lastAuthorizationResponse = nil
        lastTokenResponse = nil
        authorizationError = nil
        didChangeState()
    }
    
    func update(withAuthorizationResponse response: AuthorizationResponse?, error: NSError?)  {
        // If the error is an OAuth authorization error, updates the state. Other errors are ignored.
        if (error as NSError?)?.domain == OIDOAuthAuthorizationErrorDomain {
            update(withAuthorizationError: error)
            return
        }
        if response == nil {
            return
        }
        lastAuthorizationResponse = response
        // clears the last token response and refresh token as these now relate to an old authorization
        // that is no longer relevant
        lastTokenResponse = nil
        refreshToken = nil
        authorizationError = nil
        // if the response's scope is nil, it means that it equals that of the request
        // see: https://tools.ietf.org/html/rfc6749#section-5.1
        scope = (response?.scope) != nil ? response?.scope : response?.request!.scope
        didChangeState()
    }
    
    func update(withTokenResponse response: TokenResponse?, error: NSError?)  {
        if (authorizationError != nil) {
            // Calling updateWithTokenResponse while in an error state probably means the developer obtained
            // a new token and did the exchange without also calling updateWithAuthorizationResponse.
            // Attempts to handle gracefully, but warns the developer that this is unexpected.
            print("""
                OIDAuthState:updateWithTokenResponse should not be called in an error state [\(authorizationError!)] call\
                updateWithAuthorizationResponse with the result of the fresh authorization response\
                first
                """)
            authorizationError = nil
        }
        // If the error is an OAuth authorization error, updates the state. Other errors are ignored.
        if (error as NSError?)?.domain == OIDOAuthTokenErrorDomain {
            update(withAuthorizationError: error)
            return
        }
        if response == nil {
            return
        }
        lastTokenResponse = response
        // updates the scope and refresh token if they are present on the TokenResponse.
        // according to the spec, these may be changed by the server, including when refreshing the
        // access token. See: https://tools.ietf.org/html/rfc6749#section-5.1 and
        // https://tools.ietf.org/html/rfc6749#section-6
        if response?.scope != nil {
            scope = response?.scope
        }
        if response?.refreshToken != nil {
            refreshToken = response?.refreshToken
        }
        didChangeState()
    }
    
    
    func update(withAuthorizationError oauthError: NSError? )  {
        authorizationError = oauthError
        didChangeState()
        errorDelegate!.authState(state: self, didEncounterAuthorizationError: oauthError)
    }
    
    // MARK: - OAuth Requests
    func tokenRefreshRequest() -> TokenRequest? {
        return tokenRefreshRequest(withAdditionalParameters: nil)
    }
    
    
    func tokenRefreshRequest(withAdditionalParameters additionalParameters: [String : AnyCodable]?) -> TokenRequest? {
        // TODO: Add unit test to confirm exception is thrown when expected
        if !(refreshToken != nil) {
            ErrorUtilities.raiseException(name: kRefreshTokenRequestException)
        }
        return TokenRequest(configuration: lastAuthorizationResponse!.request!.configuration, grantType: kGrantTypeRefreshToken, authorizationCode: nil, redirectURL: nil, clientID: lastAuthorizationResponse!.request!.clientID, clientSecret: lastAuthorizationResponse!.request!.clientSecret, scope: nil, refreshToken: refreshToken, codeVerifier: nil, nonce: nil, additionalParameters: additionalParameters)
    }
    
    // MARK: - Stateful Actions
    func didChangeState() {
        stateChangeDelegate?.didChange(state: self)
    }
    
    func setNeedsTokenRefresh() {
        needsTokenRefresh = true
    }
    

    
    
    // MARK: -
 
    class  func saveState(authState: AuthState) {
        var encodedAuthStateData: Data? = nil
        let encoder = JSONEncoder()

        do {
            encodedAuthStateData = try encoder.encode(authState)
        }
        catch {
            print(error)
        }
        
        UserDefaults.standard.set(encodedAuthStateData, forKey: kAuthStateKey)
        UserDefaults.standard.synchronize()
    }
    
    
    class func loadState() -> AuthState? {
        guard let data = UserDefaults.standard.object(forKey: kAuthStateKey) as? Data else {
            return nil
        }
        let decoder = JSONDecoder()
        var authState: AuthState?
        do {
            authState = try decoder.decode(AuthState.self, from: data)
        }
        catch {
            print(error)
        }
  //      self.setAuthState(authState)
        return authState
    }
    
}
