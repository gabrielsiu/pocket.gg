//
//  AboutVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit
import SafariServices

final class AboutVC: UITableViewController {

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
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 { return aboutInfoCell }
        case 1:
            switch indexPath.row {
            case 0: return smashGgAPICell
            case 1: return apolloiOSCell
            default: break
            }
        case 2:
            let cell = UITableViewCell()
            cell.textLabel?.text = "@gabrielsiu_dev"
            cell.imageView?.image = UIImage(named: "icon-twitter")
            cell.imageView?.layer.masksToBounds = true
            cell.imageView?.layer.cornerRadius = k.Sizes.cornerRadius
            return cell
        default: break
        }
        return UITableViewCell()
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 2 ? "Contact" : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                guard let url = URL(string: k.URL.smashggAPI) else { break }
                present(SFSafariViewController(url: url), animated: true)
            case 1:
                guard let url = URL(string: k.URL.apolloiOS) else { break }
                present(SFSafariViewController(url: url), animated: true)
            default: break
            }
        case 2:
            guard let url = URL(string: k.URL.twitter) else { break }
            UIApplication.shared.open(url)
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 100 : UITableView.automaticDimension
    }
}
