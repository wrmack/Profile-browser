//
//  ShowProfileInteractor.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 8/02/19.
//  Copyright (c) 2019 Warwick McNaughton. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import JavaScriptCore



protocol ShowProfileBusinessLogic {
    func fetchProfile(request: ShowProfile.Profile.Request, callback: @escaping (String?)->())
    func getStoreTriples()-> [Triple]?
    func addSelectedItemToDataStore(item: (String, String, Int))
    func saveWebIDToRecents(webID: String)
    func getWebid()->String 
}

protocol ShowProfileDataStore {
    var storeTriples: [Triple]? {get set}
    var selectedItem: Triple? {get set}
    var context: JSContext? {get set}
    var webid: String? {get set}
}



class ShowProfileInteractor: NSObject, ShowProfileBusinessLogic, ShowProfileDataStore, URLSessionDelegate {
    var presenter: ShowProfilePresentationLogic?
    var context: JSContext?
    var storeTriples: [Triple]?
    var selectedItem: Triple?
    var webid: String?
    

    // MARK: - VIP
    
    func fetchProfile(request: ShowProfile.Profile.Request, callback: @escaping (String?)->()) {
        webid = request.webid
        if context == nil { setupContext(); setupRdfLib()}
        let url = URL(string: request.webid! )
        fetch(url: url!, callback: { response, httpURLResponse, error  in
            guard error == nil else {
                DispatchQueue.main.async {
                    callback(error!.localizedDescription)
                }
                return
            }
            
            let mimeType = httpURLResponse!.mimeType
            let statusCode = httpURLResponse!.statusCode
            
            print("Mime-type: \(mimeType!)")
            print("Status code: \(statusCode)")
            print("Data: \n\(response!)")

            guard statusCode == 200 else {
                DispatchQueue.main.async {
                    callback("Status code \(statusCode)")
                }
                return
            }
            guard mimeType == "text/turtle" || mimeType == "text/n3" else {
                DispatchQueue.main.async {
                    callback("Content mimetype is not text/turtle")
                }
                return
            }
            self.context?.evaluateScript("var store = RDF.graph();")
            self.context?.evaluateScript("RDF.parse(`" + response! + "`, store, '" + request.webid! + "', 'text/turtle');")
            let statementsArray = self.context!.objectForKeyedSubscript("store")!.toDictionary()!["statements"] as! [Any]
            if statementsArray.count == 0 {
                DispatchQueue.main.async {
                    callback("Could not be parsed")
                }
                return
            }
//            print("Store statements: \(statementsArray)")
            var triples = [Triple]()
            var count = 0
            for item in statementsArray {
                if let tripleDictionary = item as? [String : Any] {
                    let subject = (tripleDictionary["subject"] as! [String : Any])["value"] as! String
                    let subjectType = (tripleDictionary["subject"] as! [String : Any])["termType"] as! String
                    let predicate = (tripleDictionary["predicate"] as! [String : Any])["value"] as! String
                    let predicateType = (tripleDictionary["predicate"] as! [String : Any])["termType"] as! String
                    let objectType = (tripleDictionary["object"] as! [String : Any])["termType"] as! String
                    var objectLang = (tripleDictionary["object"] as! [String : Any])["lang"] as? String
                    if (objectLang != nil) && (objectLang!.count == 0) {objectLang = nil}
                    var object: String?
                    switch objectType {
                    case "NamedNode":
                        object = (tripleDictionary["object"] as! [String : Any])["value"] as? String
                    case "Literal":
                        object = (tripleDictionary["object"] as! [String : Any])["value"] as? String
                    case "Collection":
                        object = "Collection placeholder"
                    case "BlankNode":
                        object = (tripleDictionary["object"] as! [String : Any])["value"] as? String
                    default:
                        object = "Missing object"
                    }
                    
                    let triple = Triple(index: count, subject: (subject, subjectType), predicate:( predicate, predicateType), object: (object!, objectType, objectLang))
                    triples.append(triple)
                    count += 1
                }
            }
            print("Triples derived from parsing store statements: ")
            for triple in triples {
                print(triple)
            }
            // Uncomment below to print the store rdf data as triples
            //            self.context?.evaluateScript("var triples = store.toNT();")
            //            let storeTriples = self.context?.objectForKeyedSubscript("triples")
            //            print("Store triples: \n\(storeTriples!)")
            DispatchQueue.main.async {
                self.storeTriples = triples
                let response = ShowProfile.Profile.Response(triples: triples)
                self.presenter?.presentTriplesBySubject(response: response) 
            }
        })
    }
    
    
    // MARK: - Datastore
    
    func getStoreTriples()-> [Triple]? {
        return storeTriples
    }
    
    func getWebid()->String {
        return webid!
    }
    
    func addSelectedItemToDataStore(item: (String, String, Int)) {
        let (_, _, idx) = item
        for triple in storeTriples! {
            if triple.index == idx {
                selectedItem = triple
                break
            }
        }
    }
    
    
    // MARK: - Helpers
    
    /*
     Setup the javascript context
     */
    func setupContext() {
        
        context = JSContext()
        
        // Catch JavaScript exceptions
        context!.exceptionHandler = { context, error in
            print("JS Error: \(error!)")
        }
        
        let nativePrint: @convention(block) (String) -> Void = { message in
            print("JS print: \(message)")
        }
        context!.setObject(nativePrint, forKeyedSubscript: "nativePrint" as NSString)
    }
    
    
    /*
     Write the bundled javascript RDF library into the javascript context.
     Note: the bundle was created with browserify standalone option set to "RDF".
     All exports in index.js are available to Swift through RDF.
     Setup the store in javascript.
     */
    func setupRdfLib() {
        
        guard let rdfPath = Bundle.main.path(forResource: "rdfbundle", ofType: "js")
            else { print("Unable to read resource files."); return }
        
        do {
            let jsCode = try String(contentsOfFile: rdfPath, encoding: String.Encoding.utf8)
            _ = context?.evaluateScript(jsCode)
        }
        catch {
            print("Evaluate script failed")
        }
    }
    
    /*
     Url fetcher with callback
     */
    func fetch(url: URL, callback: @escaping (String?, HTTPURLResponse?, Error?) -> Void) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                callback(nil, nil, error)
            }
            else {
                print("\nResponse:\n\(response! as Any)")
                let httpResponse = response as? HTTPURLResponse
                print("\nAll headers:\n\(httpResponse!.allHeaderFields as! [String : Any])")
                
                let dataString = String(data: data!, encoding: .utf8)
                callback(dataString!, httpResponse!, nil)
            }
        }
        task.resume()
    }
    
    func saveWebIDToRecents(webID: String) {
        var recentsArray = [String]()
        let defaults = UserDefaults.standard
        if let recentsData = defaults.data(forKey: "Recents") {
            recentsArray = try! JSONDecoder().decode([String].self, from: recentsData)
            guard webID != recentsArray.first else {return}
            if recentsArray.count > 15 {
                recentsArray.removeLast(1)
            }
        }
        recentsArray.insert(webID, at: 0)
        let encodedRecentsArray = try? JSONEncoder().encode(recentsArray)
        defaults.set(encodedRecentsArray, forKey: "Recents")
    }
    
    
    // MARK: - URLSessionDelegate methods
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!)
        )
    }
    
}
