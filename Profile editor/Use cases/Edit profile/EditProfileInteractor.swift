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
    func saveTriple(request: EditProfile.EditTriple.Request, callback: @escaping (String?)->())
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
     Create a SPAQL request to replace existing resource with changed resource
     */
    func saveTriple(request: EditProfile.EditTriple.Request, callback: @escaping (String?)->()) {
        let originalTripleSub = (selectedItem!.subject.1 == "Literal") ? "\"\(selectedItem!.subject.0)\"" : "<\(selectedItem!.subject.0)>"
        let originalTriplePred = (selectedItem!.predicate.1 == "Literal") ? "\"\(selectedItem!.predicate.0)\"" : "<\(selectedItem!.predicate.0)>"
        let originalTripleObj = (selectedItem!.object.1 == "Literal") ? "\"\(selectedItem!.object.0)\"" : "<\(selectedItem!.object.0)>"
        let originalTriple = "\(originalTripleSub) \(originalTriplePred) \(originalTripleObj) ."
        
        let replacementTripleSub = (request.triple!.subject.1 == "Literal") ? "\"\(request.triple!.subject.0)\"" : "<\(request.triple!.subject.0)>"
        let replacementTriplePred = (request.triple!.predicate.1 == "Literal") ? "\"\(request.triple!.predicate.0)\"" : "<\(request.triple!.predicate.0)>"
        let replacementTripleObj = (request.triple!.object.1 == "Literal") ? "\"\(request.triple!.object.0)\"" : "<\(request.triple!.object.0)>"
        let replacementTriple = "\(replacementTripleSub) \(replacementTriplePred) \(replacementTripleObj) ."
        
        var urlRequest = URLRequest(url: URL(string: webid!)! )
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("appliction/sparql-update", forHTTPHeaderField: "Content-Type")
        let bodyString = "DELETE DATA { \(originalTriple)}; INSERT DATA {\(replacementTriple)}"
        let body = bodyString.data(using: .utf8)
        urlRequest.httpBody = body
        print("urlRequest: \(urlRequest.allHTTPHeaderFields!)")
        
        fetch(urlRequest: urlRequest, callback: { dataString, mimeType, statusCode in
            
            print(dataString)
            print(mimeType)
            
            if statusCode == 401 {
                DispatchQueue.main.async {
                    callback("unauthorized")
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
    
    
    // MARK: - Helpers
    /*
     Url fetcher with callback
     */
    func fetch(urlRequest: URLRequest, callback: @escaping (String, String, Int) -> Void) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            print("\nResponse:\n\(response! as Any)")
            let httpResponse = response as? HTTPURLResponse
            print("\nAll headers:\n\(httpResponse!.allHeaderFields as! [String : Any])")
            
            let string = String(data: data!, encoding: .utf8)
            callback(string!, httpResponse!.mimeType!, (httpResponse?.statusCode)!)
        }
        task.resume()
    }
}
