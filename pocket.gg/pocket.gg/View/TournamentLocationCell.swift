//
//  TournamentLocationCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-06.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit
import MapKit

final class TournamentLocationCell: UITableViewCell {
    
    var locationNotAvailableView: UIView?
    var locationNotAvailableLabel: UILabel?
    let mapView = MKMapView()

    // MARK: - Initialization
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        // WORK ON THIS
        setupViews()
        setupConstraints()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        contentView.addSubview(mapView)
    }
    
    private func setupConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    private func setupLocationNotAvailableView() {
        locationNotAvailableView = UIView()
        locationNotAvailableView?.backgroundColor = .white
        locationNotAvailableView?.alpha = 0.5
        
        locationNotAvailableLabel = UILabel()
        locationNotAvailableLabel?.text = "Location not available"
        
        guard let view = locationNotAvailableView else { return }
        guard let label = locationNotAvailableLabel else { return }
        
        view.addSubview(label)
        contentView.addSubview(view)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    // MARK: - Public Methods
    
    func updateView(location: Tournament.Location) {
        if let lat = location.latitude, let lng = location.longitude {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lng), latitudinalMeters: 1000, longitudinalMeters: 1000)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            annotation.title = location.venueName
            annotation.subtitle = location.address
            mapView.setRegion(region, animated: false)
            mapView.addAnnotation(annotation)
        } else {
            setupLocationNotAvailableView()
        }
    }
}
