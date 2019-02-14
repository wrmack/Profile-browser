//
//  IDToken.swift
//  POD browser
//
//  Created by Warwick McNaughton on 20/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import Foundation






class IDToken: NSObject {
    
    /*! Field keys associated with an ID Token. */
    private let kIssKey = "iss"
    private let kSubKey = "sub"
    private let kAudKey = "aud"
    private let kExpKey = "exp"
    private let kIatKey = "iat"
    private let kNonceKey = "nonce"
    
    /*! @brief The header JWT values.
     */
    private(set) var header: [AnyHashable : Any]?
    /*! @brief All ID Token claims.
     */
    private(set) var claims: [String : NSObject]?
    /*! @brief Issuer Identifier for the Issuer of the response.
     @remarks iss
     @see http://openid.net/specs/openid-connect-core-1_0.html#IDToken
     */
    private(set) var issuer: URL?
    /*! @brief Subject Identifier.
     @remarks sub
     @see http://openid.net/specs/openid-connect-core-1_0.html#IDToken
     */
    private(set) var subject: String?
    /*! @brief Audience(s) that this ID Token is intended for.
     @remarks aud
     @see http://openid.net/specs/openid-connect-core-1_0.html#IDToken
     */
    private(set) var audience: [String]? = []
    /*! @brief Expiration time on or after which the ID Token MUST NOT be accepted for processing.
     @remarks exp
     @see http://openid.net/specs/openid-connect-core-1_0.html#IDToken
     */
    private(set) var expiresAt: Date?
    /*! @brief Time at which the JWT was issued.
     @remarks iat
     @see http://openid.net/specs/openid-connect-core-1_0.html#IDToken
     */
    private(set) var issuedAt: Date?
    /*! @brief String value used to associate a Client session with an ID Token, and to mitigate replay
     attacks.
     @remarks nonce
     @see http://openid.net/specs/openid-connect-core-1_0.html#IDToken
     */
    private(set) var nonce: String?
    
    
    init?(idTokenString idToken: String?) {
        super.init()
        let sections = idToken?.components(separatedBy: ".")
        // The header and claims sections are required.
        if (sections?.count ?? 0) <= 1 {
            return nil
        }
        header = TokenUtilities.parseJWTSection(sections?[0])
        claims = TokenUtilities.parseJWTSection(sections?[1])
        if header == nil || claims == nil {
            return nil
        }
        
        
        for parameter in claims! {
            switch parameter.key {
            case kIssKey:
                issuer = URL(string: claims![kIssKey] as! String)
            case kSubKey:
                subject = claims![kSubKey] as? String
            case kAudKey:
                if claims![kAudKey] is [String] {
                    audience = claims![kAudKey] as? [String]
                }
                else { audience!.append(claims![kAudKey] as! String) }
            case kExpKey:
                let rawDate = claims![kExpKey]
                expiresAt = Date(timeIntervalSince1970: TimeInterval(Int64(truncating: rawDate as! NSNumber )))
            case kIatKey:
                let rawDate = claims![kIatKey]
                issuedAt = Date(timeIntervalSince1970: TimeInterval(Int64(truncating: rawDate as! NSNumber )))
            case kNonceKey:
                nonce = claims![kNonceKey] as? String
            default:
               break
            }

        }

        // Required fields.
        if issuer == nil || audience == nil || subject == nil || expiresAt == nil || issuedAt == nil {
            return nil
        }
    }
    
    
 
}
