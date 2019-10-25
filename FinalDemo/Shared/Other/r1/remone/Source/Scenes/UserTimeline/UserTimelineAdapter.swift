//
//  UserTimelineAdapter.swift
//  remone
//
//  Created by Arjav Lad on 27/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol UserTimelineAdapterDelegate {
    func comment(timestamp: RMTimestamp?)
    func showOption(timestamp: RMTimestamp?)
    func showLocation(timestamp: RMTimestamp?)
    func didSelect(timeStamp: RMTimestamp?)
    func showUserProfile(timestamp: RMTimestamp?)
    func dataLoadedInTableView(_ newDataFound: Bool)
    func pullToRefresh()
}

struct TimestampDisplayModel: Hashable {

    var hashValue: Int {
        return date.hashValue
    }

    static func ==(lhs: TimestampDisplayModel, rhs: TimestampDisplayModel) -> Bool {
        return lhs.date == rhs.date
    }

    var date: Date!
    var dateStartInterval: TimeInterval!
    var dateEndInterval: TimeInterval!
    var timestamps: [RMTimestamp] = []
}

class UserTimelineAdapter: NSObject {

    private let tblTimestampList: UITableView
    private let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    private var timeStamps: [RMTimestamp] = [RMTimestamp]()
    private var sortedTimestamps: [TimestampDisplayModel] = []
    var showAlert: ((String?, String?) -> Void)?
    let delegate: UserTimelineAdapterDelegate
    var currentRequest: APIManager.APIRequest?
    var paging: Pagination = Pagination()
    var isLoadingData: Bool = false
    private var refreshControl: UIRefreshControl = UIRefreshControl.init()
    private var userid: String?

    init(with tableView: UITableView, withDelegate: UserTimelineAdapterDelegate, for userid: String? = nil) {
        self.tblTimestampList = tableView
        self.delegate = withDelegate
        self.userid = userid
        super.init()
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ReloadTimeline"), object: nil, queue: .main) { (notification) in
//            self.reloadTimeline()
//        }
        self.setupTableView()
    }

    func updateUser(id: String) {
        self.userid = id
        self.tblTimestampList.backgroundColor = .white
        self.reloadTimeline()
    }

