//
//  TournamentCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2018-12-25.
//  Copyright © 2018 Gabriel Siu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class TournamentCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var tournamentImage: UIImageView!
    @IBOutlet weak var tournamentName: UILabel!
    @IBOutlet weak var tournamentGames: UILabel!
    @IBOutlet weak var tournamentDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateView(tournament: Tournament) {
        self.tournamentName.text = tournament.name
        self.tournamentGames.text = tournament.games
        self.tournamentDate.text = tournament.date
        //self.tournamentImage.image = tournament.image
    }
    
    func updateTournamentPicture(imageUrl: String) {
        Alamofire.request(imageUrl).responseImage { (response) in
            if response.result.error == nil {
                self.tournamentImage.image = response.result.value
            }
            else {
                debugPrint("Error updating the tournament picture")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
