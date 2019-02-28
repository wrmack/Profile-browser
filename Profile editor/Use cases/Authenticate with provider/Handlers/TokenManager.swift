//
//  TokenManager.swift
//  POD browser
//
//  Created by Warwick McNaughton on 21/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import UIKit


fileprivate let kGrantTypeAuthorizationCode = "authorization_code"

class TokenManager {
    
    var authState: AuthState?
    /*! @brief Number of seconds the access token is refreshed before it actually expires.
     */
    private let kExpiryTimeTolerance: Int = 60
    
    
    init(authState: AuthState) {
        self.authState = authState
    }
    
    func performActionWithFreshTokens(action: @escaping (String?, String?, Error?) -> Void) {
        performActionWithFreshTokens(action: action, additionalRefreshParameters: nil)
    }

    func performActionWithFreshTokens(action: @escaping (String?, String?, Error?) -> Void, additionalRefreshParameters additionalParameters: [String : AnyCodable]?) {
        performActionWithFreshTokens(action: action, additionalRefreshParameters: additionalParameters, dispatchQueue: DispatchQueue.main)
    }

    func performActionWithFreshTokens(action: @escaping (String?, String?, Error?) -> Void, additionalRefreshParameters additionalParameters: [String : AnyCodable]?, dispatchQueue: DispatchQueue) {
        if isTokenFresh() {
            // access token is valid within tolerance levels, perform action
            dispatchQueue.async(execute: {
                action(self.authState!.accessToken, self.authState!.idToken, nil)
            })
            return
        }
        if (authState!.refreshToken == nil) {
            // no refresh token available and token has expired
            let tokenRefreshError: Error? = ErrorUtilities.error(code: ErrorCode.TokenRefreshError, underlyingError: nil, description: "Unable to refresh expired token without a refresh token.")
            dispatchQueue.async(execute: {
                action(nil, nil, tokenRefreshError)
            })
            return
        }

        // access token is expired, first refresh the token, then perform action
   //    assert((pendingActionsSyncObject != nil), String(format: "_pendingActionsSyncObject cannot be nil", ""))
        let pendingAction = AuthStatePendingAction(action: action, andDispatchQueue: dispatchQueue)
        let lockQueue = DispatchQueue(label: "pendingActionsSyncObject")
        lockQueue.sync {
            // if a token is already in the process of being refreshed, adds to pending actions
            if authState!.pendingActions != nil {
                authState!.pendingActions!.append(pendingAction)
                return
            }
            // creates a list of pending actions, starting with this one
            authState!.pendingActions = [pendingAction]
        }

        // refresh the tokens
        let tokenRefreshRequest = authState!.tokenRefreshRequest(withAdditionalParameters: additionalParameters)

        perform(tokenRequest: tokenRefreshRequest, originalAuthorizationResponse: authState!.lastAuthorizationResponse, callback: { response, error in
            // update OIDAuthState based on response
            if response != nil {
                self.authState!.needsTokenRefresh = false
                self.authState!.update(withTokenResponse: response, error: nil)
            } else {
                if (error as NSError?)?.domain == OIDOAuthTokenErrorDomain {
                    self.authState!.needsTokenRefresh = false
                    self.authState!.update(withAuthorizationError: error)
                } else {
//                    if self.authState!.errorDelegate!.responds(to: #selector(OIDAuthStateErrorDelegate.authState(state:didEncounterTransientError:))) {
//                        self.authState!.errorDelegate!.authState!(state:self.authState!, didEncounterTransientError: error)
//                    }
                }
            }
            // nil the pending queue and process everything that was queued up
            var actionsToProcess: [Any] = []
            let lockQueue = DispatchQueue(label: "self.pendingActionsSyncObject")
            lockQueue.sync {
                actionsToProcess = self.authState!.pendingActions!
                self.authState!.pendingActions = nil
            }
            for actionToProcess: AuthStatePendingAction in actionsToProcess as? [AuthStatePendingAction] ?? [] {
                actionToProcess.dispatchQueue!.async(execute: {
                    actionToProcess.action!(self.authState!.accessToken, self.authState!.idToken, error)
                })
            }
        })

    }
    
    
    func perform(tokenRequest request: TokenRequest?, originalAuthorizationResponse authorizationResponse: AuthorizationResponse?, callback: @escaping (TokenResponse?, NSError?) -> Void) {
        
        var URLRequest: URLRequest = request!.urlRequest()
        //        AppAuthRequestTrace(@"Token Request: %@\nHeaders:%@\nHTTPBody: %@",
        //                             URLRequest.URL,
        //                             URLRequest.allHTTPHeaderFields,
        //                             [[NSString alloc] initWithData:URLRequest.HTTPBody
        //                                encoding:NSUTF8StringEncoding]);
        let session = URLSession.shared
        session.dataTask(with: URLRequest, completionHandler: { data, response, error in
            
            if error != nil {
                // A network error or server error occurred.
                var errorDescription: String? = nil
                if let anURL = URLRequest.url {
                    errorDescription = "Connection error making token request to '\(anURL)': \(error?.localizedDescription ?? "")."
                }
                let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.NetworkError, underlyingError: error as NSError?, description: errorDescription)
                DispatchQueue.main.async(execute: {
                    callback(nil, returnedError)
                })
                return
            }
            
            //  The converted code is limited to 2 KB.
            //  Upgrade your plan to remove this limitation.
            //
            let HTTPURLResponse = response as? HTTPURLResponse
            let statusCode: Int? = HTTPURLResponse?.statusCode
            //         AppAuthRequestTrace("Token Response: HTTP Status %d\nHTTPBody: %@", Int(statusCode ?? 0), String(data: data, encoding: .utf8))
            if statusCode != 200 {
                // A server error occurred.
                let serverError = ErrorUtilities.HTTPError(HTTPResponse: HTTPURLResponse!, data: data)
                // HTTP 4xx may indicate an RFC6749 Section 5.2 error response, attempts to parse as such.
                if statusCode! >= 400 && statusCode! < 500 {
 
                    var json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : (NSObject & NSCopying)]
                    // If the HTTP 4xx response parses as JSON and has an 'error' key, it's an OAuth error.
                    // These errors are special as they indicate a problem with the authorization grant.
                    if json?![OIDOAuthErrorFieldError] != nil {
                        let oauthError = ErrorUtilities.OAuthError( OAuthErrorDomain: OIDOAuthTokenErrorDomain, OAuthResponse: json!, underlyingError: serverError)
                        DispatchQueue.main.async(execute: {
                            callback(nil, oauthError)
                        })
                        return
                    }
                }
                
                // Status code indicates this is an error, but not an RFC6749 Section 5.2 error.
                var errorDescription: String? = nil
                if let anURL = URLRequest.url {
                    errorDescription = "Non-200 HTTP response (\(statusCode!)) making token request to '\(anURL)'."
                }
                let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.ServerError, underlyingError: serverError, description: errorDescription)
                DispatchQueue.main.async(execute: {
                    callback(nil, returnedError)
                })
                return
            }
            
