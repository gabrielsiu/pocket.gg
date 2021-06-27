//
//  SetViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-06-21.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class SetViewController: UITableViewController {
    
    let set: PhaseGroupSet
    
    // MARK: - Initialization
    
    init(_ set: PhaseGroupSet) {
        self.set = set
        super.init(style: .insetGrouped)
        
        title = set.fullRoundText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissVC))
    }
    
    // MARK: - Actions
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Summary"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SetCell()
        cell.addSetInfo(set)
        return cell
    }
}
