//
//  EditProfileInteractor.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 11/02/19.
//  Copyright (c) 2019 Warwick McNaughton. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import JavaScriptCore



protocol EditProfileBusinessLogic {
    func getSelectedItem()->Triple
    func saveTriple(request: EditProfile.EditTriple.Request, callback: @escaping (String?, String?)->())
    func setWebid(webid: String)
}

protocol EditProfileDataStore {
    var selectedItem: Triple? { get set }
    var context: JSContext? {get set}
    var storeTriples: [Triple]? {get set}
    var webid: String? {get set}
}



class EditProfileInteractor: NSObject, EditProfileBusinessLogic, EditProfileDataStore, URLSessionDelegate {
    var presenter: EditProfilePresentationLogic?
    var selectedItem: Triple?
    var context: JSContext?
    var storeTriples: [Triple]?
    var webid: String? 
    
    
    // MARK: - VIP

    /*
     Create a SPARQL request to replace existing resource with changed resource
     */
    func saveTriple(request: EditProfile.EditTriple.Request, callback: @escaping (String?, String?)->()) {
        let originalTripleSub = (selectedItem!.subject.1 == "Literal") ? "\"\(selectedItem!.subject.0)\"" : "<\(selectedItem!.subject.0)>"
        let originalTriplePred = (selectedItem!.predicate.1 == "Literal") ? "\"\(selectedItem!.predicate.0)\"" : "<\(selectedItem!.predicate.0)>"
        let originalTripleObj = (selectedItem!.object.1 == "Literal") ? "\"\(selectedItem!.object.0)\"" : "<\(selectedItem!.object.0)>"
        let originalTriple = "\(originalTripleSub) \(originalTriplePred) \(originalTripleObj) ."
        
        let replacementTripleSub = (request.triple!.subject.1 == "Literal") ? "\"\(request.triple!.subject.0)\"" : "<\(request.triple!.subject.0)>"
        let replacementTriplePred = (request.triple!.predicate.1 == "Literal") ? "\"\(request.triple!.predicate.0)\"" : "<\(request.triple!.predicate.0)>"
        let replacementTripleObj = (request.triple!.object.1 == "Literal") ? "\"\(request.triple!.object.0)\"" : "<\(request.triple!.object.0)>"
        let replacementTriple = "\(replacementTripleSub) \(replacementTriplePred) \(replacementTripleObj) ."
        
        // Get saved authstate to use saved tokens
        let authState = AuthState.loadState()
//        authState = nil
        
        // No saved authstate
        if authState == nil {
            callback("getTokens", nil)
            return
        }
        
        // The saved authstate is not for this webid
        if authState?.webid != webid  {
            callback("getTokens", nil)
            return
        }
        
        let popToken = POPToken(webId: webid!, authState: authState!)
        
        var urlRequest = URLRequest(url: URL(string: webid!)! )
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/sparql-update", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(popToken!.token!)", forHTTPHeaderField: "Authorization") // Check!!!!
        let bodyString = "DELETE DATA { \(originalTriple)}; INSERT DATA {\(replacementTriple)}"
        let body = bodyString.data(using: .utf8)
        urlRequest.httpBody = body
        print("urlRequest: \(urlRequest.allHTTPHeaderFields!)")
        
        fetch(urlRequest: urlRequest, callback: { dataString, mimeType, statusCode, authErrorInfo in
            
            print("dataString: \(dataString)")
            print("mimeType: \(mimeType)")
            print("Status code: \(statusCode)")
            print("authInfo: \(authErrorInfo!)")
            
            if statusCode == 401 && authErrorInfo!.count == 0 {
                DispatchQueue.main.async {
                    callback("getTokens", nil)
                }            
            }
            if statusCode == 401 && authErrorInfo!.count > 0 {
                let errorDescription = "\(authErrorInfo!["error"]!): \(authErrorInfo!["error_description"]!)"
                DispatchQueue.main.async {
                    callback(nil, errorDescription)
                }
            }
             else if statusCode == 200 {
                DispatchQueue.main.async {
                    callback("success", nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    callback("unknown error", nil)
                }
            }
        })
        
//        let response = EditProfile.EditTriple.Response()
//        presenter?.presentSomething(response: response)
    }
    
    
    // MARK: - Datastore
    
    func getSelectedItem()->Triple {
        return selectedItem!
    }
    
    
    func setWebid(webid: String) {
        self.webid = webid
    }
    
    // MARK: - Helpers
    /*
     Url fetcher with callback
     */
    func fetch(urlRequest: URLRequest, callback: @escaping (String, String, Int, [String : String]?) -> Void) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            let httpResponse = response as? HTTPURLResponse
            print("\nResponse:\n\(response! as Any)")
            print("\nAll headers:\n\(httpResponse!.allHeaderFields as! [String : Any])")
            
            // Authentication errors may be contained in the www-authentication header
            var authInfo = [String : String]()
            if httpResponse?.statusCode == 401 {
                if let authResponse = httpResponse?.allHeaderFields["Www-Authenticate"] as? String {
                    if authResponse.contains("error") {
                        let type = authResponse.prefix(upTo: authResponse.firstIndex(of: " ")!)
                        authInfo["type"] = String(type)
                        let claims = authResponse.suffix(from: authResponse.firstIndex(of: " ")!)
 //                       claims.removeAll(where: {$0 == " "})
                        let claimsArray = claims.split(separator: ",")
                        var claimsDict = [String : String]()
                        for claim in claimsArray {
                            let idxEq = claim.firstIndex(of: "=")
                            var key = claim.prefix(upTo: idxEq!)
                            key.removeAll(where: {$0 == " "})
                            let value = claim.suffix(from: claim.index(after: idxEq!))
                            let valueWithoutEscapes = value.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
                            claimsDict[String(key)] = valueWithoutEscapes
                        }
                        if let errStr = claimsDict["error"] {
                            authInfo["error"] = errStr
                        }
                        if let errDescStr = claimsDict["error_description"] {
                            authInfo["error_description"] = errDescStr
                        }
                    }
                }
            }
            
            let string = String(data: data!, encoding: .utf8)
            callback(string!, httpResponse!.mimeType!, (httpResponse?.statusCode)!, authInfo)
        }
        task.resume()
    }
}
