//
//  ShowInfoInteractor.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 3/03/19.
//  Copyright (c) 2019 Warwick McNaughton. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ShowInfoBusinessLogic {
    func fetchAttributedString(request: ShowInfo.Info.Request) 
}

protocol ShowInfoDataStore {
  //var name: String { get set }
}

class ShowInfoInteractor: ShowInfoBusinessLogic, ShowInfoDataStore {
    var presenter: ShowInfoPresentationLogic?

    // MARK: - VIP

    func fetchAttributedString(request: ShowInfo.Info.Request) {
        let response = ShowInfo.Info.Response()
        presenter?.presentAttributedString(response: response) 
    }
}