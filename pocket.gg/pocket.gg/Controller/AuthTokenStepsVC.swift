//
//  AuthTokenStepsVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-24.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class AuthTokenStepsVC: UIViewController {
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissVC))
        addLabels()
    }
    
    // MARK: - Setup
    
    private func addLabels() {
        let scrollView = UIScrollView(frame: .zero)
        view.addSubview(scrollView)
        scrollView.setEdgeConstraints(top: view.topAnchor,
                                      bottom: view.bottomAnchor,
                                      leading: view.leadingAnchor,
                                      trailing: view.trailingAnchor)
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.setEdgeConstraints(top: scrollView.topAnchor,
                                       bottom: scrollView.bottomAnchor,
                                       leading: scrollView.leadingAnchor,
                                       trailing: scrollView.trailingAnchor)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        let label1 = UILabel(frame: .zero)
        label1.text = "How do I get an Auth Token?"
        label1.textAlignment = .left
        label1.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        
        let label2 = UILabel(frame: .zero)
        label2.textAlignment = .left
        label2.numberOfLines = 0
        let text = """
        To get an auth token, you will need to log onto smash.gg, and follow the steps below. \
        You may wish to perform these steps on another device (such as a personal computer), but the steps will be the same for any device.

        1. Log into smash.gg, creating an account if you don't have one already
        2. Click your profile icon on the bottom left (hidden in the top-left menu if you are on mobile), then click "Developer Settings"
        3. Click the "Create new token" button
        4. Type a description for the auth token (eg. "pocket.gg Auth Token"), then click "Save"
        5. Copy down the auth token somewhere safe (it should be a random sequence of alphanumeric characters)
        6. Return to the pocket.gg app, and enter your auth token in the "Auth Token" field
        7. Click the "Submit" button, and if all was successful, you should be able to use the pocket.gg app

        Keep in mind that your auth token will only be valid for approximately 1 year, \
        and once it expires, pocket.gg will prompt you for an auth token again. \
        If that happens, simply follow the steps above again to get a new auth token.
        """
        label2.text = text
        
        contentView.addSubview(label1)
        contentView.addSubview(label2)
        label1.setEdgeConstraints(top: contentView.topAnchor,
                                  bottom: label2.topAnchor,
                                  leading: contentView.leadingAnchor,
                                  trailing: contentView.trailingAnchor,
                                  padding: UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11))
        label2.setEdgeConstraints(top: label1.bottomAnchor,
                                  bottom: contentView.bottomAnchor,
                                  leading: contentView.leadingAnchor,
                                  trailing: contentView.trailingAnchor,
                                  padding: UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11))
    }
    
    // MARK: - Actions
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}
