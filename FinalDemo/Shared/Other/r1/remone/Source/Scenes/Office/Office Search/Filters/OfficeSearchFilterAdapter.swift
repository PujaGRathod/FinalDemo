//
//  OfficeSearchFilterAdapter.swift
//  remone
//
//  Created by Arjav Lad on 10/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol OfficeSearchFilterAdapterDelegate {
    func showSelectWeekDays()
    func showSearchHistory()
}

class OfficeSearchFilterAdapter: NSObject {

    private let tblFilterList: UITableView
    private let delegate: OfficeSearchFilterAdapterDelegate

    private let hours = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24" ]
    private let minutes = ["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]

    private let openingTimePicker = UIPickerView.init()
    private let closingTimePicker = UIPickerView.init()

    private let filter: OfficeSearchFilter

    init(with tableView: UITableView, withDelegate: OfficeSearchFilterAdapterDelegate, withFilter: OfficeSearchFilter) {
        self.tblFilterList = tableView
        self.delegate = withDelegate
        self.filter = withFilter
        super.init()
        self.setupTableView()
        self.setupPickers()
        self.setup(with: self.filter)
    }

    func updateSelectedDays() {
        self.tblFilterList.reloadData()
    }
    
    private func setupTableView() {
        self.tblFilterList.delegate = self
        self.tblFilterList.dataSource = self

        self.tblFilterList.register(UINib(nibName: "FilterHeaderCell", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "FilterHeaderCell")
        self.tblFilterList.register(UINib.init(nibName: "FilterSearchHistoryCell", bundle: nil), forCellReuseIdentifier: "FilterSearchHistoryCell")
        self.tblFilterList.register(UINib.init(nibName: "FilterShowPartnerCell", bundle: nil), forCellReuseIdentifier: "FilterShowPartnerCell")
        self.tblFilterList.register(UINib.init(nibName: "FilterSpecifyBussinesDayCell", bundle: nil), forCellReuseIdentifier: "FilterSpecifyBussinesDayCell")
        self.tblFilterList.register(UINib.init(nibName: "FilterSpecifyBussinesTimeCell", bundle: nil), forCellReuseIdentifier: "FilterSpecifyBussinesTimeCell")
        self.tblFilterList.register(UINib.init(nibName: "FilterSelectionCell", bundle: nil), forCellReuseIdentifier: "FilterSelectionCell")
    }

    func setup(with filter: OfficeSearchFilter) {
        self.setTimeText()
        self.tblFilterList.reloadData()
    }

    func resignfirstResponder() {
        let openingTimeIndexPath = IndexPath.init(row: 1, section: 2)
        if let openingTimeCell = self.tblFilterList.cellForRow(at: openingTimeIndexPath) as? FilterSpecifyBussinesTimeCell {
            openingTimeCell.txtTime.resignFirstResponder()
        }

        let closingTimeIndexPath = IndexPath.init(row: 2, section: 2)
        if let closingTimeCell = self.tblFilterList.cellForRow(at: closingTimeIndexPath) as? FilterSpecifyBussinesTimeCell {
            closingTimeCell.txtTime.resignFirstResponder()
        }
    }

    private func getTimeComponents(from text: String) -> (String?, String?) {
        if text.trimString() != "" {
            let comps = text.components(separatedBy: ":")
            if comps.count == 2 {
                return (comps[0].trimString(),comps[1].trimString())
            }
        }
        return (nil, nil)
    }

    private func setupPickers() {
        self.openingTimePicker.dataSource = self
        self.openingTimePicker.delegate = self
        self.closingTimePicker.dataSource = self
        self.closingTimePicker.delegate = self
        self.openingTimePicker.tintColor = APP_COLOR_THEME
        self.closingTimePicker.tintColor = APP_COLOR_THEME
        self.openingTimePicker.reloadAllComponents()
        self.closingTimePicker.reloadAllComponents()

        self.openingTimePicker.backgroundColor = .white
        self.closingTimePicker.backgroundColor = .white

        self.openingTimePicker.selectRow(0, inComponent: 0, animated: true)
        self.closingTimePicker.selectRow(0, inComponent: 0, animated: true)
    }

    private func setTimeText() {
        let indexesOpeningTime = self.getIndexesForTime(self.filter.openingTime)
        self.openingTimePicker.selectRow(indexesOpeningTime.0, inComponent: 0, animated: true)
        self.openingTimePicker.selectRow(indexesOpeningTime.1, inComponent: 1, animated: true)
        self.filter.openingTime = "\(self.hours[indexesOpeningTime.0]):\(self.minutes[indexesOpeningTime.1])"

        let indexesClosingTime = self.getIndexesForTime(self.filter.closingTime)
        self.closingTimePicker.selectRow(indexesClosingTime.0, inComponent: 0, animated: true)
        self.closingTimePicker.selectRow(indexesClosingTime.1, inComponent: 1, animated: true)
        self.filter.closingTime = "\(self.hours[indexesClosingTime.0]):\(self.minutes[indexesClosingTime.1])"

        self.reloadTimeCells()
    }

    private func getIndexesForTime(_ timeText: String) -> (Int, Int) {
        if timeText.trimString() == "" {
            return (0, 0)
        }
        let comps = self.getTimeComponents(from: timeText)
        var indexHour: Int = 0
        var indexMinute: Int = 0
        if let hour = comps.0 {
            indexHour = self.hours.index(of: hour) ?? 0
        }
        if let minute = comps.1 {
            indexMinute = self.minutes.index(of: minute) ?? 0
        }
        return (indexHour, indexMinute)
    }

    private func reloadTimeCells() {
        let openingTimeIndexPath = IndexPath.init(row: 1, section: 2)
        if let openingTimeCell = self.tblFilterList.cellForRow(at: openingTimeIndexPath) as? FilterSpecifyBussinesTimeCell {
            openingTimeCell.txtTime.text = self.filter.openingTime
            openingTimeCell.lblTitle.text = "営業開始時間"
        }

        let closingTimeIndexPath = IndexPath.init(row: 2, section: 2)
        if let closingTimeCell = self.tblFilterList.cellForRow(at: closingTimeIndexPath) as? FilterSpecifyBussinesTimeCell {
            closingTimeCell.txtTime.text = self.filter.closingTime
            closingTimeCell.lblTitle.text = "営業終了時間"
        }
    }

    private func updateTimeText() {

        let openingHourIndex = self.openingTimePicker.selectedRow(inComponent: 0)
        let openingMinuteIndex = self.openingTimePicker.selectedRow(inComponent: 1)
        self.filter.openingTime = "\(self.hours[openingHourIndex]):\(self.minutes[openingMinuteIndex])"

        let closingHourIndex = self.closingTimePicker.selectedRow(inComponent: 0)
        let closingMinuteIndex = self.closingTimePicker.selectedRow(inComponent: 1)
        self.filter.closingTime = "\(self.hours[closingHourIndex]):\(self.minutes[closingMinuteIndex])"

        self.reloadTimeCells()
    }

    private func selectEquipment(at index: Int) {
        let equipment = self.filter.equipments[index]
        equipment.isSelected = !equipment.isSelected
        self.filter.equipments[index] = equipment
    }

    private func selectSeatingType(at index: Int) {
        let seatingType = self.filter.seatingTypes[index]
        seatingType.isSelected = !seatingType.isSelected
        self.filter.seatingTypes[index] = seatingType
    }

}

extension OfficeSearchFilterAdapter: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.updateTimeText()
    }
}

