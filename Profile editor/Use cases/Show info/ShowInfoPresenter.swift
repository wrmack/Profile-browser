//
//  ShowInfoPresenter.swift
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

protocol ShowInfoPresentationLogic {
    func presentAttributedString(response: ShowInfo.Info.Response)
}

class ShowInfoPresenter: ShowInfoPresentationLogic {
    weak var viewController: ShowInfoDisplayLogic?

    // MARK: - VIP
    
    func presentAttributedString(response: ShowInfo.Info.Response) {
        
        let attString = NSMutableAttributedString()
        
        var heading1Atts = InfoAttributes().heading1
        heading1Atts[NSAttributedString.Key.paragraphStyle] = InfoParaStyle().leftWithSpacingBefore
        
        var heading2Atts = InfoAttributes().heading2
        heading2Atts[NSAttributedString.Key.paragraphStyle] = InfoParaStyle().leftWithSpacingBefore
        
        var normAtts = InfoAttributes().normal
        normAtts[NSAttributedString.Key.paragraphStyle] = InfoParaStyle().leftWithSpacingBefore
        
        var boldnormAtts = InfoAttributes().normalBold
        boldnormAtts[NSAttributedString.Key.paragraphStyle] = InfoParaStyle().leftWithSpacingBefore
        
        
        
        attString.append(NSAttributedString(string: "Quick info\n", attributes: heading1Atts))
        attString.append(NSAttributedString(string: "Enter a webid\n", attributes: heading2Atts))
 //       attString.append(NSAttributedString(string: "Remaining list:\n", attributes: boldnormAtts))
        attString.append(NSAttributedString(string: "A webid is like:\n    https://username.inrupt.net/profile/card#me\nThis app only handles https:// (not http://).\nA webid ends with a fragment (marked by #) like #me or #i.\n", attributes: normAtts))
        attString.append(NSAttributedString(string: "Features\n", attributes: heading2Atts))
        attString.append(NSAttributedString(string: "Maintains a recents list to save having to re-enter webids.\nPress a table row to see data in triple form.\nApp will assess whether object can be acessed and provide a link to load the object.  This is experimental and may or may not be successful.\n", attributes: normAtts))
        attString.append(NSAttributedString(string: "Limitations\n", attributes: heading2Atts))
        attString.append(NSAttributedString(string: "When the row detail is presented, it is possible to edit the object.  When Save is pressed the app will attempt to authenticate the user using tokens.  Solid server needs to be patched to accept tokens from native apps. It is possible to save an edit using a patched version.\n", attributes: normAtts))
        
        let viewModel = ShowInfo.Info.ViewModel(attString: attString)
        viewController?.displayAttributedString(viewModel: viewModel) 
    }
}
