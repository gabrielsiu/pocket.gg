//
//  SettingsViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-12.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class SettingsViewController: UITableViewController {

    var featuredCell = UITableViewCell()
    var upcomingCell = UITableViewCell()
    var videoGameSelectionCell = UITableViewCell()
    var aboutCell = UITableViewCell()
    
    var featuredSwitch = UISwitch()
    var upcomingSwitch = UISwitch()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissVC)), animated: true)
        
        setupCells()
    }
    
    // MARK: - Setup
    
    private func setupCells() {
        featuredSwitch.isOn = UserDefaults.standard.bool(forKey: k.UserDefaults.featuredTournaments)
        upcomingSwitch.isOn = UserDefaults.standard.bool(forKey: k.UserDefaults.upcomingTournaments)
        
        featuredSwitch.addTarget(self, action: #selector(featuredSwitchToggled(_:)), for: .valueChanged)
        upcomingSwitch.addTarget(self, action: #selector(upcomingSwitchToggled(_:)), for: .valueChanged)
        
        featuredCell.accessoryView = featuredSwitch
        upcomingCell.accessoryView = upcomingSwitch
        videoGameSelectionCell.accessoryType = .disclosureIndicator
        aboutCell.accessoryType = .disclosureIndicator
        
        featuredCell.selectionStyle = .none
        upcomingCell.selectionStyle = .none
        
        featuredCell.textLabel?.text = "Featured"
        upcomingCell.textLabel?.text = "Upcoming"
        videoGameSelectionCell.textLabel?.text = "Video Game Selection"
        aboutCell.textLabel?.text = "About"
    }
    
    // MARK: - Actions
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
        // TODO: Refresh main tournament list if any preferences were changed
    }
    
    @objc private func featuredSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: k.UserDefaults.featuredTournaments)
    }
    
    @objc private func upcomingSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: k.UserDefaults.upcomingTournaments)
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1, 2: return 1
        default: fatalError("Invalid number of sections")
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return featuredCell
            case 1: return upcomingCell
            default: fatalError("Invalid row in section 0")
            }
        case 1:
            switch indexPath.row {
            case 0: return videoGameSelectionCell
            default: fatalError("Invalid row in section 1")
            }
        case 2:
            switch indexPath.row {
            case 0: return aboutCell
            default: fatalError("Invalid row in section 2")
            }
        default: fatalError("Invalid section")
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Enable/Disable Filters"
        case 1, 2: return ""
        default: fatalError("Invalid section")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let preferredGames = UserDefaults.standard.array(forKey: k.UserDefaults.preferredVideoGames) as? [Int] ?? [1]
            navigationController?.pushViewController(VideoGamesViewController(preferredGames: preferredGames), animated: true)
        case 2:
            // TODO: Add About page
            print("hi")
        default: return
        }
    }
    
}
