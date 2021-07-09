//
//  AnalyticsService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-07-09.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class AnalyticsService {
    
    static var reportedPhaseGroupIDs = Set<Int>()
    
    static func reportPhaseGroup(_ id: Int?) {
        guard let id = id else { return }
        guard !reportedPhaseGroupIDs.contains(id) else { return }
        reportedPhaseGroupIDs.insert(id)
        Analytics.logEvent("bracketLayoutError", parameters: ["phaseGroupID": id as NSNumber])
    }
}
