//
//  ShowProfileSectionHeaderView.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 8/02/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import UIKit


class ShowProfileSectionHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    var sectionLabel: UILabel?
    var sectionCollapseButton: UIButton?
    var sectionIndex: Int?
    var isUnfolded = true
    
    // MARK: - Lifecycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        contentView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        contentView.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        contentView.layer.borderWidth = 1
        sectionLabel = UILabel()
        sectionLabel?.numberOfLines = 0
        contentView.addSubview(sectionLabel!)
        sectionLabel?.invalidateIntrinsicContentSize()
        sectionLabel?.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        sectionLabel?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        sectionLabel?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        sectionLabel?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        sectionCollapseButton = UIButton()
        sectionCollapseButton?.setTitle("▼", for: .normal)
        sectionCollapseButton?.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1.0), for: .normal)
        sectionCollapseButton?.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        sectionCollapseButton!.transform = CGAffineTransform(rotationAngle: 0)
        sectionCollapseButton?.addTarget(nil, action: #selector(ShowProfileViewController.sectionCollapseButtonPressed(_:)) , for: .touchUpInside)
        contentView.addSubview(sectionCollapseButton!)
        sectionCollapseButton?.translatesAutoresizingMaskIntoConstraints = false
        sectionCollapseButton?.leadingAnchor.constraint(equalTo: sectionLabel!.trailingAnchor, constant: 10).isActive = true
        sectionCollapseButton?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        sectionCollapseButton?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        sectionCollapseButton?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }
}
