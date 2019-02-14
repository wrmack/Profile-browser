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
//        webIDTextView?.contentSize = CGSize(width: 600, height: 14)
//        webIDTextView?.contentOffset = CGPoint(x: 0, y: 0)
//        webIDTextView?.isScrollEnabled = true
//        webIDTextView?.bounces = true
//        webIDTextView?.alwaysBounceHorizontal = true
//        webIDTextView?.clipsToBounds = false
//        webIDTextView?.showsVerticalScrollIndicator = false
//        webIDTextView?.showsHorizontalScrollIndicator = false
//        webIDTextView?.maximumZoomScale = 1
//        webIDTextView?.maximumZoomScale = 0.5
        addSubview(webIDTextField!)
        
        webIDTextField?.translatesAutoresizingMaskIntoConstraints = false
        webIDTextField?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        webIDTextField?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        webIDTextField?.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        webIDTextField?.bottomAnchor.constraint(equalTo: bottomAnchor, constant:-7).isActive = true
    }
    

}