            //           let jsonDeserializationError: NSError?
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : (NSObject & NSCopying)]
            //            if jsonDeserializationError != nil {
            //                // A problem occurred deserializing the response/JSON.
            //                let errorDescription = "JSON error parsing token response: \(jsonDeserializationError?.localizedDescription ?? "")"
            //                let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.JSONDeserializationError, underlyingError: jsonDeserializationError, description: errorDescription)
            //                DispatchQueue.main.async {
            //                    callback(nil, returnedError)
            //                }
            //                return
            //            }
            let tokenResponse = TokenResponse(request: request, parameters: json!)
            
            //            if tokenResponse == nil {
            //                // A problem occurred constructing the token response from the JSON.
            //                let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.TokenResponseConstructionError, underlyingError: jsonDeserializationError, description: "Token response invalid.")
            //                DispatchQueue.main.async {
            //                    callback(nil, returnedError)
            //                }
            //                return
            //            }
            
            
            // If an ID Token is included in the response, validates the ID Token following the rules
            // in OpenID Connect Core Section 3.1.3.7 for features that AppAuth directly supports
            // (which excludes rules #1, #4, #5, #7, #8, #12, and #13). Regarding rule #6, ID Tokens
            // received by this class are received via direct communication between the Client and the Token
            // Endpoint, thus we are exercising the option to rely only on the TLS validation. AppAuth
            // has a zero dependencies policy, and verifying the JWT signature would add a dependency.
            // Users of the library are welcome to perform the JWT signature verification themselves should
            // they wish.
            if tokenResponse.idToken != nil {
                let idToken = IDToken(idTokenString: tokenResponse.idToken)
                
                if idToken == nil {
                    let invalidIDToken: NSError? = ErrorUtilities.error(code: ErrorCode.IDTokenParsingError, underlyingError: nil, description: "ID Token parsing failed")
                    DispatchQueue.main.async(execute: {
                        callback(nil, invalidIDToken)
                    })
                    return
                }
                
                
                
                // OpenID Connect Core Section 3.1.3.7. rule #1
                // Not supported: AppAuth does not support JWT encryption.
                
                // OpenID Connect Core Section 3.1.3.7. rule #2
                // Validates that the issuer in the ID Token matches that of the discovery document.
                let issuer: URL? = tokenResponse.request!.configuration!.issuer
                if issuer != nil && !(idToken!.issuer == issuer) {
                    let invalidIDToken: NSError? = ErrorUtilities.error(code: ErrorCode.IDTokenFailedValidationError, underlyingError: nil, description: "Issuer mismatch")
                    DispatchQueue.main.async(execute: {
                        callback(nil, invalidIDToken)
                    })
                    return
                }
                
                // OpenID Connect Core Section 3.1.3.7. rule #3
                // Validates that the audience of the ID Token matches the client ID.
                let clientID = tokenResponse.request!.clientID
                if !idToken!.audience!.contains(clientID) {
                    let invalidIDToken: NSError? = ErrorUtilities.error(code: ErrorCode.IDTokenFailedValidationError, underlyingError: nil, description: "Audience mismatch")
                    DispatchQueue.main.async(execute: {
                        callback(nil, invalidIDToken)
                    })
                    return
                }
                
                // OpenID Connect Core Section 3.1.3.7. rules #4 & #5
                // Not supported.
                
                // OpenID Connect Core Section 3.1.3.7. rule #6
                // As noted above, AppAuth only supports the code flow which results in direct communication
                // of the ID Token from the Token Endpoint to the Client, and we are exercising the option to
                // use TSL server validation instead of checking the token signature. Users may additionally
                // check the token signature should they wish.
                
                // OpenID Connect Core Section 3.1.3.7. rules #7 & #8
                // Not applicable. See rule #6.
                
                // OpenID Connect Core Section 3.1.3.7. rule #9
                // Validates that the current time is before the expiry time.
                let expiresAtDifference: TimeInterval = idToken!.expiresAt!.timeIntervalSinceNow
                if expiresAtDifference < 0 {
                    let invalidIDToken: NSError? = ErrorUtilities.error(code: ErrorCode.IDTokenFailedValidationError, underlyingError: nil, description: "ID Token expired")
                    DispatchQueue.main.async(execute: {
                        callback(nil, invalidIDToken)
                    })
                    return
                }
                // OpenID Connect Core Section 3.1.3.7. rule #10
                // Validates that the issued at time is not more than +/- 10 minutes on the current time.
                let issuedAtDifference: TimeInterval = idToken!.issuedAt!.timeIntervalSinceNow
                if abs(Float(issuedAtDifference)) > 600 {
                    let invalidIDToken: NSError? = ErrorUtilities.error(code: ErrorCode.IDTokenFailedValidationError, underlyingError: nil, description: """
                        Issued at time is more than 5 minutes before or after \
                        the current time
                        """)
                    DispatchQueue.main.async(execute: {
                        callback(nil, invalidIDToken)
                    })
                    return
                }
                
                // Only relevant for the authorization_code response type
                if tokenResponse.request!.grantType == kGrantTypeAuthorizationCode {
                    // OpenID Connect Core Section 3.1.3.7. rule #11
                    // Validates the nonce.
                    let nonce = authorizationResponse!.request!.nonce
                    if nonce != "" && !(idToken!.nonce == nonce) {
                        let invalidIDToken: NSError? = ErrorUtilities.error(code: ErrorCode.IDTokenFailedValidationError, underlyingError: nil, description: "Nonce mismatch")
                        DispatchQueue.main.async(execute: {
                            callback(nil, invalidIDToken)
                        })
                        return
                    }
                }
                // OpenID Connect Core Section 3.1.3.7. rules #12
                // ACR is not directly supported by AppAuth.
                // OpenID Connect Core Section 3.1.3.7. rules #12
                // max_age is not directly supported by AppAuth.
                
            }
            
            // Success
            DispatchQueue.main.async(execute: {
                callback(tokenResponse, nil)
            })
            
        }).resume()
    }
    
    
    /*! @fn isTokenFresh
     @brief Determines whether a token refresh request must be made to refresh the tokens.
     */
    func isTokenFresh() -> Bool {
        if authState!.needsTokenRefresh {
            // forced refresh
            return false
        }
        if authState!.accessTokenExpirationDate == nil {
            // if there is no expiration time but we have an access token, it is assumed to never expire
            return (authState!.accessToken != nil)
        }
        // has the token expired?
        let tokenFresh: Bool = Int(authState!.accessTokenExpirationDate!.timeIntervalSinceNow) > kExpiryTimeTolerance
        return tokenFresh
    }
}
