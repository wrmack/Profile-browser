//
//  WMTextField.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 8/02/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import UIKit

/*
 A subclass of UITextField which provides UI tweaks
 */
class WMTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        borderStyle = .roundedRect
        font = UIFont.systemFont(ofSize: 14)
        backgroundColor = UIColor.white
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        returnKeyType = .go
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    
    
}

