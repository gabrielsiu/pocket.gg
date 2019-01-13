//
//  GameSelectionVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-01-03.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import UIKit

class GameSelectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searching = false
    var filtered: [String] = []
    var gameNameArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Video Game Selection"
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func fillGameNameArray() {
        for index in 0..<gameIdArray.count {
            gameNameArray.append(gamesDict[gameIdArray[index]] ?? "INVALID VIDEO GAME")
        }
    }
    
    func emptyGameNameArray() {
        gameNameArray.removeAll()
    }
    
    func isGameSelected(gameKey: Int) -> Bool {
        //See if the current game in gameKey is any one of the user's preferred games; if it is, then the switch will be enabled when it's cell is dequeued
        for element in DefaultsService.instance.preferredGames {
            if element == gameKey {
                return true
            }
        }
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isMovingToParent {
            fillGameNameArray()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            emptyGameNameArray()
            filtered.removeAll()
        }
    }
    
    //Search Bar Methods

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searching = true
        self.searchBar(searchBar, textDidChange: searchBar.text ?? "")
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searching = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered.removeAll()
        //Get a list of video game names, filtered by the text in the search bar
        filtered = gameNameArray.filter({ (text) -> Bool in
            let temp = text as NSString
            let range = temp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if filtered.count == 0 {
            searching = false
        } else {
            searching = true
        }
        self.tableView.reloadData()
    }
    
    //Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filtered.count
        } else {
            return gamesDict.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "videoGameCell", for: indexPath) as? VideoGameCell {
            
            //'status' records whether the user selected a particular video game or not
            var status = false
            
            if searching {
                //Get the game name from the filtered list (using indexPath.row as the index), and find it's corresponding key
                let gameKey = VideoGameService.instance.getKey(for: filtered[indexPath.row])
                if gameKey == -1 {
                    return UITableViewCell()
                }
                
                status = isGameSelected(gameKey: gameKey)
                
                let videoGame = VideoGame(name: filtered[indexPath.row], enabled: status)
                cell.updateView(videoGame: videoGame)
                
            } else {
                //gameKey will iterate over every single video game as the table view loads
                let gameKey = gameIdArray[indexPath.row]
                
                status = isGameSelected(gameKey: gameKey)
                
                let videoGame = VideoGame(name: gamesDict[gameIdArray[indexPath.row]] ?? "INVALID VIDEO GAME", enabled: status)
                cell.updateView(videoGame: videoGame)
            }

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
