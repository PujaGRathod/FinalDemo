//
//  OfficeProfileAdapter.swift
//  remone
//
//  Created by Arjav Lad on 10/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol OfficeProfileAdapterDelegate {
    func openMaps()
    func showMoreUsers()
    func reportOffice()
    func showUserProfile(for id: String)
    func showLoader(_ show: Bool)
    func showAlertForFollowRequest(yes: @escaping ()->(), no: ()->())
    func showAlertForStopFollowRequest(yes: @escaping ()->(), no: ()->())
    func openURL(_ url: URL?)
}


class OfficeProfileAdapter: NSObject, OfficeUsersTblCellDelegate {

    private let tableView: UITableView
    fileprivate let office: RMOffice
    let delegate: OfficeProfileAdapterDelegate

    init(with table: UITableView, delegate: OfficeProfileAdapterDelegate, with office: RMOffice) {
        self.tableView = table
        self.delegate = delegate
        self.office = office
        super.init()
        self.setupTableView()
    }

    func setupTableView() {
        self.tableView.register(UINib.init(nibName: "EquipmentTblCell", bundle: nil), forCellReuseIdentifier: "EquipmentTblCell")
        self.tableView.register(UINib.init(nibName: "OfficeUsersTblCell", bundle: nil), forCellReuseIdentifier: "OfficeUsersTblCell")
        self.tableView.register(UINib.init(nibName: "OfficeInfoTblCell", bundle: nil), forCellReuseIdentifier: "OfficeInfoTblCell")
        self.tableView.register(UINib.init(nibName: "OfficeLocationMapTblCell", bundle: nil), forCellReuseIdentifier: "OfficeLocationMapTblCell")
        self.tableView.register(UINib.init(nibName: "OfficeReportTblCell", bundle: nil), forCellReuseIdentifier: "OfficeReportTblCell")
        self.tableView.register(UINib.init(nibName: "OfficeProfileNameSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "OfficeProfileNameSectionHeaderView")
        self.tableView.register(UINib.init(nibName: "OfficeProfileSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "OfficeProfileSectionHeaderView")
        self.tableView.estimatedSectionHeaderHeight = 36
        //        self.tableView.estimatedRowHeight = 36
        self.tableView.backgroundColor = .white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    func showMoreUsers() {
        self.delegate.showMoreUsers()
    }

    func followUser(at index: Int?) {
        if let index = index {
            let officeUser: RMUser = self.office.users[index]
            func sendRequest() {
                self.delegate.showLoader(true)
                officeUser.followUnfollowUser { (success) in
                    self.delegate.showLoader(false)
                    if success {
                        officeUser.followStatus = officeUser.followStatus.getNewStatus
                        self.office.users[index] = officeUser
                    }
                    self.tableView.reloadData()
                }
            }
            if officeUser.followStatus == .requested {
                self.delegate.showAlertForFollowRequest(yes: {
                    sendRequest()
                }, no: {

                })
            }
            else if officeUser.followStatus == .following
            {
                self.delegate.showAlertForStopFollowRequest(yes: {
                    sendRequest()
                }, no: {
                    
                })
            }
            
            else {
                sendRequest()
            }
        }
    }

    func openProfile(at index: Int?) {
        if let index = index {
            if index < self.office.users.count {
                let user = self.office.users[index]
                self.delegate.showUserProfile(for: user.id)
            }

        }

    }

    func openMaps() {
        self.delegate.openMaps()
    }

    @objc func openOfficeURL(_ sender: UIButton) {
        self.delegate.openURL(self.office.url)
    }

   @objc func reportOffice(_ sender: UIButton) {
        self.delegate.reportOffice()
    }
}

extension OfficeProfileAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        // Company Info
        case 0:
            return 4

        // Users in company
        case 1:
            if self.office.users.count > 3 {
                return 4
            } else if self.office.users.count == 0 {
                return 1
            } else {
                return self.office.users.count
            }
        // Equipments
        case 2:
            return self.office.equipments.count

        // Seating Type
        case 3:
            return 0

        // Map Location
        case 4:
            return 1

        // Report
        case 5:
            return 1

        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {

        // Company Info
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfficeInfoTblCell") as! OfficeInfoTblCell
            switch indexPath.row {
            case 0:
                if self.office.timings == "" {
                    cell.setInfo(with: #imageLiteral(resourceName: "time"), text: "Closed".localized)
                } else {
                    cell.setInfo(with: #imageLiteral(resourceName: "time"), text: self.office.timings)
                }

            case 1:
                if self.office.location.address == "" {
                    cell.setInfo(with: #imageLiteral(resourceName: "iconLocationPin"), text: " - ")
                } else {
                    cell.setInfo(with: #imageLiteral(resourceName: "iconLocationPin"), text: self.office.location.address)
                }

            case 2:
                if self.office.nearestStation == "" {
                    cell.setInfo(with: #imageLiteral(resourceName: "icon_NearestSattion"), text: " - ")
                } else {
                cell.setInfo(with: #imageLiteral(resourceName: "icon_NearestSattion"), text: self.office.nearestStation)
                }

            case 3:
                cell.addEquipments(self.office.equipments)

            default:
                break
            }
            return cell

        // Users in company
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfficeUsersTblCell") as! OfficeUsersTblCell
            if self.office.users.count > 3 &&
                indexPath.row == 3 {
                cell.viewProfile.isHidden = true
                cell.btnShowMore.isHidden = false
            
            } else if self.office.users.count == 0 {
                cell.lblNoUsers.isHidden = false
                cell.viewProfile.isHidden = true
                cell.btnShowMore.isHidden = true
            } else {
                cell.viewProfile.isHidden = false
                cell.btnShowMore.isHidden = true
                cell.loadProfile(for: self.office.users[indexPath.row])
                cell.index = indexPath.row
            }
            cell.delegate = self
            return cell

        // Equipments
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EquipmentTblCell") as! EquipmentTblCell
            let equipment = self.office.equipments[indexPath.row]
            cell.imageViewEquipment.sd_setImage(with: equipment.imageURL, completed: { (image, _, _, _) in
                cell.imageViewEquipment.image = image
            })
            cell.lblEquipmentName.text = equipment.name
            cell.lblEquipmentDesc.text = "\(equipment.value ?? "") \(equipment.unit ?? "")"
            cell.viewSep.isHidden = (indexPath.row == (self.office.equipments.count - 1))
            return cell

        // Seating Type
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EquipmentTblCell") as! EquipmentTblCell
//            cell.imageViewEquipment.image = #imageLiteral(resourceName: "iconMeetingCopy")
            cell.imageViewEquipment.image = nil
//            cell.lblEquipmentName.text = "ブース席"
            cell.lblEquipmentName.text = ""
            cell.lblEquipmentDesc.attributedText = NSAttributedString.init(string: "\(self.office.numberOfSeats)席",
                attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1),
                             NSAttributedStringKey.font: HiraginoSansW5(withSize: 14)])
            cell.viewSep.isHidden = true
            return cell

        // Map Location
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfficeLocationMapTblCell") as! OfficeLocationMapTblCell
            cell.loadMapView(for: self.office.location)
            cell.openMaps = {
                self.openMaps()
            }
            return cell
            
        // Report
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfficeReportTblCell") as! OfficeReportTblCell
            cell.btnReport.addTarget(self, action: #selector(self.reportOffice(_:)), for: UIControlEvents.touchUpInside)
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Company Info
        if section == 0,
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OfficeProfileNameSectionHeaderView") as? OfficeProfileNameSectionHeaderView {

            if let _ = self.office.url {
                headerView.lblText.text = nil
                headerView.lblText.attributedText = NSAttributedString.init(string: self.office.name,
                                                                            attributes: [
                                                                                NSAttributedStringKey.font: headerView.lblText.font,
                                                                                NSAttributedStringKey.foregroundColor: APP_COLOR_THEME,
                                                                                NSAttributedStringKey.underlineColor: APP_COLOR_THEME,
                                                                                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            } else {
                headerView.lblText.attributedText = nil
                headerView.lblText.text = self.office.name
            }
            headerView.showPartnerShop(self.office.isPartnerShop)
            headerView.btnOfficeUrl.addTarget(self, action: #selector(self.openOfficeURL(_:)), for: .touchUpInside)
            return headerView

        } else if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OfficeProfileSectionHeaderView") as? OfficeProfileSectionHeaderView {
            switch section {
            // Users in company
            case 1:
                headerView.lblText.text = "このオフィスにいる人"

            // Equipments
            case 2:
                headerView.lblText.text = "設備"

            // Seating Type
            case 3:
                if self.office.numberOfSeats == "0" ||
                        self.office.numberOfSeats == "" {
                        headerView.lblText.text = ""
                        headerView.lblDetails.text = ""
                        return nil
                } else {
                    headerView.lblText.text = "座席数"
                    headerView.lblDetails.attributedText = NSAttributedString.init(string: "\(self.office.numberOfSeats)席",
                        attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1),
                                     NSAttributedStringKey.font: HiraginoSansW5(withSize: 14)])
                    return headerView
                }

            // Map Location
            case 4:
                headerView.lblText.text = "所在地"

            // Report
            case 5:
                headerView.lblText.text = ""

            default:
                return nil
            }
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        // Company Info
        case 0:
            switch indexPath.row {
            case 0:
                let width = (tableView.frame.size.width - 57)
                let text = self.office.timings
                let height = text.height(withConstrainedWidth: width, font: HiraginoSansW3(withSize: 12))
                return height + 12

            case 1:
                let width = (tableView.frame.size.width - 57)
                let text = self.office.location.address
                let height = text.height(withConstrainedWidth: width, font: HiraginoSansW3(withSize: 12))
                return height + 12

            case 2:
                let width = (tableView.frame.size.width - 57)
                let text = self.office.nearestStation
                let height = text.height(withConstrainedWidth: width, font: HiraginoSansW3(withSize: 12))
                return height + 12

            case 3:
                return 46

            default:
                return 0
            }

        // Users in company
        case 1:
            return 56

        // Equipments
        case 2:
            return 42

        // Seating Type
        case 3:
            return 0

        // Map Location
        case 4:
            let width = (tableView.frame.size.width - 40)
            let text = self.office.location.address
            let height = text.height(withConstrainedWidth: width, font: HiraginoSansW3(withSize: 14))
            return height + 256

        // Report
        case 5:
            return 114

        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Users in company
        if indexPath.section == 1 {
            if self.office.users.count > 3 &&
                indexPath.row == 3 {
                let user = self.office.users[indexPath.row]
                self.delegate.showUserProfile(for: user.id)
            } else if self.office.users.count == 0 {

            } else {

            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 5 {
            return 32
        } else if section == 0 {
            let width = (tableView.frame.size.width - 93)
            let text = self.office.name
            let height = text.height(withConstrainedWidth: width, font: HiraginoSansW5(withSize: 20))
            return height + 22
        } else if section == 3 {
            if self.office.numberOfSeats == "0" ||
                self.office.numberOfSeats == "" {
                return 2
            } else {
                return 52
            }
        }
        return 52
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 5 {
            return 0.001
        } else if section == 3 {
            if self.office.numberOfSeats == "0" ||
                self.office.numberOfSeats == "" {
                return 0.0001
            } else {
                return 32
            }
        }
        return 32
    }

}
