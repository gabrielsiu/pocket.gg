//
//  TournamentVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-01-06.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import UIKit


class DataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventsDataService.instance.getEvents().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventCell {
            let event = EventsDataService.instance.getEvents()[indexPath.row]
            cell.updateView(event: event)
            cell.updateEventPicture(imageUrl: event.imageUrl)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}


class TournamentVC: UITableViewController, sendTournamentDataProtocol {
    
    //Outlets
    @IBOutlet weak var tournamentLabel: UINavigationItem!
    @IBOutlet weak var tournamentImage: UIImageView!
    @IBOutlet weak var tournamentGames: UILabel!
    @IBOutlet weak var tournamentDate: UILabel!
    
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    //Variables
    var name: String!
    var games: String!
    var date: String!
    var image: UIImage!
    var id: String!
    
    var dataSource = DataSource()
    
    //Instantiate Alert Controller
    let alertController = UIAlertController(title: "Error getting list of events", message: "No events available for the selected tournament", preferredStyle: .alert)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tournamentLabel.title = name
        tournamentImage.image = image
        tournamentGames.text = games
        tournamentDate.text = date
        
        eventsTableView.delegate = dataSource
        eventsTableView.dataSource = dataSource
        
        spinner.isHidden = true
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (result: UIAlertAction) -> Void in
        }
        self.alertController.addAction(okAction)
        
        getListOfEvents()
    }
    
    //Delegate Method
    func sendDataToTournamentVC(name: String, games: String, date: String, image: UIImage, id: String) {
        self.name = name
        self.games = games
        self.date = date
        self.image = image
        self.id = id
    }
    
    func getListOfEvents() {
        spinner.isHidden = false
        spinner.startAnimating()
        
        self.tableView.reloadData()
        EventsDataService.instance.getEvents(id: self.id) { (success) in
            if success {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            } else {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                self.present(self.alertController, animated: true, completion: nil)
                debugPrint("Error getting list of events")
            }
        }
    }

    
}
