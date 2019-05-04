//
//  TournamentVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-01-06.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import UIKit

class TournamentVC: UITableViewController, sendTournamentDataProtocol {
    
    //Outlets
    @IBOutlet weak var tournamentLabel: UINavigationItem!
    @IBOutlet weak var tournamentImage: UIImageView!
    @IBOutlet weak var tournamentGames: UILabel!
    @IBOutlet weak var tournamentDate: UILabel!
    
    
    //Variables
    var name: String!
    var games: String!
    var date: String!
    var image: UIImage!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tournamentLabel.title = name
        tournamentImage.image = image
        tournamentGames.text = games
        tournamentDate.text = date
    }
    
    //Delegate Method
    func sendDataToTournamentVC(name: String, games: String, date: String, image: UIImage) {
        self.name = name
        self.games = games
        self.date = date
        self.image = image
    }


}
