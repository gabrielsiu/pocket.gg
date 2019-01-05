//
//  VideoGameCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-01-03.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import UIKit

class VideoGameCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var videoGameName: UILabel!
    @IBOutlet weak var videoGameSwitch: UISwitch!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
