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
    var aboutCell = UITableViewCell()
    
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
        
        aboutCell.accessoryType = .disclosureIndicator
        aboutCell.textLabel?.text = "About"
    }
    
    @objc private func featuredSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: k.UserDefaults.featuredTournaments)
    }
    
    @objc private func upcomingSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: k.UserDefaults.upcomingTournaments)
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1, 2, 3: return 1
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
        case 2: return authTokenCell
        case 3: return aboutCell
        default: return UITableViewCell()
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Tournament Filters" }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "Enable/Disable these to change the types of tournaments that show up on the main screen."
        case 1: return "Only tournaments that feature events with at least 1 of the video games selected here will show up on the main screen."
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            navigationController?.pushViewController(VideoGamesVC(), animated: true)
        case 3:
            navigationController?.pushViewController(AboutVC(style: .insetGrouped), animated: true)
        default: return
        }
    }
}
