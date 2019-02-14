//
//  ScopeUtilities.swift
//  POD browser
//
//  Created by Warwick McNaughton on 26/01/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import Foundation


let kScopeOpenID = "openid"
let kScopeProfile = "profile"
let kScopeWebID = "webid"
let kScopeEmail = "email"
let kScopeAddress = "address"
let kScopePhone = "phone"



class ScopeUtilities: NSObject {
    
    static let disallowedScopeCharacters: CharacterSet? = {
        var disallowedCharacters = CharacterSet()
        var allowedCharacters = CharacterSet()
        //        var allowedCharacters = NSMutableCharacterSet(range: NSMakeRange(0x23, 0x5B - 0x23 + 1))
        //        allowedCharacters.addCharacters(in: NSMakeRange(0x5D, 0x7E - 0x5D + 1))
        //        allowedCharacters.addCharacters(in: "0x21")
        allowedCharacters.insert(charactersIn: "\u{0023}"..."\u{005B}")
        allowedCharacters.insert(charactersIn: "\u{005D}"..."\u{007E}")
        allowedCharacters.insert("\u{0021}")
        disallowedCharacters = allowedCharacters.inverted
        return disallowedCharacters
    }()
    
    
    
    class func scopes(withArray scopes: [String]?) -> String? {
        let disallowedCharacters = ScopeUtilities.disallowedScopeCharacters
        for scope in scopes! {
            assert((scope.count) != 0, "Found illegal empty scope string.")
            if let aCharacters = disallowedCharacters {
                assert(Int((scope as NSString?)?.rangeOfCharacter(from: aCharacters).location ?? 0) == NSNotFound, "Found illegal character in scope string.")
            }
        }
        let scopeString = scopes?.joined(separator: " ")
        return scopeString
    }
    
    
    class func scopesArray(with scopes: String?) -> [String]? {
        return scopes?.components(separatedBy: " ")
    }
}

