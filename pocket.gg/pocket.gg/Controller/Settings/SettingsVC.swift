//
//  SettingsVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-12.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class SettingsVC: UITableViewController {

    var featuredCell = UITableViewCell()
    var upcomingCell = UITableViewCell()
    var videoGameSelectionCell = UITableViewCell()
    var authTokenCell = UITableViewCell()
    var appIconCell = UITableViewCell()
    var aboutCell = UITableViewCell()
    
    let authTokenDate = UserDefaults.standard.string(forKey: k.UserDefaults.authTokenDate)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupCells()
    }
    
    // MARK: - Setup
    
    private func setupCells() {
        let featuredSwitch = UISwitch()
        featuredSwitch.isOn = UserDefaults.standard.bool(forKey: k.UserDefaults.featuredTournaments)
        featuredSwitch.addTarget(self, action: #selector(featuredSwitchToggled(_:)), for: .valueChanged)
        featuredCell.accessoryView = featuredSwitch
        featuredCell.selectionStyle = .none
        featuredCell.textLabel?.text = "Featured"
        
        let upcomingSwitch = UISwitch()
        upcomingSwitch.isOn = UserDefaults.standard.bool(forKey: k.UserDefaults.upcomingTournaments)
        upcomingSwitch.addTarget(self, action: #selector(upcomingSwitchToggled(_:)), for: .valueChanged)
        upcomingCell.accessoryView = upcomingSwitch
        upcomingCell.selectionStyle = .none
        upcomingCell.textLabel?.text = "Upcoming"
        
        videoGameSelectionCell.accessoryType = .disclosureIndicator
        videoGameSelectionCell.textLabel?.text = "Video Game Selection"
        
        authTokenCell.accessoryType = .disclosureIndicator
        authTokenCell.textLabel?.text = "Auth Token"
        
        appIconCell.accessoryType = .disclosureIndicator
        appIconCell.textLabel?.text = "App Icon"
        
        aboutCell.accessoryType = .disclosureIndicator
        aboutCell.textLabel?.text = "About"
    }
    
    // MARK: - Actions
    
    @objc private func featuredSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: k.UserDefaults.featuredTournaments)
    }
    
    @objc private func upcomingSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: k.UserDefaults.upcomingTournaments)
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1, 2, 3, 4: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return featuredCell
            case 1: return upcomingCell
            default: return UITableViewCell()
            }
        case 1: return videoGameSelectionCell
        case 2: return appIconCell
        case 3: return authTokenCell
        case 4: return aboutCell
        default: return UITableViewCell()
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Tournament Sections" : nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        // TODO: CHANGE THIS WORDING
        case 0: return "Enable/Disable these to show/hide the \"Featured Tournaments\" and/or \"Upcoming Tournaments\" sections on the main screen"
        case 1: return "Only tournaments that feature events with at least 1 of the video games selected here will show up on the main screen"
        case 3:
            if let date = authTokenDate {
                return "Auth Token entered on " + date
            } else {
                return "No auth token present"
            }
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1: navigationController?.pushViewController(VideoGamesVC(), animated: true)
        case 2: navigationController?.pushViewController(AppIconVC(), animated: true)
        case 3: navigationController?.pushViewController(AuthTokenSettingsVC(authTokenDate), animated: true)
        case 4: navigationController?.pushViewController(AboutVC(style: .insetGrouped), animated: true)
        default: return
        }
    }
}
