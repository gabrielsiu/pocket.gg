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
    var smashGgAPICell = UITableViewCell()
    var apolloiOSCell = UITableViewCell()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        
        setupCells()
    }
    
    // MARK: - Setup
    
    private func setupCells() {
        smashGgAPICell.accessoryType = .disclosureIndicator
        smashGgAPICell.textLabel?.text = "smash.gg GraphQL API"
        
        apolloiOSCell.accessoryType = .disclosureIndicator
        apolloiOSCell.textLabel?.text = "Apollo iOS"
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
        case 1: return 2
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
            case 0: return smashGgAPICell
            case 1: return apolloiOSCell
            default: fatalError("Invalid row in section 1")
            }
        default: fatalError("Invalid section")
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 { return "Libraries & Thanks" }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0: showWebpage(with: k.URL.smashGgAPI)
            case 1: showWebpage(with: k.URL.apolloiOS)
            default: fatalError("Invalid row tapped")
            }
        default: return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 100 }
        return UITableView.automaticDimension
    }
}
