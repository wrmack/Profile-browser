//
//  ShowProfileHeaderView.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 8/02/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import UIKit

class  ShowProfileHeaderView: UIView {
    
    // MARK: - Properties
    var webIDTextField: WMTextField?
    var webIDRecents: UIButton?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Views
    
    private func setupViews() {
        
        webIDTextField = WMTextField(frame: CGRect.zero)
        webIDTextField!.placeholder = "eg https://username.inrupt.net/profile/card#me"
        webIDTextField!.isEnabled = true
        addSubview(webIDTextField!)
        webIDTextField?.translatesAutoresizingMaskIntoConstraints = false
        webIDTextField?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        webIDTextField?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        webIDTextField?.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        webIDTextField?.bottomAnchor.constraint(equalTo: bottomAnchor, constant:-7).isActive = true
        
        webIDRecents = UIButton()
        webIDRecents?.setTitle("≣", for: .normal)
        webIDRecents?.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1.0), for: .normal)
        webIDRecents?.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        webIDRecents?.addTarget(nil, action: #selector(ShowProfileViewController.displayRecentsInPopup) , for: .touchUpInside)
        addSubview(webIDRecents!)
        webIDRecents?.translatesAutoresizingMaskIntoConstraints = false
        webIDRecents?.leadingAnchor.constraint(equalTo: webIDTextField!.trailingAnchor, constant: 10).isActive = true
        webIDRecents?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        webIDRecents?.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        webIDRecents?.bottomAnchor.constraint(equalTo: bottomAnchor, constant:-7).isActive = true
    }
    

}

