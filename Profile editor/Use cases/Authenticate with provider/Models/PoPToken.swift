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
 
 
 
 
 Questions:
 Does Solid use symmetric or asymmetric keys?
 Who sends what to whom and when?
 How generate a public / private key in JWK format?
 
 
 
 The code for AuthenticationRequest.js shows private and public keys:
 https://github.com/solid/oidc-rp/blob/master/src/AuthenticationRequest.js
 
 This is the asymmetric keys model.
 
 This indicates the pop confirmation key is assigned to the 'request' parameter (line 148):
 https://github.com/solid/oidc-op/blob/master/src/handlers/AuthenticationRequest.js
 
 =====
 OAuth PoP key distribution docs give two versions (ver 03 cf 04 of doc) with one using a RSA public key and the other an ECC public key:
 https://tools.ietf.org/rfcdiff?url2=draft-ietf-oauth-pop-key-distribution-04.txt
 
 "As shown in Figure 6 the content of the 'key' parameter contains the         As shown in Figure 6 the content of the 'req_cnf' parameter contains
 RSA public key the client would like to associate with the access              the ECC public key the client would like to associate with the access
 token.                                                                                    token (in JSON format).
 
 POST /token HTTP/1.1                                                                    POST /token HTTP/1.1
 Host: server.example.com                                                              Host: server.example.com
 Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW                                Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
 Content-Type: application/x-www-form-urlencoded;charset=UTF-8                Content-Type: application/x-www-form-urlencoded;charset=UTF-8
 
 grant_type=authorization_code                                                       grant_type=authorization_code
 &code=SplxlOBeZQQYbYS6WxSbIA                                                        &code=SplxlOBeZQQYbYS6WxSbIA
 &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb                        &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb
 &token_type=pop                                                                        &token_type=pop
 &alg=RS256                                                                               &req_cnf=eyJhbGciOiJSU0ExXzUi ..
 &key=eyJhbGciOiJSU0ExXzUi ...
 
 (remainder of JWK omitted for brevity)                                            (remainder of JWK omitted for brevity)"
 =====
 
 
 =====
 An example of a successful response is shown in Figure 7.                        An example of a successful response is shown in Figure 7.
 
 HTTP/1.1 200 OK                                                                           HTTP/1.1 200 OK
 Content-Type: application/json;charset=UTF-8                                      Content-Type: application/json;charset=UTF-8
 Cache-Control: no-store                                                                Cache-Control: no-store
 Pragma: no-cache                                                                         Pragma: no-cache
 
 {                                                                                            {
 "access_token":"2YotnFZFE....jr1zCsicMWpAA",                                        "access_token":"2YotnFZFE....jr1zCsicMWpAA",
 "token_type":"pop",                                                                       "token_type":"pop",
 "alg":"RS256",
 "expires_in":3600,                                                                         "expires_in":3600,
 "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA"                                              "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA"
 }                                                                                             }
 
 The access code contains a JWT:
 
 {                                                                                            {
 "iss":"xas.example.com",                                                                "iss":"xas.example.com",
 "aud":"http://auth.example.com",                                                      "aud":"http://auth.example.com",
 "exp":"1361398824",                                                                         "exp":"1361398824",
 "nbf":"1360189224",                                                                         "nbf":"1360189224",
 "cnf":{                                                                                     "cnf":{
    "jwk":{"kty":"RSA",                                                                      "jwk" : {
            "n": "0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx                         "kty" : "EC",
             4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMs                "kid" : h'11',
             tn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2                   "crv" : "P-256",
             QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbI                  "x" : b64'usWxHK2PmfnHKwXPS54m0kTcGJ90UiglWiGahtagnv8',
             SD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqb                 "y" : b64'IBOL+C3BttVivg+lSreASjpkttcsz+1rb7btKLv8EX4'
            w0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw",                                                   }
           "e":"AQAB",
           "alg":"RS256",
          "kid":"id123"}
        }                                                                                             }
 }                                                                                             }
 
 
 
 
 =====
 
 
 
 In browser, select log in to inrupt using web inspector on the login popup.
 A GET request is sent to https://inrupt.net/login with query params
 scope: openid
 client_id
 response_type: id_token token
 request:  is JWT -
 https://jwt.io/#debugger-io?token=eyJhbGciOiJub25lIn0.eyJyZWRpcmVjdF91cmkiOiJodHRwczovL3dybWFjay5pbnJ1cHQubmV0Ly53ZWxsLWtub3duL3NvbGlkL2xvZ2luIiwiZGlzcGxheSI6InBhZ2UiLCJub25jZSI6Im1fTUhLZ1FtM0JwdXJhMDlHSU1zT3BsMHQ4OGNjTmc2VVM1dzYtcFdrMVUiLCJrZXkiOnsiYWxnIjoiUlMyNTYiLCJlIjoiQVFBQiIsImV4dCI6dHJ1ZSwia2V5X29wcyI6WyJ2ZXJpZnkiXSwia3R5IjoiUlNBIiwibiI6IjNUaHBkTXRuNmxOcmFfcEZDWTYyQ1dlRWxVUTFWRWdiQWJuY0hZc1c3MFhEZzZzT1hvd201M1dISmRfQUdTSW15b2pXTDFhU2JaTjBiUGNJUzhmbjg0cEFHNHV2VS1BRV9WUTk2SmhYSlJ3UmNLdjRsenBtYnJsNmpTX1RST1RCZWhWSGhkbXNaVGxsVV93U29CYmhkVVhyb1dmOUt3Unk2NFFCZk95Ry1zd3dVLVlQMGRJdmgyUXFzM2JLQ3YwdmlHNk02eG9BVjRxY3JROHVHNWh3Mk95MFZHM1B4VTljYlVxSFJvbk9WbnB2ZEh0elJaTEFxMnRXd0REMTdwQV9LbkVXa3Z4ZzRxcmN6SW5WM3ZRYXVJalEtcmpzMnJWRlJTel9sV19ieDk4QnNLOWJyckEtMWpqLThNdVRVRkdiTUhqelhrekRfVlZ2YkFKV1lEX0VfdyJ9fQ.%26state%3D9LJFstftfMc_m0YRx65SxdRB8fgGvc10hRsx2ZDVJYA
 state:
 
 Press log in button: [couldn't capture anything because popup gets dismissed]
 
 
 In browser attempt to access prefs.ttl file and view the requests / responses in web inspector.  The request sends a PoPToken:
 https://jwt.io/#debugger-io?token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJlMjkxZWY0NmE5YmU0ODJlMTgxZWVhYWNiZmViODNkNSIsImF1ZCI6Imh0dHBzOi8vd3JtYWNrLmlucnVwdC5uZXQiLCJleHAiOjE1NDg0OTQyMTMsImlhdCI6MTU0ODQ5MDYxMywiaWRfdG9rZW4iOiJleUpoYkdjaU9pSlNVekkxTmlJc0ltdHBaQ0k2SW5aYWFVTmtaR1ZJYkhRMEluMC5leUpwYzNNaU9pSm9kSFJ3Y3pvdkwybHVjblZ3ZEM1dVpYUWlMQ0p6ZFdJaU9pSm9kSFJ3Y3pvdkwzZHliV0ZqYXk1cGJuSjFjSFF1Ym1WMEwzQnliMlpwYkdVdlkyRnlaQ050WlNJc0ltRjFaQ0k2SW1VeU9URmxaalEyWVRsaVpUUTRNbVV4T0RGbFpXRmhZMkptWldJNE0yUTFJaXdpWlhod0lqb3hOVFE1TkRNMU5qWTRMQ0pwWVhRaU9qRTFORGd5TWpZd05qZ3NJbXAwYVNJNklqVTVOMll6T1dabE1qRXpabU5rWmpRaUxDSnViMjVqWlNJNklpMUtSMlUwTjFkdmJYRm5ZVGRTWDB0R1kxTnRPV1ZsUVRoT1drRlFabXRyUzBzd2FWcHJaM0JGTFc4aUxDSmhlbkFpT2lKbE1qa3haV1kwTm1FNVltVTBPREpsTVRneFpXVmhZV05pWm1WaU9ETmtOU0lzSW1OdVppSTZleUpxZDJzaU9uc2lZV3huSWpvaVVsTXlOVFlpTENKbElqb2lRVkZCUWlJc0ltVjRkQ0k2ZEhKMVpTd2lhMlY1WDI5d2N5STZXeUoyWlhKcFpua2lYU3dpYTNSNUlqb2lVbE5CSWl3aWJpSTZJakpWT1haNGJtOVhOVlkwUldseFZFZFdXR0ZoWjNoUVVGVnJZbWw1UTB0NFdrdFJMVkZ6TjBoRFdWOVZURUZyVVd0amNXSlpRM0V4ZWs1YWFraFBWa1pWY25CV1dpMXVWM0pQZWtjNU1qSjZVelkzU0hWUk5XeGxibXBGTmkwNFVsZERWbWRrVG1ScFJqaERaMmxUVmkwMFJIQkRhMkZRUzNZelIxaDRha0Z1VUhwa2RrdFhNbmc0UzJObVdWQmZZWE41Vkd0NmFIUlNPUzAzYVU0d1NGaFRhWGRJVkVKRWNUVlJjR2hxYmtOUFptaDJOMmh0V21WaVlVaFhXbFJGUkhkQlRXOXJVbnBDUkZkMk1EVXdSM0ZFYTBkc1IzQkllRk5wVVVaMGJUVkJUSE5TZFZoeVNFRklWbFJxTUdkelIyNUNObU5GWDFkbE1rVTVSWGx0YURSWmRGRlRMWEJvWkdKR2VuWXRaM0p1TTA5T2MzaGZZalpWYVhkclRFcGhiRTQyVURaZlYzQnhOakZEUjJkSFRFdElXWE56VkZWbVluTTNObkpFY25jMWMzUkhaVUk1TWpsaVVrc3diMHRKWjBoTVNFY3hkeUo5ZlN3aVlYUmZhR0Z6YUNJNklrOHdaVVU0T0hSMkxYRnVUbHB3U0drNVUwTkJOa0VpZlEuUjRieXZ5LVNTRTQtbGFwbERfS0hKUGJFR0FMaDZDUU96dmhoSm03a1lUeWlVRXE3VFAxaDR4c3I5MjBwaVpnUVhENHYwbU44NXNkMlNpTjBFZHotOGRMY2JfQlJjSUJfNk1pTDFLdDRPSmxVdFU4Y3gwN3VSa1JNdnBoZXhIRk04UlRodC1BN2dYSDlRdlZoejBSVWk3b1hIOE1QVnFUYjBOcHdyZnlWUURhV2MtcmtHQ1JwamJlRWVqcTdpMTVZRFFNV2dBdzV6Y0hmYlZoTWc0czhDZjZaVFhXVnQ0Zmx6ZUZCUVlyUTJjUHJFeUxnRzJtMHlyWlRuOVZibHprQXlhRXQxMXlSYzc3Q1Foanotc0FvSmRKZm9lQzMtMVVXdTVMYUFhTHZocUFNeDlsbG50bEdhOWRxb1g1VEE3OEJYY1dPMWZkSk9BTTBFZGVLYzRIV2VnIiwidG9rZW5fdHlwZSI6InBvcCJ9.C2_3Bt3rB_jp7HQPazRlLYIg_cfmBV0gJvzEvn-S0TKvWo-j5_rc2CUL0he64Dl7l_f9jD6__8--FTPibOmzTSnZyHqWw4hRoJCtbxlhnZ0Pug4FsYgad8nxbWuVVS5pd43H2AciYighbRNm3k6ajEQiTRAJmugunoS823Ze41zL-HfnRRvFPSi1Mo_3iuo6efJaA4Vi9F-MF1m52-Mo2_UcbrFo-LRowDdD_Lh2Ax65_RQ68ZR7yGTQodQn1p-dmazLsBH7OWcQmtTUS7Kki80HYUwghyvsKHQVa0Db1Kzt1p8Q0Pt3oJAxOrzAz9YYmE8xP1uOIO1LNQwFyRuUkA
 The PoP Token includes an id_token that has the JWK.
 
 The Solid-Auth-Client PoPToken class (POPToken.js) returns the following JWT with 3 parts:
 header:  alg
 payload:
     iss: client_id
     aud: resource server uri origin
     id_token: id_token
     token_type: 'pop'
     exp:
     iat:
 key: session key
 
 AuthenticationRequest.js:
 
 static generateSessionKeys () {
 return crypto.subtle.generateKey(
 {
     name: "RSASSA-PKCS1-v1_5",
     modulusLength: 2048,
     publicExponent: new Uint8Array([0x01, 0x00, 0x01]),
     hash: { name: "SHA-256" },
 },
     true,
     ["sign", "verify"]
 )
 .then((keyPair) => {
     // returns a keypair object
     return Promise.all([
     crypto.subtle.exportKey('jwk', keyPair.publicKey),
     crypto.subtle.exportKey('jwk', keyPair.privateKey)
     ])
     })
     .then(jwkPair => {
     let [ publicJwk, privateJwk ] = jwkPair
 
     return { public: publicJwk, private: privateJwk }
     })
 }
 
 RSASSA_PKCS1_v1_5.js
 
 generateKey (params, extractable, usages) {
 
     // 1. Verify usages
     usages.forEach(usage => {
         if (usage !== 'sign' && usage !== 'verify') {
         throw new SyntaxError('Key usages can only include "sign" and "verify"')
         }
     })
 
     let keypair = {}
 
     // 2. Generate RSA keypair
     try {
         let {modulusLength,publicExponent} = params
         // TODO
         // - fallback on node-rsa if OpenSSL is not available on the system
         let privateKey = spawnSync('openssl', ['genrsa', modulusLength || 4096]).stdout
         let publicKey = spawnSync('openssl', ['rsa', '-pubout'], { input: privateKey }).stdout
         try {
             keypair.privateKey = privateKey.toString('ascii')
             keypair.publicKey = publicKey.toString('ascii')
         } catch (error){
             throw new OperationError(error.message)
         }
     // 3. Throw operation error if anything fails
     } catch (error) {
         throw new OperationError(error.message)
     }
 
     // 4-9. Create and assign algorithm object
     let algorithm = new RSASSA_PKCS1_v1_5(params)
 
     // 10-13. Instantiate publicKey
     let publicKey = new CryptoKey({
         type: 'public',
         algorithm,
         extractable: true,
         usages: ['verify'],
         handle: keypair.publicKey
     })
 
     // 14-18. Instantiate privateKey
     let privateKey = new CryptoKey({
         type: 'private',
         algorithm,
         extractable: extractable,
         usages: ['sign'],
         handle: keypair.privateKey
     })
 
     // 19-22. Create and return a new keypair
     return new CryptoKeyPair({publicKey,privateKey})
 }
 
 
 
*/


import Foundation


class PoPToken: Codable {
    
    
    
}
