//
//  MainVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2018-12-26.
//  Copyright © 2018 Gabriel Siu. All rights reserved.
//

import UIKit
import Apollo

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var optionsBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.isHidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140.0
        
        optionsBtn.image = UIImage(named: "settings.png")
        
        getListOfTournaments()
    }

    //Pull to Refresh Control
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        TournamentDataService.instance.clearTournaments()
        TournamentDataService.instance.resetTournamentInfo()
        getListOfTournaments()
        refreshControl.endRefreshing()
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toSearchVC", sender: nil)
    }
    
    @IBAction func optionsBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toSettingsVC", sender: self)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        if segue.identifier == "unwindToMainVC" {
            if let settingsVC = segue.source as? SettingsVC {
                if settingsVC.dataChanged == true {
                    clearMainPage()
                    getListOfTournaments()
                }
            }
        }
    }
    
    func clearMainPage() {
        TournamentDataService.instance.clearTournaments()
        TournamentDataService.instance.resetTournamentInfo()
    }
    
    func getListOfTournaments() {
        spinner.isHidden = false
        spinner.startAnimating()
        
        self.tableView.reloadData()
        TournamentDataService.instance.getTournamentList(perPage: DefaultsService.instance.tournamentsPerPage, pageNum: 1/*CHANGE FOR INFINITE SCROLLING*/, videogameIds: DefaultsService.instance.preferredGames, filters: DefaultsService.instance.filters) { (success) in
            if success {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            } else {
                debugPrint("Error getting list of tournaments")
            }
        }
    }
    
    //Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TournamentDataService.instance.getTournaments().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tournamentCell", for: indexPath) as? TournamentCell {
            let tournament = TournamentDataService.instance.getTournaments()[indexPath.row]
            cell.updateTournamentPicture(imageUrl: tournament.imageName)
            cell.updateView(tournament: tournament)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
