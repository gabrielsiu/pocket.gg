//
//  MainVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2018-12-26.
//  Copyright © 2018 Gabriel Siu. All rights reserved.
//

import UIKit
import Apollo

protocol sendTournamentDataProtocol {
    func sendDataToTournamentVC(name: String, games: String, date: String, image: UIImage)
}

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var optionsBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //Variables
    var delegate: sendTournamentDataProtocol? = nil //Delegate variable
    var tournamentClickedName: String? = nil
    var tournamentClickedGames: String? = nil
    var tournamentClickedDate: String? = nil
    var tournamentClickedImage: UIImage? = nil
    
    
    //Instantiate Alert Controller
    let alertController = UIAlertController(title: "Error getting list of tournaments", message: "No tournaments available for the selected game(s)", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.isHidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (result: UIAlertAction) -> Void in
        }
        self.alertController.addAction(okAction)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        optionsBtn.image = UIImage(named: "settings.png")
        
        getListOfTournaments()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    // MARK: - Pull to Refresh Control
    
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
        TournamentDataService.instance.getTournamentList(perPage: DefaultsService.instance.tournamentsPerPage, pageNum: 1/*CHANGE FOR INFINITE SCROLLING*/, videogameIds: DefaultsService.instance.preferredGames.map { String($0)}, filters: DefaultsService.instance.filters) { (success) in
            if success {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            } else {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                self.present(self.alertController, animated: true, completion: nil)
                debugPrint("Error getting list of tournaments")
            }
        }
    }
    
    // MARK: - Table View Methods
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //When selecting the row, a segue is performed. Right before the transition, prepareForSegue is called, where the delegate of MainVC (which is TournamentVC) is set. Then the tournament data is passed to the delegate
        performSegue(withIdentifier: "mainToTournamentVC", sender: self)
        
        //Access the tapped cell
        let currentCell = tableView.cellForRow(at: indexPath) as! TournamentCell
        
        //Grab the current cell's information and store them in temporary variables
        tournamentClickedName = currentCell.tournamentName.text
        tournamentClickedGames = currentCell.tournamentGames.text
        tournamentClickedDate = currentCell.tournamentDate.text
        tournamentClickedImage = currentCell.tournamentImage.image
        
        //Pass the information from the temporary variables to the delegate
        self.delegate?.sendDataToTournamentVC(name: tournamentClickedName!, games: tournamentClickedGames!, date: tournamentClickedDate!, image: tournamentClickedImage!)
        
        //Unhighlight the row after it's tapped
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Set the delegate of MainVC as TournamentVC
        if let tournamentVC = segue.destination as? TournamentVC {
            self.delegate = tournamentVC
        }
    }
}
