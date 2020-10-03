//
//  LoadingViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-09-27.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class LoadingViewController: UIViewController {
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.setAxisConstraints(xAnchor: view.centerXAnchor, yAnchor: view.centerYAnchor)
    }
    
    deinit {
        print("LoadingViewController deinit")
    }
}
