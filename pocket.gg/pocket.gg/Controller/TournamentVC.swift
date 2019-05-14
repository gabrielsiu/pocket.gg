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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}


class TournamentVC: UITableViewController, sendTournamentDataProtocol {
    
    //Outlets
    @IBOutlet weak var tournamentLabel: UINavigationItem!
    @IBOutlet weak var tournamentImage: UIImageView!
    @IBOutlet weak var tournamentGames: UILabel!
    @IBOutlet weak var tournamentDate: UILabel!
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    
    //Variables
    var name: String!
    var games: String!
    var date: String!
    var image: UIImage!
    
    var dataSource = DataSource()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tournamentLabel.title = name
        tournamentImage.image = image
        tournamentGames.text = games
        tournamentDate.text = date
        
        eventsTableView.delegate = dataSource
        eventsTableView.dataSource = dataSource
    }
    
    //Delegate Method
    func sendDataToTournamentVC(name: String, games: String, date: String, image: UIImage) {
        self.name = name
        self.games = games
        self.date = date
        self.image = image
    }

    @IBAction func press(_ sender: Any) {
        EventsDataService.instance.getEvents(id: "72577") { (success) in
            print("done")
        }
    }
}
