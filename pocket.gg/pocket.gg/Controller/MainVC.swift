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
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var optionsBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        menuBtn.target = self.revealViewController()
        menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        menuBtn.image = UIImage(named: "menu.png")
        optionsBtn.image = UIImage(named: "settings.png")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
 
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        TournamentDataService.instance.clearTournaments()
        TournamentDataService.instance.resetTournamentInfo()
        getListOfTournaments()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func reloadBtnPressed(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    @IBAction func testBtnPressed(_ sender: Any) {
        TournamentDataService.instance.getTournamentList(perPage: DefaultsService.instance.tournamentsPerPage, pageNum: 1, videogameIds: DefaultsService.instance.preferredGames, filters: DefaultsService.instance.filters) { (success) in
            if success {
                print("tournament list gotten successfully")
            } else {
                print("error getting tournaments")
            }
        }
    }
    
    @IBAction func optionsBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toSettingsVC", sender: nil)
    }
    
    
    func getListOfTournaments() {
        TournamentDataService.instance.getTournamentList(perPage: DefaultsService.instance.tournamentsPerPage, pageNum: 1/*CHANGE FOR INFINITE SCROLLING*/, videogameIds: DefaultsService.instance.preferredGames, filters: DefaultsService.instance.filters) { (success) in
            if success {
                print("should be reloading data....")
                self.tableView.reloadData()
                print("data has been reloaded...")
            } else {
                print("somehow failed....")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNavController = segue.destination as! UINavigationController
        let targetVC = destNavController.topViewController
        if let settingsVC = targetVC as? SettingsVC {
            print("hi")
        }
    }
}
