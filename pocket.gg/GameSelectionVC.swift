//
//  GameSelectionVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-01-03.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import UIKit

class GameSelectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Video Game Selection"
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    //Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "videoGameCell", for: indexPath) as? VideoGameCell {

            //gameKey will iterate over every single video game as the table view loads
            let gameKey = gameIdArray[indexPath.row]
            //'status' records whether the user selected a particular video game or not
            var status = false
            
            //See if the current game in gameKey is any one of the user's preferred games; if it is, then the switch will be enabled when it's cell is dequeued
            for element in DefaultsService.instance.preferredGames {
                if element == gameKey {
                    status = true
                    break
                }
            }
            
            let videoGame = VideoGame(name: gamesDict[gameIdArray[indexPath.row]] ?? "INVALID VIDEO GAME", enabled: status)
            cell.updateView(videoGame: videoGame)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
