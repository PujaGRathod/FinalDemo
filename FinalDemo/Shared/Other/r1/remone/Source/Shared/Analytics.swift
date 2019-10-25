//
//  Analytics.swift
//  remone
//
//  Created by Akshit Zaveri on 07/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import Foundation

class Analytics {
    
    static let shared = Analytics()
    
    init() {
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return
        }
        gai.tracker(withTrackingId: "UA-113733912-1")
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true
        
        // Optional: set Logger to VERBOSE for debug information.
        // TODO: Remove before app release.
//        gai.logger.logLevel = .verbose;

        gai.dispatchInterval = 60
    }

//    func appLaunch(with login: Bool) {
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker?.set(kGAIScreenName, value: name)
//        if let param = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable:Any] {
//            tracker?.send(param)
//        }
//    }

    func trackScreen(name: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        if let param = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable:Any] {
            tracker?.send(param)
        }
    }
    
    func track(category: String, action: String, label: String, value: NSNumber? = nil) {
        let tracker = GAI.sharedInstance().defaultTracker
        let parameters = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
        if let param = parameters?.build() as? [AnyHashable:Any] {
            tracker?.send(param)
        }
    }
    
    func trackTimestampPost(with status: TimeStampStatus) {
        self.track(category: "post_timestamp", action: "post", label: status.rawValue)
    }
    
    func trackTimestampPost(for company: RMCompany) {
        self.track(category: "post_timestamp", action: "post", label: company.name)
    }

    func trackTimestampLike(with status: TimeStampStatus) {
        self.track(category: "action_timestamp", action: "like", label: status.rawValue)
    }

    func trackTimestampComment(with status: TimeStampStatus) {
        self.track(category: "action_timestamp", action: "comment", label: status.rawValue)
    }
    
    func trackOfficeSearch(keyword: String) {
        if keyword.trimString().count > 0 {
            self.track(category: "office_search", action: "search", label: keyword)
        }
    }

    func trackPeopleSearch(keyword: String) {
        if keyword.trimString().count > 0 {
            self.track(category: "people_search", action: "search", label: keyword)
        }
    }
}