    func removeRefreshControll() {
        if #available(iOS 10.0, *) {
            self.tblTimestampList.refreshControl = nil
        } else {
            self.refreshControl.removeFromSuperview()
        }
    }

    func refresh(with timeStamp: RMTimestamp) {
        if let index = self.getIndexPath(for: timeStamp) {
            self.tblTimestampList.reloadRows(at: [index], with: .none)
        }
    }

    func setupRefreshControl() {
        //        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.tintColor = APP_COLOR_THEME
        self.refreshControl.addTarget(self, action: #selector(self.reloadTimeline), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.tblTimestampList.refreshControl = self.refreshControl
        } else {
            self.tblTimestampList.addSubview(self.refreshControl)
        }
    }

    func setupTableView() {
        self.tblTimestampList.delegate = self
        self.tblTimestampList.dataSource = self
        self.tblTimestampList.emptyDataSetDelegate = self
        self.tblTimestampList.emptyDataSetSource = self
        self.tblTimestampList.register(UINib.init(nibName: "UserTimestampTblCell", bundle: nil), forCellReuseIdentifier: "UserTimestampTblCell")
        self.tblTimestampList.estimatedRowHeight = 200
        self.tblTimestampList.rowHeight = UITableViewAutomaticDimension
        self.tblTimestampList.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.setupRefreshControl()
    }

    func formatTimestamps(_ reload: Bool = true) {

        self.sortedTimestamps = []
        // 1 - extract dates
        var rawDateComponents: [DateComponents] = []
        for timestamp in self.timeStamps {
            let set: Set<Calendar.Component> = [ Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second  ]
            let comps = self.calendar.dateComponents(set, from: timestamp.time)
            rawDateComponents.append(comps)
        }

        var uniqueDateComponents: [DateComponents] = []
        var uniqueTimeintervals: [TimeInterval] = []
        for rawDateComponent in rawDateComponents {
            var startComps = rawDateComponent
            startComps.hour = 0
            startComps.minute = 0
            startComps.second = 0
            guard let startDateTimeinterval: TimeInterval = self.calendar.date(from: startComps)?.timeIntervalSinceReferenceDate else {
                continue
            }
            if uniqueTimeintervals.contains(startDateTimeinterval) == false {
                uniqueDateComponents.append(rawDateComponent)
                uniqueTimeintervals.append(startDateTimeinterval)
            }
        }

        // 2 -
        for comps in uniqueDateComponents {
            var timestampsForCurrentDate: [RMTimestamp] = []
            var startComps = comps
            startComps.hour = 0
            startComps.minute = 0
            startComps.second = 0
            guard let startDateTimeinterval: TimeInterval = self.calendar.date(from: startComps)?.timeIntervalSinceReferenceDate else {
                continue
            }

            var endComps = comps
            endComps.hour = 23
            endComps.minute = 59
            endComps.second = 59
            guard let endDateTimeinterval: TimeInterval = self.calendar.date(from: endComps)?.timeIntervalSinceReferenceDate else {
                continue
            }

            for timestamp in self.timeStamps {
                let timestampInterval: TimeInterval = timestamp.time.timeIntervalSinceReferenceDate
                if timestampInterval >= startDateTimeinterval, timestampInterval <= endDateTimeinterval {
                    timestampsForCurrentDate.append(timestamp)
                }
            }

            if let date = self.calendar.date(from: comps) {
                var timelineDisplayModel = TimestampDisplayModel()
                timelineDisplayModel.dateStartInterval = startDateTimeinterval
                timelineDisplayModel.dateEndInterval = endDateTimeinterval
                timelineDisplayModel.date = date

                timestampsForCurrentDate.sort { (obj1, obj2) -> Bool in
                    let date1 = obj1.time
                    let date2 = obj2.time
                    if date1 > date2 {
                        return true
                    }
                    return false
                }

                timelineDisplayModel.timestamps = timestampsForCurrentDate
                self.sortedTimestamps.append(timelineDisplayModel)
            }
        }

        self.sortedTimestamps.sort { (obj1, obj2) -> Bool in
            if let date1 = obj1.date,
                let date2 = obj2.date {
                if date1 > date2 {
                    return true
                }
            }
            return false
        }
//        if reload {
//            DispatchQueue.main.async {
//                self.tblTimestampList.reloadData()
//            }
//        }
    }

    @objc func reloadTimeline() {
        self.delegate.pullToRefresh()
        self.refreshControl.endRefreshing()
        self.loadTimeline(at: 0)
    }

    func loadTimeline(at page: Int) {
        if self.isLoadingData ||
            self.currentRequest != nil {
//            self.currentRequest?.cancel()
//            self.isLoadingData = false
            return;
        }
        if  page != 0 &&
            self.paging.totalPages <= page {
            self.delegate.dataLoadedInTableView(false)
            self.isLoadingData = false
            return;
        }
        self.isLoadingData = true
        self.currentRequest = APIManager.shared.getTimeline(for: self.userid, at: page) { (timestampList, error, pagination) in
            self.isLoadingData = false
            if let error = error {
                self.showAlert?("Error".localized, error.localizedDescription)
                self.delegate.dataLoadedInTableView(false)
            } else {
                if let page = pagination {
                    let count = self.timeStamps.count
                    if page.currentPage == 0 {
                        self.timeStamps = timestampList
                    } else {
                        let new = timestampList.filter({ (post) -> Bool in
                            return !(self.timeStamps.contains(post))
                        })
                        self.timeStamps.append(contentsOf: new)
                    }
                    self.paging = page
                    self.formatTimestamps(true)
                    self.tblTimestampList.reloadData()
                    if page.currentPage > 0
                    {
                        self.delegate.dataLoadedInTableView(false)
                    }
                    else
                    {
                        self.delegate.dataLoadedInTableView((count != self.timeStamps.count))
                    }
//
                } else {
                    self.formatTimestamps(true)
                    self.tblTimestampList.reloadData()
                    self.delegate.dataLoadedInTableView(false)
                }
            }
            self.currentRequest = nil
        }
        self.delegate.dataLoadedInTableView(false)
    }

    func getSectionHeaderText(for section: Int) -> String {
        let displayModel = self.sortedTimestamps[section]
        let set: Set<Calendar.Component> = [ Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday]
        let comps = self.calendar.dateComponents(set, from: displayModel.date)
        if displayModel.date.compare(.isToday) {
            return ""
        } else {
            let weekDay = displayModel.date.toString(format: .custom("E"), locale: Locale.init(identifier: "ja_JP"))
            if let day = comps.day,
                let month = comps.month {
                return " \(month)/\(day) (\(weekDay))  "
            }
            return ""
        }
    }

    func getTimestamp(for indexPath: IndexPath) -> RMTimestamp? {
        let displayModel = self.sortedTimestamps[indexPath.section]
        let timestamp = displayModel.timestamps[indexPath.row]
        return timestamp
    }

    func getIndexPath(for timeStamp: RMTimestamp) -> IndexPath? {
        for (sectionIndex, displayModel) in self.sortedTimestamps.enumerated() {
            let timeinterval = displayModel.date.timeIntervalSinceReferenceDate
            if timeinterval > displayModel.dateStartInterval,
                timeinterval < displayModel.dateEndInterval {
                if let index = displayModel.timestamps.index(of: timeStamp) {
                    return IndexPath.init(row: index, section: sectionIndex)
                }
            }
        }

        return nil
    }

    func delete(timeStamp: RMTimestamp) {
        if let index = self.getIndexPath(for: timeStamp) {
            if let timestampIndex = self.timeStamps.index(of: timeStamp) {
                self.timeStamps.remove(at: timestampIndex)
            }
            if self.timeStamps.count != 0 {
                self.formatTimestamps(false)
                if self.tblTimestampList.numberOfRows(inSection: index.section) > index.row {
                    let numberOfRows = self.tblTimestampList.numberOfRows(inSection: index.section)
                    self.tblTimestampList.beginUpdates()
                    if numberOfRows == 1 {
                        self.tblTimestampList.deleteSections(IndexSet.init(integer: index.section), with: .automatic)
                    }
                    else {
                         self.tblTimestampList.deleteRows(at: [index], with: .automatic)
                    }
                    self.tblTimestampList.endUpdates()
                } else {
                    self.tblTimestampList.reloadData()
                }
            } else {
                self.formatTimestamps(true)
                self.tblTimestampList.reloadData()
            }
        }
    }

}

