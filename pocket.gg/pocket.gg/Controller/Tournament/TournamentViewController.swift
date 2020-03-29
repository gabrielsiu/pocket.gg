//
//  TournamentViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-08.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit
import SafariServices
import MapKit

final class TournamentViewController: UITableViewController {
    
    var headerImageView: UIImageView?
    let generalInfoCell: TournamentGeneralInfoCell
    let locationCell: TournamentLocationCell
    
    var tournament: Tournament
    var doneRequest = false // TODO: Add pull-to-refresh control, setting this back to false when data is refreshed (for all applicable screens)
    
    // MARK: - Initialization
    
    init(_ tournament: Tournament) {
        self.tournament = tournament
        generalInfoCell = TournamentGeneralInfoCell(tournament)
        locationCell = TournamentLocationCell()
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = tournament.name
        
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: k.Identifiers.eventCell)
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: k.Identifiers.streamCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        setupHeaderImageView()
        loadTournamentDetails()
    }
    
    // MARK: - UI Setup
    
    private func setupHeaderImageView() {
        NetworkService.getImage(imageUrl: tournament.headerImage.url) { [weak self] (header) in
            guard let header = header else { return }
            
            DispatchQueue.main.async {
                guard let ratio = self?.tournament.headerImage.ratio else { return }
                guard let width = self?.tableView.frame.width else { return }
                
                // TODO: Using constraints, fix so that the header expands to fit the screen upon rotating the device
                self?.headerImageView = UIImageView.init(image: header)
                self?.headerImageView?.contentMode = .scaleAspectFit
                // TODO: Animate this frame change
                self?.headerImageView?.frame = CGRect(x: 0, y: 0, width: width, height: width / CGFloat(ratio))
                self?.tableView.tableHeaderView = self?.headerImageView
            }
        }
    }
    
    private func loadTournamentDetails() {
        NetworkService.getTournamentDetailsById(id: tournament.id) { [weak self] (details) in
            self?.doneRequest = true
            guard let details = details else {
                let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.generateTournamentMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            
            self?.tournament.location = details["location"] as? Tournament.Location
            self?.tournament.contactInfo = details["contact"] as? String
            self?.tournament.events = details["events"] as? [Tournament.Event]
            self?.tournament.streams = details["streams"] as? [Tournament.Stream]
            self?.tournament.registration = details["registration"] as? (Bool, String)
            self?.tournament.slug = details["slug"] as? String
            
            self?.generalInfoCell.updateView(location: self?.tournament.location?.address, {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            })
            self?.locationCell.updateView(location: self?.tournament.location)
            self?.tableView.reloadSections([1, 2, 3], with: .automatic)
        }
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Sections:
        // 0 - General Info
        // 1 - Events
        // 2 - Streams
        // 3 - Location
        // 4 - Registration
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return tournament.events?.count ?? 1
        case 2: return tournament.streams?.count ?? 1
        case 3:
            guard tournament.location?.latitude != nil, tournament.location?.longitude != nil else { return 1 }
            return 2
        case 4: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return generalInfoCell
            
        case 1:
            guard !(tournament.events?.isEmpty ?? true) else {
                return doneRequest ? UITableViewCell().setupDisabled("No events currently available") : LoadingCell()
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.eventCell) as? SubtitleCell {
                guard let event = tournament.events?[safe: indexPath.row] else {
                    return UITableViewCell()
                }
                let dateText = DateFormatter.shared.dateFromTimestamp(event.startDate)
                cell.setPlaceholder("game-controller")
                cell.updateView(text: event.name, imageInfo: event.videogameImage, detailText: dateText, newRatio: k.Sizes.eventImageRatio)
                return cell
            }
            return UITableViewCell()
            
        case 2:
            guard !(tournament.streams?.isEmpty ?? true) else {
                return doneRequest ? UITableViewCell().setupDisabled("No streams currently available") : LoadingCell()
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.streamCell) as? SubtitleCell {
                guard let stream = tournament.streams?[safe: indexPath.row] else {
                    return UITableViewCell()
                }
                cell.setPlaceholder("placeholder")
                cell.updateView(text: stream.name, imageInfo: (stream.logoUrl, nil), detailText: stream.game)
                return cell
            }
            return UITableViewCell()
            
        case 3:
            switch indexPath.row {
            case 0: return locationCell
            case 1: return UITableViewCell().setupActive(textColor: view.tintColor, text: "Get Directions")
            default: return UITableViewCell()
            }
            
        case 4:
            guard doneRequest else { return LoadingCell() }
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let registrationOpen = tournament.registration?.isOpen ?? false
            let closeDate = DateFormatter.shared.dateFromTimestamp(tournament.registration?.closeDate)
            cell.isUserInteractionEnabled = registrationOpen
            cell.textLabel?.textColor = view.tintColor
            cell.textLabel?.text = registrationOpen ? "Register" : "Registration not available"
            cell.detailTextLabel?.text = "Close\(registrationOpen ? "s" : "d") on \(closeDate)"
            cell.accessoryType = registrationOpen ? .disclosureIndicator : .none
            return cell
            
        default: return UITableViewCell()
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Events"
        case 2: return "Streams"
        case 3: return "Location"
        case 4: return "Registration"
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 3:
            switch indexPath.row {
            case 0: return k.Sizes.mapHeight
            default: return UITableView.automaticDimension
            }
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            guard let event = tournament.events?[safe: indexPath.row] else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            navigationController?.pushViewController(EventViewController(event), animated: true)
        case 3:
            switch indexPath.row {
            case 1:
                tableView.deselectRow(at: indexPath, animated: true)
                if let lat = tournament.location?.latitude, let lng = tournament.location?.longitude {
                    let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = tournament.location?.venueName ?? tournament.location?.address
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                }
            default: return
            }
        case 4:
            guard let slug = tournament.slug else { return }
            guard let url = URL(string: "https://smash.gg/\(slug)/register") else {
                debugPrint(k.Error.urlGeneration, "https://smash.gg/\(slug)/register")
                return
            }
            present(SFSafariViewController(url: url), animated: true)
        default: return
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 4: return tournament.registration?.isOpen ?? false ? "Registering for a tournament will take you to smash.gg." : ""
        default: return ""
        }
    }
}
