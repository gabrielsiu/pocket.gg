//
//  TournamentCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2018-12-25.
//  Copyright © 2018 Gabriel Siu. All rights reserved.
//

import UIKit

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
    
    func updateView(tournamentImage: UIImage, tournamentTitle: String, tournamentGames: String, tournamentDate: String) {
        self.tournamentImage.image = tournamentImage
        self.tournamentName.text = tournamentTitle
        self.tournamentGames.text = tournamentGames
        self.tournamentDate.text = tournamentDate
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