extension UserTimelineAdapter: UserTimestampTblCellDelegate {
    func like(timestamp: RMTimestamp?) {
        if let timeStamp = timestamp {
            timeStamp.updateLikeStatus {
                self.refresh(with: timeStamp)
            }
        }
    }

    func showUserProfile(timestamp: RMTimestamp?) {
        self.delegate.showUserProfile(timestamp: timestamp)
    }

    func comment(timestamp: RMTimestamp?) {
        self.delegate.comment(timestamp: timestamp)
    }

    func showOption(timestamp: RMTimestamp?) {
        self.delegate.showOption(timestamp: timestamp)
    }

    func showLocation(timestamp: RMTimestamp?) {
        self.delegate.showLocation(timestamp: timestamp)
    }

}

extension UserTimelineAdapter: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sortedTimestamps.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let displayModel = self.sortedTimestamps[section]
        return displayModel.timestamps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserTimestampTblCell", for: indexPath) as? UserTimestampTblCell {
            if let timeStamp = self.getTimestamp(for: indexPath) {
                cell.delegate = self
                cell.setup(for: timeStamp)
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate.didSelect(timeStamp: self.getTimestamp(for: indexPath))
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //        if section == 0 {
        //            return nil
        //        }
        var frame = tableView.frame
        frame.size.height = 64
        let headerView = UIView.init(frame: frame)
        headerView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        headerView.frame = frame
        headerView.clipsToBounds = true

        let lblTime = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 64, height: 20))
        lblTime.text = self.getSectionHeaderText(for: section)
        lblTime.textAlignment = .center
        lblTime.font = HiraginoSansW3(withSize: 10) //PingFangSCRegular(withSize: 10)
        lblTime.backgroundColor = UIColor.init(red: 13/255, green: 63/255, blue: 158/255, alpha: 25/100)
        lblTime.textColor = APP_COLOR_THEME
        lblTime.layer.cornerRadius = 10
        lblTime.clipsToBounds = true
        headerView.addSubview(lblTime)
        if lblTime.frame.width < 54 {
            lblTime.frame.size.width = 64
        }
        var lblPosition = lblTime.frame.origin
        lblPosition.x = headerView.center.x - (lblTime.frame.width / 2)
        //        lblPosition.y = headerView.center.y - (lblTime.frame.height / 2)
        lblPosition.y = 12
        lblTime.frame.origin = lblPosition

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = self.getSectionHeaderText(for: section)
        if header == "" {
            return 0.001
        }
        return 64
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= 6.0,
            !self.isLoadingData {
            self.loadTimeline(at: self.paging.currentPage + 1)
        }
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString.init(string: "Let's follow the members of the company!".localized,
                                            attributes: [NSAttributedStringKey.font: HiraginoSansW3(withSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return title
    }

}
