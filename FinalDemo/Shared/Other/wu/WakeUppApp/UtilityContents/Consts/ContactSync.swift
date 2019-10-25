
//
//  ContactSync.swift
//  WakeUppApp
//
//  Created by Admin on 18/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI

import SwiftyJSON

let specialChar : String = " " //In this line is not space value, but it special char of space.

//PV
protocol ContactSyncDelegate {
    func didStart_ContactSyncProcess()
    func didFinish_ContactSyncProcess()
}

class ContactSync
{
    //MARK:- Variable
    static let shared = ContactSync()
    var delegate : ContactSyncDelegate? //PV
    
    var contactStore = CNContactStore()
    var arrResponsePhone = NSMutableArray()
    var arrDeviceContactInfo = [StructDeviceContactInfo]() 
    
    //MARK:-
    func performSync(){
        self.delegate?.didStart_ContactSyncProcess() //PV
        requestAccessToContacts { (success) in
            if success {
                self.retrieveContacts({ (success) in
                    if (self.arrResponsePhone.count) > 0 { self.api_syncContact(arr: self.arrResponsePhone) }
                    else {
                        //print("No contacts in your directory")
                    }
                    //self.delegate?.didFinish_ContactSyncProcess() //PV
                })
            }
            else {
                self.delegate?.didFinish_ContactSyncProcess() //PV
                /*DispatchQueue.main.async {
                    self.requestAccess(completionHandler: { (success) in
                        self.performSync()
                    })
                }*/
                
                DispatchQueue.main.async {
                    self.requestAccess(completionHandler: { (success) in
                        //--->
                    })
                }
            }
        }
    }
    
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void)
    {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus
        {
        case .authorized:
            completion(true)
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler:
                { (accessGranted, error) -> Void in
                    completion(accessGranted)
            })
        default:
            //completion(false)
            DispatchQueue.main.async {
                self.requestAccess(completionHandler: { (success) in
                    self.performSync()
                })
            }
        }
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        //let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
        
        case .denied:
            showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            contactStore.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        }
    }
    
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "'\(APPNAME)' requires access to Contacts to proceed.\n Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            completionHandler(false)
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        /*alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })*/
        
        //present(alert, animated: true)
        APP_DELEGATE.appNavigation?.viewControllers[0].present(alert, animated: true, completion: nil)
    }
    
    func retrieveContacts(_ completion: (_ success: Bool) -> Void)
    {
        arrResponsePhone = NSMutableArray();
        self.arrDeviceContactInfo.removeAll() 
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock:
            { (cnContact, error) in
                
                if cnContact.phoneNumbers.count > 1
                {
                      for phoneNumber in cnContact.phoneNumbers
                      {
                            if let contact = ContactEntry.init(cnContact: cnContact, false, phoneNumber)
                            {
                                if let phone = contact.phone
                                {
                                    if phone.count < 15 || phone.count > 6
                                    {
                                        self.arrResponsePhone.add(contact.pipedPhone ?? "")
                                        self.AddContact_In_DeviceContactInfo(contact: contact)
                                    }
                                }
                            }
                        }
                }
                else
                {
                    if cnContact.phoneNumbers.count > 0
                    {
                        if let contact = ContactEntry.init(cnContact: cnContact, false, cnContact.phoneNumbers.first!)
                        {
                            if let phone = contact.phone
                            {
                                if phone.count < 15 || phone.count > 6 {
                                    self.arrResponsePhone.add(contact.pipedPhone ?? "")
                                    self.AddContact_In_DeviceContactInfo(contact: contact)
                                }
                            }
                        }
                    }
                }
            })
            completion(true)
        }
        catch {
            completion(false)
        }
    }
    
    //MARK:- API
    func api_syncContact(arr:NSMutableArray)
    {
        var nwarr = [String]()
        for name in arr
        {
            if name is String
            {
                nwarr.append(name as! String)
            }
        }
        
        let parameter:NSDictionary = [
            "service": "contact_sync",
            "request": [ "contact_list":nwarr.joined(separator: ",")],
            "auth": getAuthForService()
        ]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APISyncContacts, parameters: parameter, keyname: "", message: "", showLoader: true,responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.delegate?.didFinish_ContactSyncProcess() //PV
            if error != nil { print(error?.localizedDescription ?? "") }
            else {
                /* if Int(apistatus) == 0 { //print("api_syncContact : statusmessage : \(statusmessage)") }
                else { //print("api_syncContact : statusmessage : \(statusmessage)") } */
                
                //print("api_syncContact : statusmessage : \(statusmessage)")
                self.getAppUsers()
            }
        })
    }
    
    func getAppUsers() {
        let dic = [ "user_id":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) ] as [String : Any]
        //print("socket API - Get_AppUsers dic.: \(dic)")
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Get_AppUsers",dic).timingOut(after: 30) {data in
            let data = data as Array
            if(data.count > 0) {
                //print(data[0])
                if data[0] is String { return }
                
                var arrAppUsers = [User]()
                let arrResponse = data[0] as! NSArray
                //print("socket API - Get_AppUsers Response: \(arrResponse)")
                
                for dicData in arrResponse {
                    let jsonDic = dicData as! NSDictionary
                    let user = User.init(json: JSON(jsonDic))
                    if user.userId != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) // pu added 30oct
                    {
                        user.imagePath = "\(Get_Profile_Pic_URL)\(user.image!)"
                        user.userId = "\(jsonDic.object(forKey: "user_id")!)"
                        user.isVerify = "\(jsonDic.object(forKey: "is_verify")!)"
                        user.platform = "\(jsonDic.object(forKey: "platform")!)"
                        user.isOnline = "\(jsonDic.object(forKey: "is_online")!)"
                        user.status = "\(jsonDic.object(forKey: "status")!)"
                        if user.phoneno! == UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
                        {
                           
                        }
                        else
                        {
                            arrAppUsers.append(user)
                        }
                    }
                }
                let arr:NSMutableArray = NSMutableArray.init(array: arrAppUsers)
                UserDefaultManager.setCustomObjToUserDefaults(CustomeObj: arr as AnyObject, key: kAppUsers)
                postNotification(with: NC_UserListRefresh)
            }
        }
    }
    
    //MARK:-
    func isUserInContacts(chatUser:StructChat)->Bool{
        let userContact = "\(chatUser.kcountrycode)|\(chatUser.kphonenumber)"
        if self.arrResponsePhone.contains(userContact){
            return true
        }
        return false
    }
    
    func get_WithoutFormat_PhoneNo(phoneNo : String) -> String {
        
        if (phoneNo.count == 0) { return "" }
        
        let arrReplaceChar : [String] = [specialChar," ","(",")","-","+"]
        var strPhoneNo : String = phoneNo
        //print("B-strPhoneNo : \(strPhoneNo)")
        for strObj : String in arrReplaceChar {
            strPhoneNo = strPhoneNo.replacingOccurrences(of: strObj, with: "")
        }
        strPhoneNo = strPhoneNo.replacingOccurrences(of: specialChar, with: "") //In this line not replace space value, but it special char replace
        //print("A-strPhoneNo : \(strPhoneNo)")
        
        return strPhoneNo
    }
    
    func AddContact_In_DeviceContactInfo(contact:ContactEntry) -> Void {
        let serialQueue = DispatchQueue(label: "myqueue")
        serialQueue.sync {
            let arrContactNo : [String] = contact.pipedPhone!.components(separatedBy: "|")
            let strCountryCode : String = arrContactNo.first!
            let strPhoneNo : String = arrContactNo.last!
            
            let objContactInfo : StructDeviceContactInfo = StructDeviceContactInfo.init(Name: contact.name, CountryCode: strCountryCode, PhoneNo: strPhoneNo)
//                if self.arrDeviceContactInfo.count > 0
//                {
////                    if self.arrDeviceContactInfo.contains(where: { $0.PhoneNo == objContactInfo.PhoneNo }) {
////                    } else {
////                         self.arrDeviceContactInfo.append(objContactInfo)
////                    }
//                    if (self.arrDeviceContactInfo.enumerated().first(where: {$0.element.PhoneNo == objContactInfo.PhoneNo}) != nil){
//                    }
//                    else {
//                         self.arrDeviceContactInfo.append(objContactInfo)
//                    }
//                }
//                else
//                {
                   self.arrDeviceContactInfo.append(objContactInfo)
//                }
        }
    }
    func isUserInContacts(countryCode:String, phoneNo:String) -> StructDeviceContactInfo {
        //print("contact no. : \(countryCode) \(phoneNo)")
        
        //Replace Empty space.
        var strFullPhoneNo : String = "\(countryCode)\(phoneNo)"
        strFullPhoneNo = self.get_WithoutFormat_PhoneNo(phoneNo: strFullPhoneNo)
        //print("strFullPhoneNo. : \(strFullPhoneNo)")
        
        //Sometime not working
        //if self.arrDeviceContactInfo.contains(where: {$0.PhoneNo == strPhoneNo || $0.CountryCode_PhoneNo == strPhoneNo}) { //This return only TRUE & FALSE
        
        //if let objContactInfo:StructDeviceContactInfo = self.arrDeviceContactInfo.first(where: {$0.PhoneNo == phoneNo || $0.CountryCode == countryCode || $0.CountryCode_PhoneNo == strFullPhoneNo}) {
        if let objContactInfo:StructDeviceContactInfo = self.arrDeviceContactInfo.first(where: {$0.PhoneNo == phoneNo && $0.CountryCode == countryCode && $0.CountryCode_PhoneNo == strFullPhoneNo}) {
            //print("objContactInfo : \(objContactInfo.CountryCode!) | \(objContactInfo.PhoneNo!) | \(objContactInfo.Name!)")
            return objContactInfo
        }
        return StructDeviceContactInfo.init(dictionary: [:])
    }
    
    func get_ContactObject(strCountryCode: String, strPhoneNo: String) -> CNContact {
        //let strFullPhoneNo : String = "+\(strCountryCode)\(strPhoneNo)"
        let strFullPhoneNo : String = "+\(strCountryCode) \(strPhoneNo)"
        let contact = CNMutableContact()
        let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue : strFullPhoneNo))
        contact.phoneNumbers = [homePhone]
        return contact.mutableCopy() as! CNContact
    }
}

