//
//  AuthenticateWithProviderPresenter.swift
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

protocol AuthenticateWithProviderPresentationLogic {
    func processMessage(response: AuthenticateWithProvider.DisplayMessages.Response)
}

class AuthenticateWithProviderPresenter: AuthenticateWithProviderPresentationLogic {
    weak var viewController: AuthenticateWithProviderDisplayLogic?

    // MARK: - VIP

    func processMessage(response: AuthenticateWithProvider.DisplayMessages.Response) {
        
        var messageString: String?
        if let message = response.message!["message"] {
            messageString = String()
            if message is Data {
                let json = try? JSONSerialization.jsonObject(with: message as! Data, options: []) as! [String : Any]
                for key in json!.keys {
                    messageString!.append(key + ": ")
                    let value = json![key]
                    if value is String {
                        var valueString = value as! String
                        if key == "client_secret" || key == "registration_access_token"  {
                            let redactedString = valueString.prefix(15) + "...[redacted]"
                            valueString = String(redactedString)
                        }
                        messageString!.append("\n   " + valueString)
                    }
                    if value is Date {
                        let valueString = (value as! Date).description
                        messageString!.append("\n   " + valueString)
                    }
                    if value is URL {
                        let valueString = (value as! URL).absoluteString
                        messageString!.append("\n   " + valueString)
                    }
                    if value is Bool {
                        let valueString = (value as! Bool).description
                        messageString!.append("\n   " + valueString)
                    }
                    if value is [String] {
                        var valueString = String()
                        for str in value as! [String] {
                            valueString.append("\n   " + str)
                        }
                        messageString!.append(valueString)
                    }
                    messageString!.append("\n")
                }
            }
            else {
                messageString = message as? String
                if let status = response.message!["status"] as? String {
                    if status.contains("token") {
                        let redactedString = messageString!.prefix(15) + "...[redacted]\n"
                        messageString = String(redactedString)
                    }
  
                }
            }
        }
        
        var normAtts = PresentationAttributes().normal
        normAtts[NSAttributedString.Key.paragraphStyle] = PresentationParaStyle().left
        var normBoldAtts = PresentationAttributes().normalBold
        normBoldAtts[NSAttributedString.Key.paragraphStyle] = PresentationParaStyle().left
        
        var statusAttString: NSMutableAttributedString?
        if let statusString = response.message!["status"] {
            statusAttString = NSMutableAttributedString()
            statusAttString!.append(NSMutableAttributedString(string: statusString as! String, attributes: normBoldAtts))
        }
        
        var messageAttString: NSMutableAttributedString?
        if messageString != nil {
            messageAttString = NSMutableAttributedString()
            messageAttString!.append(NSAttributedString(string: messageString!, attributes: normAtts))
        }
        
        let viewModel = AuthenticateWithProvider.DisplayMessages.ViewModel(status: statusAttString, message: messageAttString)
        viewController?.displayMessage(viewModel: viewModel) 
    }
}