extension OfficeSearchFilterAdapter: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.hours.count
        }
        return self.minutes.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        if component == 0 {
            title = self.hours[row]
        } else {
            title = self.minutes[row]
        }
        let text = NSAttributedString.init(string: title, attributes: [ NSAttributedStringKey.foregroundColor: APP_COLOR_THEME ])
        return text
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.updateTimeText()
    }
}

extension OfficeSearchFilterAdapter: UITableViewDataSource, UITableViewDelegate, FilterShowPartnerCellDelegate {

    func showPartner(_ show: Bool, at indexPath: IndexPath?) {
        self.filter.showOnlyPartnerStore = show
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        // Search Histoy
        case 0:
            return 1

        // Show only partner stores
        case 1:
            return 1

        // Business Day Selection
        case 2:
            return 3

//        // Seat Type
//        case 3:
//            return self.filter.seatingTypes.count

        // Office Equipments
        case 3:
            return self.filter.equipments.count

        default:
            return 0
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        // Search Histoy
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSearchHistoryCell", for: indexPath) as! FilterSearchHistoryCell
            return cell

        // Show only partner stores
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterShowPartnerCell", for: indexPath) as! FilterShowPartnerCell
            cell.showPartner.isOn = self.filter.showOnlyPartnerStore
            cell.delegate = self
            cell.indexpath = indexPath
            return cell

        // Business Day Selection
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSpecifyBussinesDayCell", for: indexPath) as! FilterSpecifyBussinesDayCell
                let selectedDays = self.filter.getSelectedBusinessDays.map({ (day) -> String in
                    return day.key.localized
                })
                if selectedDays.count > 0 {
                    cell.lblSelectedDays.text = selectedDays.joined(separator: ", ")
                } else {
                    cell.lblSelectedDays.text = ""
                }
                return cell

            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSpecifyBussinesTimeCell", for: indexPath) as! FilterSpecifyBussinesTimeCell
                cell.txtTime.inputView = self.openingTimePicker
                cell.txtTime.text = self.filter.openingTime
                cell.txtTime.delegate = self
                cell.lblTitle.text = "営業開始時間"

                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSpecifyBussinesTimeCell", for: indexPath) as! FilterSpecifyBussinesTimeCell
                cell.txtTime.inputView = self.closingTimePicker
                cell.txtTime.text = self.filter.closingTime
                cell.txtTime.delegate = self
                cell.lblTitle.text = "営業終了時間"

                return cell

            default:
                return UITableViewCell()
            }

//        // Seat Type
//        case 3:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSelectionCell", for: indexPath) as!FilterSelectionCell
//            let seatType = self.filter.seatingTypes[indexPath.row]
//            cell.setupData(seatType: seatType)
//            cell.isSelectedFilter(seatType.isSelected)
//            return cell

        // Office Equipments
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSelectionCell", for: indexPath) as!FilterSelectionCell
            let equipment = self.filter.equipments[indexPath.row]
            cell.setupData(officeEquipment: equipment)
            cell.isSelectedFilter(equipment.isSelected)

            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader  = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterHeaderCell")  as! FilterHeaderCell
        if section == 2 {
            viewHeader.setTitle(title: "Business day · hour".localized)
        } else if section == 3 {
//            viewHeader.setTitle(title: "Seat Type".localized)
//        } else if section == 4 {
            viewHeader.setTitle(title: "Office equipment".localized)
        } else {
            viewHeader.setTitle(title: "")
        }
        return viewHeader
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            self.delegate.showSearchHistory()

        case 1:
            break

        case 2:
            if indexPath.row == 0 {
                self.delegate.showSelectWeekDays()
            }

//        case 3:
//            self.selectSeatingType(at: indexPath.row)
//            self.tblFilterList.reloadRows(at: [indexPath], with: .none)

        case 3:
            self.selectEquipment(at: indexPath.row)
            self.tblFilterList.reloadRows(at: [indexPath], with: .none)

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0001

        case 1,2:
            return 24

        case 3:
            return 36

        default:
            return 0.0001
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

}
