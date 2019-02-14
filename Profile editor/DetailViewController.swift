//
//  DetailViewController.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 8/02/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = "\(detail.0)  \n\(detail.1)   \n\(detail.2)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: (String, String, Int)? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

