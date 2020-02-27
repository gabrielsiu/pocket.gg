//
//  AboutViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit
import SafariServices

final class AboutViewController: UITableViewController {

    var aboutInfoCell = AboutInfoCell()
    var apolloiOSCell = UITableViewCell()
    var placeholderIconCell = UITableViewCell()
    var settingsIconCell = UITableViewCell()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        
        setupCells()
    }
    
    // MARK: - Setup
    
    private func setupCells() {
        apolloiOSCell.accessoryType = .disclosureIndicator
        placeholderIconCell.accessoryType = .disclosureIndicator
        settingsIconCell.accessoryType = .disclosureIndicator
        
        apolloiOSCell.textLabel?.text = "Apollo iOS"
        placeholderIconCell.textLabel?.text = "iOS Application Placeholder icon by Icons8"
        settingsIconCell.textLabel?.text = "Settings icon by Icons8"
    }
    
    // MARK: - Actions
    
    private func showWebpage(with pageUrl: String) {
        guard let url = URL(string: pageUrl) else {
            debugPrint(k.Error.urlGeneration, pageUrl)
            return
        }
        present(SFSafariViewController(url: url), animated: true)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        default: fatalError("Invalid number of sections")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return aboutInfoCell
            default: fatalError("Invalid row in section 0")
            }
        case 1:
            switch indexPath.row {
            case 0: return apolloiOSCell
            case 1: return placeholderIconCell
            case 2: return settingsIconCell
            default: fatalError("Invalid row in section 1")
            }
        default: fatalError("Invalid section")
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return ""
        case 1: return "Libraries & Thanks"
        default: fatalError("Invalid section")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0: showWebpage(with: k.URL.apolloiOS)
            case 1: showWebpage(with: k.URL.placeholderIcon)
            case 2: showWebpage(with: k.URL.settingsIcon)
            default: fatalError("Invalid row tapped")
            }
        default: return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        return UITableView.automaticDimension
    }
}
