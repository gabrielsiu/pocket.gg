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
    var locationCell: TournamentLocationCell?
    
    var tournament: Tournament
    var doneRequest = false // TODO: Add pull-to-refresh control, setting this back to false when data is refreshed (for all applicable screens)
    var requestSuccessful = true
    var tournamentIsOnline: Bool {
        return tournament.isOnline ?? true
    }
    
    // MARK: - Initialization
    
    init(_ tournament: Tournament) {
        self.tournament = tournament
        generalInfoCell = TournamentGeneralInfoCell(tournament)
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
        
        setupHeaderImageView()
        loadTournamentDetails()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        locationCell?.updateImageForOrientation()
    }
    
    // MARK: - UI Setup
    
    private func setupHeaderImageView() {
        NetworkService.getImage(imageUrl: tournament.headerImage?.url) { [weak self] (result) in
            guard let result = result else { return }
            
            DispatchQueue.main.async {
                guard let ratio = self?.tournament.headerImage?.ratio else { return }
                guard let width = self?.tableView.frame.width else { return }
                
                // TODO: Make the header image appear consistent independent of the device orientation when this screen is loaded
                self?.headerImageView = UIImageView.init(image: result)
                self?.headerImageView?.contentMode = .scaleAspectFit
                // TODO: Animate this frame change
                self?.headerImageView?.frame = CGRect(x: 0, y: 0, width: width, height: width / CGFloat(ratio))
                self?.tableView.tableHeaderView = self?.headerImageView
            }
        }
    }
    
    private func loadTournamentDetails() {
        NetworkService.getTournamentDetailsById(id: tournament.id ?? -1) { [weak self] (result) in
            guard let result = result else {
                self?.doneRequest = true
                self?.requestSuccessful = false
                let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.generateTournamentMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                self?.tableView.reloadData()
                return
            }
            
            self?.tournament.location?.venueName = result["venueName"] as? String
            self?.tournament.location?.longitude = result["longitude"] as? Double
            self?.tournament.location?.latitude = result["latitude"] as? Double
            
            if let id = self?.tournament.id, let lat = self?.tournament.location?.latitude, let long = self?.tournament.location?.longitude {
                self?.locationCell = TournamentLocationCell(id: id, latitude: lat, longitude: long)
            }
            
            self?.tournament.events = result["events"] as? [Event]
            self?.tournament.streams = result["streams"] as? [Stream]
            self?.tournament.registration = result["registration"] as? (Bool, String)
            self?.tournament.slug = result["slug"] as? String
            self?.tournament.contact = result["contact"] as? (String, String)
            
            self?.doneRequest = true
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Table View Data Source

    // Sections:
    // Not Online:              Online:
    // 0 - General Info         0 - General Info
    // 1 - Events               1 - Events
    // 2 - Streams              2 - Streams
    // 3 - Location             3 - Contact Info
    // 4 - Contact Info         4 - Registration
    // 5 - Registration
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tournamentIsOnline ? 5 : 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return tournament.events?.count ?? 1
        case 2: return tournament.streams?.count ?? 1
        default: break
        }
        
        switch section {
        case 3:
            // If tournament is online, section 3 is the Contact Info section (only 1 cell)
            guard !tournamentIsOnline else { return 1 }
            // Until location has been retrieved, return a LoadingCell
            guard doneRequest else { return 1 }
            // If the latitude or longitude is missing, show a "Location not available" cell
            guard tournament.location?.latitude != nil, tournament.location?.longitude != nil else { return 1 }
            // Show the location cells & a "Get directions" cell
            return 3
        case 4:
            // Section 4 will always have only 1 cell (Contact Info or Registration section)
            return 1
        case 5:
            // If tournament is online, section 5 does not exist
            return tournamentIsOnline ? 0 : 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return generalInfoCell
            
        case 1:
            guard requestSuccessful else {
                return UITableViewCell().setupDisabled("Unable to load events")
            }
            guard !(tournament.events?.isEmpty ?? true) else {
                return doneRequest ? UITableViewCell().setupDisabled("No events currently available") : LoadingCell()
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.eventCell) as? SubtitleCell {
                guard let event = tournament.events?[safe: indexPath.row] else { break }
                
                cell.accessoryType = .disclosureIndicator
                cell.setPlaceholder("game-controller")
                
                var detailText = "● "
                let dotColor: UIColor
                switch event.state ?? "" {
                case "ACTIVE":
                    detailText += "In Progress"
                    dotColor = .systemGreen
                case "COMPLETED":
                    guard let winner = event.winner else { fallthrough }
                    detailText += "1st place: " + winner
                    dotColor = .systemGray
                default:
                    detailText += DateFormatter.shared.dateFromTimestamp(event.startDate)
                    dotColor = .systemBlue
                }
                
                let attributedDetailText = NSMutableAttributedString(string: detailText)
                attributedDetailText.addAttribute(.foregroundColor, value: dotColor, range: NSRange(location: 0, length: 1))
                
                cell.updateView(text: event.name, imageInfo: event.videogameImage, detailText: nil, newRatio: k.Sizes.eventImageRatio)
                cell.detailTextLabel?.attributedText = attributedDetailText
                
                return cell
            }
            
        case 2:
            guard requestSuccessful else {
                return UITableViewCell().setupDisabled("Unable to load streams")
            }
            guard !(tournament.streams?.isEmpty ?? true) else {
                return doneRequest ? UITableViewCell().setupDisabled("No streams currently available") : LoadingCell()
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.streamCell) as? SubtitleCell {
                guard let stream = tournament.streams?[safe: indexPath.row] else { break }
                cell.accessoryType = .disclosureIndicator
                cell.setPlaceholder("placeholder")
                cell.updateView(text: stream.name, imageInfo: (stream.logoUrl, nil), detailText: stream.game)
                return cell
            }
            
        case 3: return tournamentIsOnline ? contactInfoSectionCell() : locationSectionCell(indexPath)
        case 4: return tournamentIsOnline ? registrationSectionCell() : contactInfoSectionCell()
        case 5: return registrationSectionCell()
        default: break
        }
        return UITableViewCell()
    }
    
    // MARK: - Section-Dependent Table View Cells
    
    private func locationSectionCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard requestSuccessful else {
            return UITableViewCell().setupDisabled("Unable to load location")
        }
        guard doneRequest else { return LoadingCell() }
        switch indexPath.row {
        case 0:
            if let locationCell = locationCell { return locationCell }
            if !tournamentIsOnline {
                if let id = tournament.id, let latitude = tournament.location?.latitude, let longitude = tournament.location?.longitude {
                    locationCell = TournamentLocationCell(id: id, latitude: latitude, longitude: longitude)
                    return locationCell ?? TournamentLocationCell(id: id, latitude: latitude, longitude: longitude)
                } else {
                    return UITableViewCell().setupDisabled("No location available")
                }
            }
        case 1:
            let cell = SubtitleCell()
            cell.selectionStyle = .none
            if tournament.location?.venueName != nil {
                cell.textLabel?.text = tournament.location?.venueName
                cell.detailTextLabel?.text = tournament.location?.address
            } else {
                cell.textLabel?.text = tournament.location?.address
            }
            return cell
        case 2: return UITableViewCell().setupActive(textColor: .systemRed, text: "Get Directions")
        default: break
        }
        return UITableViewCell()
    }
    
    private func contactInfoSectionCell() -> UITableViewCell {
        guard requestSuccessful else {
            return UITableViewCell().setupDisabled("Unable to load contact info")
        }
        guard doneRequest else { return LoadingCell() }
        guard let contactInfo = tournament.contact?.info else {
            return UITableViewCell().setupDisabled("No contact info available")
        }
        let cell = UITableViewCell()
        cell.textLabel?.textColor = .systemRed
        cell.textLabel?.text = contactInfo
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func registrationSectionCell() -> UITableViewCell {
        guard requestSuccessful else {
            return UITableViewCell().setupDisabled("Unable to load registration info")
        }
        guard doneRequest else { return LoadingCell() }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let registrationOpen = tournament.registration?.isOpen ?? false
        let closeDate = DateFormatter.shared.dateFromTimestamp(tournament.registration?.closeDate)
        cell.isUserInteractionEnabled = registrationOpen
        cell.textLabel?.textColor = .systemRed
        cell.textLabel?.text = registrationOpen ? "Register" : "Registration not available"
        cell.detailTextLabel?.text = "Close\(registrationOpen ? "s" : "d") on \(closeDate)"
        cell.accessoryType = registrationOpen ? .disclosureIndicator : .none
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Events"
        case 2: return "Streams"
        case 3: return tournamentIsOnline ? "Contact Info" : "Location"
        case 4: return tournamentIsOnline ? "Registration" : "Contact Info"
        case 5: return "Registration"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !tournamentIsOnline else { return UITableView.automaticDimension }
        guard doneRequest, requestSuccessful else { return UITableView.automaticDimension }
        return indexPath.section == 3 && indexPath.row == 0 ? k.Sizes.mapHeight : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            guard let event = tournament.events?[safe: indexPath.row] else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            navigationController?.pushViewController(EventViewController(event), animated: true)
            
        case 2:
            presentStreamAlert(indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
            
        case 3:
            if tournamentIsOnline { fallthrough }
            if indexPath.row == 2 {
                if let lat = tournament.location?.latitude, let lng = tournament.location?.longitude {
                    let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = tournament.location?.venueName ?? tournament.location?.address
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        case 4:
            if tournamentIsOnline && indexPath.section == 4 { fallthrough }
            tableView.deselectRow(at: indexPath, animated: true)
            guard let contactInfoType = tournament.contact?.type else { return }
            
            let urlPrefix = contactInfoType == "email" ? "mailto:" : ""
            if let contactInfo = tournament.contact?.info, let url = URL(string: "\(urlPrefix)\(contactInfo)") {
                UIApplication.shared.open(url)
                return
            }
            
        case 5:
            if tournamentIsOnline && indexPath.section == 5 { return }
            guard let slug = tournament.slug else { return }
            guard let url = URL(string: "https://smash.gg/\(slug)/register") else {
                tableView.deselectRow(at: indexPath, animated: true)
                debugPrint(k.Error.urlGeneration, "https://smash.gg/\(slug)/register")
                return
            }
            present(SFSafariViewController(url: url), animated: true)
            
        default: return
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let registrationSection = tournamentIsOnline ? 4 : 5
        if section == registrationSection {
            return tournament.registration?.isOpen ?? false ? "Registering for a tournament will take you to smash.gg." : nil
        }
        return nil
    }
    
    // MARK: - Stream Alert Presentation
    
    private func presentStreamAlert(_ indexPath: IndexPath) {
        guard let twitchURL = URL(string: "twitch://open") else { return }
        let twitchAppInstalled = UIApplication.shared.canOpenURL(twitchURL)
        
        guard let stream = tournament.streams?[safe: indexPath.row], let streamName = stream.name?.lowercased() else { return }
        
        let message: String
        if twitchAppInstalled {
            message = "Choose one of the options to view the stream."
        } else {
            message = "The Twitch app is not installed. Please install the Twitch app, or choose one of the options to view the stream."
        }
        let alert = UIAlertController(title: "View Stream", message: message, preferredStyle: .alert)
        
        if twitchAppInstalled {
            alert.addAction(UIAlertAction(title: "Twitch", style: .default, handler: { _ in
                guard let url = URL(string: "twitch://stream/" + streamName) else { return }
                UIApplication.shared.open(url)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Install Twitch", style: .default, handler: { _ in
                guard let url = URL(string: "itms-apps://apple.com/app/id460177396") else { return }
                UIApplication.shared.open(url)
            }))
            alert.addAction(UIAlertAction(title: "Safari", style: .default, handler: { _ in
                guard let url = URL(string: k.URL.twitch + streamName) else { return }
                UIApplication.shared.open(url)
            }))
        }
        alert.addAction(UIAlertAction(title: "In-App Safari", style: .default, handler: { [weak self] _ in
            guard let url = URL(string: k.URL.twitch + streamName) else { return }
            self?.present(SFSafariViewController(url: url), animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
