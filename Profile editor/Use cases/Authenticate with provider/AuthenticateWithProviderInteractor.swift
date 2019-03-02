//
//  AuthenticateWithProviderInteractor.swift
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

protocol AuthenticateWithProviderBusinessLogic {
    func fetchProviderConfiguration(request: AuthenticateWithProvider.FetchConfiguration.Request, callback: @escaping (ProviderConfiguration?, String?)->())
    func registerClient(request: AuthenticateWithProvider.RegisterClient.Request, callback: @escaping (_ configuration: ProviderConfiguration?, _ registrationResponse:  RegistrationResponse?, _ errorString: String?) -> Void)
    func authenticateWithProvider(request: AuthenticateWithProvider.Authenticate.Request, viewController: AuthenticateWithProviderViewController, callback: @escaping (String?)->())
    func fetchUserInfo(request: AuthenticateWithProvider.UserInfo.Request)
    func logout()
    func processMessage(request: AuthenticateWithProvider.DisplayMessages.Request) 
}

protocol AuthenticateWithProviderDataStore {
    var webid: String? {get set}
}

class AuthenticateWithProviderInteractor: NSObject, AuthenticateWithProviderBusinessLogic, AuthenticateWithProviderDataStore, AuthStateChangeDelegate, URLSessionDelegate  {
    
    var presenter: AuthenticateWithProviderPresentationLogic?
    private var authState: AuthState?
    let kRedirectURI = "com.wm.POD-browser:/mypath"
    var viewController: UIViewController?
    var webid: String?
    
    
    // MARK: - VIP
    
    // Fetch configuration

