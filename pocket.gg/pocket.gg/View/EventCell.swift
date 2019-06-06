//
//  EventCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-05-24.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class EventCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateView(event: Event) {
        self.eventName.text = event.name
        self.eventDate.text = event.name
    }
    
    func updateEventPicture(imageUrl: String) {
        Alamofire.request(imageUrl).responseImage { (response) in
            if response.result.error == nil {
                self.eventImage.image = response.result.value
            }
            else {
                debugPrint("Error updating the event picture")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
