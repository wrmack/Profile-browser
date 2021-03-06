//
//  ShowInfoAttributes.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 3/03/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import UIKit


/*
 Basic attributes, without paragraph style
 */
struct InfoAttributes {
    
    var heading1 = [
        NSAttributedString.Key.font : UIFont(name: "Arial-BoldMT", size: 22)!,
        NSAttributedString.Key.foregroundColor : UIColor(red: 0.12, green: 0.28, blue: 0.49, alpha: 1.0),
        ] as [NSAttributedString.Key : Any]
    
    var heading2 = [
        NSAttributedString.Key.font : UIFont(name: "Arial-BoldMT", size: 18)!,
        NSAttributedString.Key.foregroundColor : UIColor(red: 0.33, green: 0.55, blue: 0.8, alpha: 1.0),
        ] as [NSAttributedString.Key : Any]
    
    var heading3 = [
        NSAttributedString.Key.font : UIFont(name: "Arial-BoldMT", size: 16)!,
        NSAttributedString.Key.foregroundColor : UIColor.black,
        ] as [NSAttributedString.Key : Any]
    
    var normal = [
        NSAttributedString.Key.font : UIFont(name: "Arial", size: 14)!,
        NSAttributedString.Key.foregroundColor : UIColor.black,
        ] as [NSAttributedString.Key : Any]
    
    var normalBold = [
        NSAttributedString.Key.font : UIFont(name: "Arial-BoldMT", size: 14)!,
        NSAttributedString.Key.foregroundColor : UIColor.black,
        ] as [NSAttributedString.Key : Any]
    
    var normalItalic = [
        NSAttributedString.Key.font : UIFont(name: "Arial-ItalicMT", size: 14)!,
        NSAttributedString.Key.foregroundColor : UIColor.black,
        ] as [NSAttributedString.Key : Any]
}

/*
 Paragraph styles
 */
struct InfoParaStyle {
    var left: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.left
            style.tabStops = [NSTextTab(textAlignment: .right, location: 150, options: [:]), NSTextTab(textAlignment: .left, location: 200, options: [:])]
            style.defaultTabInterval = 40.0
            style.paragraphSpacing = 0
            style.paragraphSpacingBefore = 0
            return style
        }
    }
    var leftWithSpacingBeforeAfter: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.left
            style.tabStops = [NSTextTab(textAlignment: .right, location: 150, options: [:]), NSTextTab(textAlignment: .left, location: 200, options: [:])]
            style.defaultTabInterval = 28.0
            style.paragraphSpacing = 20
            style.paragraphSpacingBefore = 20
            return style
        }
    }
    
    var leftWithSpacingAfter: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.left
            style.tabStops = [NSTextTab(textAlignment: .right, location: 150, options: [:]), NSTextTab(textAlignment: .left, location: 200, options: [:])]
            style.defaultTabInterval = 28.0
            style.paragraphSpacing = 6
            style.paragraphSpacingBefore = 0
            return style
        }
    }
    
    var leftWithSpacingBefore: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.left
            style.tabStops = [NSTextTab(textAlignment: .right, location: 150, options: [:]), NSTextTab(textAlignment: .left, location: 200, options: [:])]
            style.defaultTabInterval = 28.0
            style.paragraphSpacing = 0
            style.paragraphSpacingBefore = 12
            return style
        }
    }
    
    var centered: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            style.tabStops = [NSTextTab]()
            style.defaultTabInterval = 28.0
            style.paragraphSpacing = 0
            style.paragraphSpacingBefore = 0
            return style
        }
    }
    
    var centeredWithSpacingBeforeAfter: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            style.tabStops = [NSTextTab]()
            style.defaultTabInterval = 28.0
            style.paragraphSpacing = 12
            style.paragraphSpacingBefore = 12
            return style
        }
    }
    
    var centeredWithSpacingBefore: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            style.tabStops = [NSTextTab]()
            style.defaultTabInterval = 28.0
            style.paragraphSpacing = 0
            style.paragraphSpacingBefore = 30
            return style
        }
    }
    
    var centeredWithSpacingAfter: NSMutableParagraphStyle {
        get {
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            style.tabStops = [NSTextTab]()
            style.defaultTabInterval = 12.0
            style.paragraphSpacing = 12
            style.paragraphSpacingBefore = 0
            return style
        }
    }
}
