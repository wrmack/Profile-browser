//
//  EditProfileRouter.swift
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

@objc protocol EditProfileRoutingLogic {
    func navigateToAuthentication()
}

protocol EditProfileDataPassing {
    var dataStore: EditProfileDataStore? { get }
}

class EditProfileRouter: NSObject, EditProfileRoutingLogic, EditProfileDataPassing {
    weak var viewController: EditProfileViewController?
    var dataStore: EditProfileDataStore?
  
  // MARK: Routing
    // TODO: pass webid using data passing rather than injection
    func navigateToAuthentication() {
        let authenticationVC = AuthenticateWithProviderViewController(webId: (dataStore?.webid)!)
        viewController!.show(authenticationVC, sender: nil)
    }
  //func routeToSomewhere(segue: UIStoryboardSegue?)
  //{
  //  if let segue = segue {
  //    let destinationVC = segue.destination as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //  } else {
  //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //    navigateToSomewhere(source: viewController!, destination: destinationVC)
  //  }
  //}

  // MARK: Navigation
  
  //func navigateToSomewhere(source: EditProfileViewController, destination: SomewhereViewController)
  //{
  //  source.show(destination, sender: nil)
  //}
  
  // MARK: Passing data
  
  //func passDataToSomewhere(source: EditProfileDataStore, destination: inout SomewhereDataStore)
  //{
  //  destination.name = source.name
  //}
}