    func fetchProviderConfiguration(request: AuthenticateWithProvider.FetchConfiguration.Request, callback: @escaping (ProviderConfiguration?, String?)->()) {
        webid = request.webid
        writeToTextView(status: "Fetching configuration...\n\n", message: nil)

        guard let issuer = URL(string: request.issuer!) else {
            let errorString = "Error creating URL for : \(request.issuer!)"
            callback(nil, errorString)
            return
        }
        let discoveryURL = issuer.appendingPathComponent(".well-known/openid-configuration")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: discoveryURL, completionHandler: {data, response, error in

            var error = error as NSError?
            if error != nil || data == nil {
                let errorDescription = "Connection error fetching discovery document \(discoveryURL): \(String(describing: error?.localizedDescription))."
                error = ErrorUtilities.error(code: ErrorCode.NetworkError, underlyingError: error! as NSError, description: errorDescription)
                DispatchQueue.main.async {
                    let errorString = "Error retrieving discovery document: \(error!.localizedDescription)"
                    callback(nil, errorString)
                }
                return
            }
            
//            print("Received data: \(String(data: data!, encoding: .utf8)!)")
//            print("Received url response: \(response as! HTTPURLResponse)")
            

            
            let urlResponse = response as! HTTPURLResponse
            if (urlResponse.statusCode != 200) {
                let URLResponseError = ErrorUtilities.HTTPError(HTTPResponse: urlResponse, data: data)
                let errorDescription = "Non-200 HTTP response \(urlResponse.statusCode) fetching discovery document \(discoveryURL)."
                let err = ErrorUtilities.error(code: ErrorCode.NetworkError, underlyingError: URLResponseError, description: errorDescription)
                DispatchQueue.main.async {
                    let errorString = "Error retrieving discovery document: \(err.localizedDescription)"
                    callback(nil, errorString)
                }
                return
            }
            
            let configuration = ProviderConfiguration(JSONData: data!, error: error)
            if error != nil {
                let errorDescription = "JSON error parsing document at \(discoveryURL): \(String(describing: error?.localizedDescription))"
                error = ErrorUtilities.error(code: ErrorCode.NetworkError, underlyingError: error, description: errorDescription)
                DispatchQueue.main.async {
                    let errorString = "Error retrieving discovery document: \(error!.localizedDescription)"
                    callback(nil, errorString)
                }
                return
            }
            self.writeToTextView(status: nil, message: data)
            
            DispatchQueue.main.async {
                callback(configuration, nil)
                session.invalidateAndCancel()
            }
        })
        task.resume()
    }
    
    // Register client
    
    func registerClient(request: AuthenticateWithProvider.RegisterClient.Request, callback: @escaping (_ configuration: ProviderConfiguration?, _ registrationResponse:  RegistrationResponse?, _ errorString: String?) -> Void) {
        let configuration = request.configuration
        guard let redirectURI = URL(string: kRedirectURI) else {
            let errorString = "Registration error creating URL for : \(kRedirectURI)"
            callback(nil, nil, errorString)
            return
        }
        
        let request = RegistrationRequest(configuration: configuration,
                                                                     redirectURIs: [redirectURI],
                                                                     responseTypes: ["code"],
                                                                     grantTypes: ["authorization_code"],
                                                                     subjectType: nil,
                                                                     tokenEndpointAuthMethod: "client_secret_post",
                                                                     additionalParameters: nil)

       writeToTextView(status: "------------------------\n\nRequesting registration...\n\n", message: nil)
        
        var URLRequest = request.urlRequest()
        
        if URLRequest == nil {
            // A problem occurred deserializing the response/JSON.
            let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.JSONSerializationError, underlyingError: nil, description: """
                The registration request could not \
                be serialized as JSON.
                """)
            DispatchQueue.main.async(execute: {
                let errorString = "Registration error: \(returnedError?.localizedDescription ?? "DEFAULT_ERROR")"
                self.setAuthState(nil)
                callback(nil, nil, errorString)
            })
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: URLRequest!, completionHandler: { data, response, error in
            
            if error != nil {
                // A network error or server error occurred.
                var errorDescription: String? = nil
                if let anURL = URLRequest!.url {
                    errorDescription = "Connection error making registration request to '\(anURL)': \(error?.localizedDescription ?? "")."
                }
                let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.NetworkError, underlyingError: error as NSError?, description: errorDescription)
                DispatchQueue.main.async(execute: {
                    let errorString = "Registration error: \(returnedError?.localizedDescription ?? "DEFAULT_ERROR")"
                    self.setAuthState(nil)
                    callback(nil, nil, errorString)
                })
                return
            }
            
            
            let HTTPURLResponse = response as? HTTPURLResponse
            if HTTPURLResponse?.statusCode != 201 && HTTPURLResponse?.statusCode != 200 {
                // A server error occurred.
                let serverError = ErrorUtilities.HTTPError(HTTPResponse: HTTPURLResponse!, data: data)
                // HTTP 400 may indicate an OpenID Connect Dynamic Client Registration 1.0 Section 3.3 error
                // response, checks for that
                if HTTPURLResponse?.statusCode == 400 {
                    var json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : (NSObject & NSCopying)]
                    // if the HTTP 400 response parses as JSON and has an 'error' key, it's an OAuth error
                    // these errors are special as they indicate a problem with the authorization grant
                    if json?![OIDOAuthErrorFieldError] != nil {
                        let oauthError = ErrorUtilities.OAuthError(OAuthErrorDomain: OIDOAuthRegistrationErrorDomain, OAuthResponse: json!, underlyingError: serverError)
                        DispatchQueue.main.async(execute: {
                            let errorString = "Registration error: \(oauthError.localizedDescription)"
                            self.setAuthState(nil)
                            callback(nil, nil, errorString)
                        })
                        return
                    }
                }
                // not an OAuth error, just a generic server error
                var errorDescription: String? = nil
                if let anURL = URLRequest!.url {
                    errorDescription = """
                    Non-200/201 HTTP response (\(Int(HTTPURLResponse?.statusCode ?? 0))) making registration request \
                    to '\(anURL)'.
                    """
                }
                let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.ServerError, underlyingError: serverError, description: errorDescription)
                DispatchQueue.main.async(execute: {
                    let errorString = "Registration error: \(returnedError!.localizedDescription)"
                    self.setAuthState(nil)
                    callback(nil, nil, errorString)
                })
                return
            }
            var json:[String : Any]?
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            }
            catch {
                // A problem occurred deserializing the response/JSON.
                let errorDescription = "JSON error parsing registration response: \(error.localizedDescription)"
                let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.JSONDeserializationError, underlyingError: error as NSError, description: errorDescription)
                DispatchQueue.main.async(execute: {
                     let errorString = "Registration error: \(returnedError!.localizedDescription)"
                    self.setAuthState(nil)
                    callback(nil, nil, errorString)
                })
                return
            }
            self.writeToTextView(status: nil, message: data)
            let registrationResponse = RegistrationResponse(request: request, parameters: json!)
            if registrationResponse == nil {
                // A problem occurred constructing the registration response from the JSON.
                let returnedError: NSError? = ErrorUtilities.error(code: ErrorCode.RegistrationResponseConstructionError, underlyingError: nil, description: "Registration response invalid.")
                DispatchQueue.main.async(execute: {
                    let errorString = "Registration error: \(returnedError!.localizedDescription)"
                    self.setAuthState(nil)
                    callback(nil, nil, errorString)
                })
                return
            }
            
            // Success
            self.writeToTextView(status: "------------------------\n\n", message: nil)
            print("Got registration response: \(registrationResponse.description())")
            
            DispatchQueue.main.async(execute: {
                callback(configuration, registrationResponse, nil)
                session.invalidateAndCancel()
            })
            
        }).resume()
        
    }
    
    // Authentication request
    
    func authenticateWithProvider(request: AuthenticateWithProvider.Authenticate.Request, viewController: AuthenticateWithProviderViewController, callback: @escaping (String?)->()) {
        
        // Construct authorisation request
        
        guard let redirectURI = URL(string: kRedirectURI) else { print("Error creating URL for : \(kRedirectURI)"); return }
        self.viewController = viewController
        let configuration = request.configuration
        let clientID = request.clientID
        let clientSecret = request.clientSecret
        let request = AuthorizationRequest(configuration: configuration, 
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [kScopeOpenID, kScopeProfile, kScopeWebID],
                                              redirectURL: redirectURI,
                                              responseType: kResponseTypeCode,
                                              additionalParameters: nil)
        
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        writeToTextView(status: "Requesting authorization...\n\n", message: nil)
        
        // Get HandleAuthenticationServices to launch the ASWebauthenticationServices view controller
        // If successful, the authorization tokens are returned in the callback.
        // The authorization flow is stored in the app delegate.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { callback("Error accessing AppDelegate"); return }
        let authSession = AuthenticationSession()
        appDelegate.currentAuthorizationFlow = authSession.fetchAuthState(authorizationRequest: request, presentingViewController: viewController) { authState, error in
            
            if error == nil {
                self.writeToTextView(status: "Got authorization code and state code\n\nRequesting tokens...\n\n", message: nil)
                self.writeToTextView(status: "Got access token: \n", message: "\(authState!.lastTokenResponse!.accessToken!)\n")
                self.writeToTextView(status: "\nGot id token: \n", message: "\(authState!.lastTokenResponse!.idToken!)\n")
                self.writeToTextView(status: "\nGot refresh token:\n", message: "\(authState!.lastTokenResponse!.refreshToken!)")
                if let authState = authState {
                    self.setAuthState(authState)
                    print("Got authorization tokens. \nAccess token: \(authState.lastTokenResponse!.accessToken!) \nID token: \(authState.lastTokenResponse!.idToken!)")
                    callback(nil)
                }
            }
            else {
                let errorString = "Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")"
                self.setAuthState(nil)
                callback(errorString)
            }
        }
            
    }
    
    
    func logout() {
//        let cookieStorage = HTTPCookieStorage.shared
    }
    
    
    func fetchUserInfo(request: AuthenticateWithProvider.UserInfo.Request) {
        let userinfoEndpoint = authState!.lastAuthorizationResponse!.request!.configuration!.discoveryDocument!.userinfoEndpoint
//        let userinfoEndpoint = URL(string: "https://warwicks-macbook.local:8443/userinfo")
        if userinfoEndpoint == nil {
            print("Userinfo endpoint not declared in discovery document")
            return
        }
        let currentAccessToken = authState!.lastTokenResponse!.accessToken
        print("Performing userinfo request")
        let tokenManager = TokenManager(authState: authState!)
        tokenManager.performActionWithFreshTokens() { accessToken, idToken, error in
            
            if error != nil {
                print("Error fetching fresh tokens: \(error!.localizedDescription)")
                return
            }
            
            // log whether a token refresh occurred
            if currentAccessToken != accessToken {
                print("Access token was refreshed automatically")
            } else {
                print("Access token was fresh and not updated \(accessToken!)")
            }
            
            // creates request to the userinfo endpoint, with access token in the Authorization header  // check 'Content-Type': 'application/json'
            var request =  URLRequest(url: userinfoEndpoint!)
            request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                
                DispatchQueue.main.async {
                    if error != nil {
                        print("HTTP request failed: \(error!)")
                        return
                    }
                    if !(response is HTTPURLResponse)   {
                        print("Non-HTTP response")
                        return
                    }
                    
                    let httpResponse = response as! HTTPURLResponse

                    var jsonDictionaryOrArray: [AnyHashable: Any]?
                    
                    do {
                        jsonDictionaryOrArray = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                    } catch {
                        print("JSON Serialization Error")
                    }
                    
                    if (httpResponse.statusCode != 200) {
                        // server replied with an error
                        let responseText = String(data: data!, encoding: String.Encoding.utf8)

                        if (httpResponse.statusCode == 401) {
                            // "401 Unauthorized" generally indicates there is an issue with the authorization
                            // grant. Puts AuthState into an error state.
                            let oauthError = ErrorUtilities.resourceServerAuthorizationError(code: 0,
                                                                                                errorResponse: jsonDictionaryOrArray,
                                                                                                underlyingError: error as NSError?)

                            self.authState!.update(withAuthorizationError: oauthError)

                            print("Authorization Error \(oauthError). Response: \(responseText!)")
                        } else {
                            print("HTTP: \(httpResponse.statusCode). Response: \(responseText!)")
                        }
                        return
                    }
                    
                    // success response
                    print("Success: \(jsonDictionaryOrArray!)")
                }
            })
            task.resume()
        }
    }
    
    
    func processMessage(request: AuthenticateWithProvider.DisplayMessages.Request) {
        let response = AuthenticateWithProvider.DisplayMessages.Response(message: request.message)
        presenter!.processMessage(response: response)
    }
    
    
    // MARK: - Helpers
    
    func setAuthState(_ authState: AuthState?) {
        if (self.authState == authState) {
            return
        }
        authState?.webid = webid
        self.authState = authState
        //       self.authState?.stateChangeDelegate = self
        self.stateChanged()
    }
    
    
    
    func stateChanged() {
        AuthState.saveState(authState: self.authState!)
    }
    
    func writeToTextView(status: String?, message: Any?) {
        var userInfo = [String : Any]()
        if status != nil {
            userInfo["status"] = status
        }
        if message != nil {
            userInfo["message"] = message
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MessageNotification"), object: nil, userInfo: userInfo as [AnyHashable : Any])
    }
    
    
    // MARK: - AuthChangeStateDelegate method
    func didChange(state: AuthState?) {
        stateChanged()
    }
    
    // MARK: - URLSessionDelegate methods
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("urlSession(_:task:didReceive:completionHandler) called")
    }

}
