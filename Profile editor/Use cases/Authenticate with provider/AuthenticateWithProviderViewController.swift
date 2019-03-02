//
//  AuthenticateWithProviderViewController.swift
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

struct Provider: Codable {
    var name: String?
}

protocol AuthenticateWithProviderDisplayLogic: class {
    func displayMessage(viewModel: AuthenticateWithProvider.DisplayMessages.ViewModel)
}



class AuthenticateWithProviderViewController: UIViewController, AuthenticateWithProviderDisplayLogic, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Properties
    var interactor: AuthenticateWithProviderBusinessLogic?
    var router: (NSObjectProtocol & AuthenticateWithProviderRoutingLogic & AuthenticateWithProviderDataPassing)?
    var logText = NSMutableAttributedString()
    var messageTextView: UITextView?
    var webId: String?
 
    
    // MARK: - Object lifecycle
    
    convenience init(webId: String) {
        self.init()
        self.webId = webId
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        let viewController = self
        let interactor = AuthenticateWithProviderInteractor()
        let presenter = AuthenticateWithProviderPresenter()
        let router = AuthenticateWithProviderRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: - Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        messageTextView = UITextView(frame: CGRect.zero, textContainer: nil)
        view.addSubview(messageTextView!)
        messageTextView!.layoutManager.allowsNonContiguousLayout = false
        messageTextView?.translatesAutoresizingMaskIntoConstraints = false
        messageTextView?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        messageTextView?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        messageTextView?.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        messageTextView?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-20).isActive = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleMessageNotifications(notification: )), name: Notification.Name(rawValue: "MessageNotification"), object: nil)
        
        let components = URLComponents(string: webId!)
        let issuerString = components!.port != nil ? "\(components!.scheme!)://\(components!.host!):\(components!.port!)" : "\(components!.scheme!)://\(components!.host!)"
        fetchConfiguration(issuer: issuerString)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    // MARK: - VIP

    /*
     Provider discovery
     Called when user enters provider's url ('issuer')in textfield.
     */
    func fetchConfiguration(issuer: String) {
        let request = AuthenticateWithProvider.FetchConfiguration.Request(issuer: issuer, webid: webId)
        interactor?.fetchProviderConfiguration(request: request, callback: { configuration, errorString in 
            if errorString == nil {
                print(configuration!.description())
                self.registerClient(configuration: configuration!)
            }
            else {
                print(errorString!)
                self.displayAlertWithMessage(title: "Error", message: errorString!)
            }
        })
    }
    
    // Dynamic registration
    func registerClient(configuration: ProviderConfiguration) {
        let request = AuthenticateWithProvider.RegisterClient.Request(configuration: configuration) 
        interactor?.registerClient(request: request, callback: { configuration, response, errorString in
            if errorString == nil {
                print(response!.description())
                self.authenticateWithProvider(configuration: configuration!, clientID: (response?.clientID)!, clientSecret: response?.clientSecret)
            }
            else {
                print(errorString!)
                self.displayAlertWithMessage(title: "Error", message: errorString!)
            }
        })
    }
    
    // Authentication to provider
    func authenticateWithProvider(configuration: ProviderConfiguration, clientID: String, clientSecret: String?) {
        let request = AuthenticateWithProvider.Authenticate.Request(configuration: configuration, clientID: clientID, clientSecret: clientSecret)
        interactor?.authenticateWithProvider(request: request, viewController: self, callback: {errorString in
            if errorString != nil {
                self.displayAlertWithMessage(title: "Error", message: errorString!)
            }
            else {
                self.router!.returnFromAuthenticationController()
            }
        })
    }

    
    func logout() {
        interactor!.logout() 
    }
    
    
    // Access user info
    func fetchUserInfo() {
        let request = AuthenticateWithProvider.UserInfo.Request()
        interactor!.fetchUserInfo(request: request)
    }

    
    // Handle messages - send for processing
    func processMessage(message: [String : Any]?) {
        let request = AuthenticateWithProvider.DisplayMessages.Request(message: message)
        interactor!.processMessage(request: request)
    }
    
    
    // Display processed messages on UITextView
    func displayMessage(viewModel: AuthenticateWithProvider.DisplayMessages.ViewModel) {
        if viewModel.status != nil {
           logText.append(viewModel.status!)
        }
        if viewModel.message != nil {
            logText.append(viewModel.message!)
        }
        DispatchQueue.main.async {
            self.messageTextView!.attributedText = self.logText
            let bottom = NSMakeRange(self.messageTextView!.attributedText.length - 1, 1)
            self.messageTextView!.scrollRangeToVisible(bottom)
        }
    }
    
    
    // MARK: - UITextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != nil {
            let provider = Provider(name: textField.text!)
            let encodedProvider = try? JSONEncoder().encode(provider)
            UserDefaults.standard.set(encodedProvider, forKey: "Provider")
        }
        fetchConfiguration(issuer: textField.text!)
        return true
    }
    
    // MARK: - UITextView delegate methods
    
    // MARK: - Alerts
    
    func displayAlertWithMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
            self.router!.returnFromAuthenticationController()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Notifications
    
    @objc func handleMessageNotifications(notification: Notification) {
        let userInfo = notification.userInfo
        processMessage(message: userInfo as? [String : Any])
    }
}
