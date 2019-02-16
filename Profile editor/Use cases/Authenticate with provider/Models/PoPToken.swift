//
//  PoPToken.swift
//  POD browser
//
//  Created by Warwick McNaughton on 26/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

/*
 
 https://github.com/solid/oidc-rp/blob/master/src/PoPToken.js
 https://tools.ietf.org/html/draft-ietf-oauth-pop-architecture-08
 https://tools.ietf.org/html/draft-ietf-oauth-pop-key-distribution-04
 https://tools.ietf.org/html/rfc7800
 https://github.com/solid/solid-auth-client
 http://www.thread-safe.com/2015/01/proof-of-possession-putting-pieces.html
 https://umu.diva-portal.org/smash/get/diva2:1243880/FULLTEXT01.pdf
 https://www.iana.org/assignments/jwt/jwt.xhtml#confirmation-methods (all the acronyms)
*/
 
import Foundation

// TODO: check types.  eg is idToken a String
struct PopTokenParams: Codable {
    var issuer: String
    var audience: String
    var issuedAtTime: Int
    var expiryTime: Int
    var idToken: String
    var tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case issuer
        case audience
        case issuedAtTime
        case expiryTime
        case idToken
        case tokenType
    }
    
}


class POPToken: NSObject {
    //var webId: String
    var token: String?
    
    convenience init?(webId: String, authState: AuthState) {
        self.init()
        
        // Create header json and b64 encode it
        var headerSection = [String : String]()
        headerSection["alg"] = "RS256"
        let jsonHeader = try? JSONEncoder().encode(headerSection)
        let b64Header = TokenUtilities.encodeBase64urlNoPadding(jsonHeader)
        
        // Set up payload parameters
        let issuer = authState.lastAuthorizationResponse?.request?.clientID
        let components = URLComponents(string: webId)
        let audience = "\(components!.scheme!)://\(components!.host!):\(components!.port!)"
        let issuedAtTime = Date().timeIntervalSince1970
        let expiryTime = Date(timeIntervalSinceNow: 3600).timeIntervalSince1970
        let idToken = authState.lastTokenResponse?.idToken
        let tokenType = "pop"
        let tokenParams = PopTokenParams(issuer: issuer!, audience: audience, issuedAtTime: Int(issuedAtTime), expiryTime: Int(expiryTime), idToken: idToken!, tokenType: tokenType)
    

        // Create payload json and b64 encode it
        let jsonPayload = try? JSONEncoder().encode(tokenParams)
        
        print("json data: \(jsonPayload!)")
        print("json string: \(String(data: jsonPayload!, encoding: String.Encoding.utf8)!)")
        let jsonDecoded = try? JSONDecoder().decode(PopTokenParams.self, from: jsonPayload! )
        print("jsonDecoded: \(jsonDecoded!)")
        
        let b64Payload = TokenUtilities.encodeBase64urlNoPadding(jsonPayload!)
        
        // Convert header and payload to ascii-encoded data
        let combined = "\(b64Header!).\(b64Payload!)"
        let signingInput = combined.data(using: .ascii)
        
        // Get private key from keychain
        var privateKey: SecKey?
        let tag = "com.wm.POD-browser".data(using: .utf8)!
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
            privateKey = (item as! SecKey)
        }
        else {
            print("Handle error")  // TODO:
            return nil
        }
        
        // Sign
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        guard SecKeyIsAlgorithmSupported(privateKey!, .sign, algorithm) else {
            print("Handle error")  // TODO:
            return nil
        }
        var signature: Data?
        var error: Unmanaged<CFError>?
        signature = SecKeyCreateSignature(privateKey!, algorithm, signingInput! as CFData, &error) as Data?
        if error != nil {
            let error = error!.takeRetainedValue() as Error
            print(error)  // TODO:
        }
        
        // Create JWS
        self.token = "\(combined).\(TokenUtilities.encodeBase64urlNoPadding(signature!)!)"
    }
    
    override init() {
        
    }
}
