//
//  ContactModel_Chat.swift
//  WakeUppApp
//
//  Created by PiyushVyas on 22/09/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

import Contacts
import ContactsUI

let k_Header : String = "kHeader"
let k_Cell : String = "kCell"
let k_Img : String = "kImg"
let k_Name : String = "kName"
let k_Type : String = "kType"
let k_Title : String = "kTitle"
let k_Subtitle : String = "kSubtitle"
let k_IsSelected : String = "kIsSelected"

//MARK:- View/Read Contact's time using method
func get_ContactArray(strMess : String) ->  NSArray {
    if strMess.count == 0 { return NSArray.init() }
    
    let data = convertStringToDictionary(str: strMess)
    //print("data : \(data)")
    if data == nil { return NSArray.init() }
    
    let arrContact : NSArray = data!["data"] as! NSArray
    return arrContact
}

func get_ContactName(strMess : String) ->  String {
    if strMess.count == 0 { return "Contact" }
    
    /*let data = convertStringToDictionary(str: strMess)
     //print("data : \(data)")
     if data == nil { return "Contact" }
     
     //let arrContact = data!["data"]
     //print("arrContact : \(arrContact)")
     
     let arrContact : NSArray = data!["data"] as! NSArray
     var arrMess : NSMutableArray = NSMutableArray.init()
     arrMess = arrContact.mutableCopy() as! NSMutableArray*/
    
    var arrMess : NSMutableArray = NSMutableArray.init()
    let strDecodeMess : String = strMess.base64Decoded!
    arrMess = get_ContactArray(strMess: strDecodeMess).mutableCopy() as! NSMutableArray
    
    if arrMess.count > 0 {
        let dicContact : NSDictionary = arrMess.firstObject as! NSDictionary
        var strName : String = dicContact.value(forKey: "vName") as! String
        
        if arrMess.count != 1 { strName = "\(strName) and \(arrMess.count - 1) other contact" }
        return strName
    }
    return "Contact"
}

func get_Contact_PhoneNoList(strMess : String) ->  [String] {
    if strMess.count == 0 { return [] }
    
    var arrMess : NSMutableArray = NSMutableArray.init()
    let strDecodeMess : String = strMess.base64Decoded!
    arrMess = get_ContactArray(strMess: strDecodeMess).mutableCopy() as! NSMutableArray
    
    var arrPhoneNo : [String] = []
    if arrMess.count > 0 {
        for objContact in arrMess {
            let dicContact : [String : Any] = objContact as! [String : Any]
            let arrPhoneNoList : NSArray = dicContact["vPhoneNoList"] as! NSArray
            
            for objPhoneNo in arrPhoneNoList {
                let dicPhoneNo : [String : Any] = objPhoneNo as! [String : Any]
                let strPhonoNo : String = dicPhoneNo["vNumber"] as! String
                
                arrPhoneNo.append(strPhonoNo)
            }
        }
    }
    return arrPhoneNo
}

func get_Contact_Is_AppUser(strMess : String) ->  Bool {
    if strMess.count == 0 { return false }
return true
    
}

func get_ContactButtonTitle(strMess : String) ->  String {
    if strMess.count == 0 { return "View" }
    
    var arrMess : NSMutableArray = NSMutableArray.init()
    let strDecodeMess : String = strMess.base64Decoded!
    arrMess = get_ContactArray(strMess: strDecodeMess).mutableCopy() as! NSMutableArray
    
    if arrMess.count > 0 {
        if arrMess.count == 1 {
            for objContact in arrMess {
                let dicContact : [String : Any] = objContact as! [String : Any]
                let arrPhoneNo : NSArray = dicContact["vPhoneNoList"] as! NSArray
                if arrPhoneNo.count == 1 {
                    let dicPhoneNo : [String : Any] = arrPhoneNo[0] as! [String : Any]
                    let isAppUser : String = dicPhoneNo["isAppUser"] as? String ?? ""
                    if isAppUser == "1" { return "Message" }
                    else { return "Save Contact" }
                }
                else { return "View All" }
            }
            return "View"
        }
        else if arrMess.count > 1 { return "View All" }
    }
    return "View"
}

func get_ContactObj(strMess : String) ->  [CNContact] {
    var arrContact : NSMutableArray = NSMutableArray.init()
    //arrContact = get_ContactArray(strMess: strMess).mutableCopy() as! NSMutableArray
    
    let strMessDecode : String = strMess.base64Decoded!
    arrContact = get_ContactArray(strMess: strMessDecode).mutableCopy() as! NSMutableArray
    
    if arrContact.count > 0 {
        var sendContact : [CNContact] = []
        for objContact in arrContact {
            let dicContact : [String : Any] = objContact as! [String : Any]
            
            //Create object using ref. : https://developer.apple.com/documentation/contacts
            let contact = CNMutableContact()
            contact.givenName = dicContact["vName"] as! String
            
            //PhoneNo
            var arrPhoneNoList : [Any] = []
            let arrPhoneNo : NSArray = dicContact["vPhoneNoList"] as! NSArray
            for objPhoneNo in arrPhoneNo {
                let data : [String : Any] = objPhoneNo as! [String : Any]
                let strPhoneNo : String = data["vNumber"] as! String  ?? "" as! String
                let strType : String = data["vType"] as! String ?? "Other" as! String
                
                let obj : CNLabeledValue = CNLabeledValue(label: get_LabelValue(strLabel: strType), value: CNPhoneNumber.init(stringValue: strPhoneNo))
                arrPhoneNoList.append(obj)
            }
            contact.phoneNumbers = arrPhoneNoList as! [CNLabeledValue<CNPhoneNumber>]
            
            //EmailAddress
            var arrEmailList : [Any] = []
            let arrEmail : NSArray = dicContact["vEmailList"] as! NSArray
            for objEmail in arrEmail {
                let data : [String : Any] = objEmail as! [String : Any]
                let strEmail : String = data["vEmail"] as! String ?? "" as! String
                let strType : String = data["vType"] as! String ?? "Other" as! String
                
                let obj = CNLabeledValue(label: get_LabelValue(strLabel: strType), value: strEmail as NSString)
                
                arrEmailList.append(obj)
            }
            contact.emailAddresses = arrEmailList as! [CNLabeledValue<NSString>]
            
            //Address
            var arrAddressList : [Any] = []
            let arrAddress : NSArray = dicContact["vAddressList"] as! NSArray
            for objAddress in arrAddress {
                let data : [String : Any] = objAddress as! [String : Any]
                let strAddress : String = data["vAddress"] as! String ?? "" as! String
                let strType : String = data["vType"] as! String ?? "Other" as! String
                
                let obj = CNMutablePostalAddress()
                obj.street = strAddress
                obj.city = ""
                obj.state = ""
                obj.postalCode = ""
                let objAdd = CNLabeledValue(label: get_LabelValue(strLabel: strType), value: obj)
                arrAddressList.append(objAdd)
            }
            contact.postalAddresses = arrAddressList as! [CNLabeledValue<CNPostalAddress>]
            
            sendContact.append(contact.mutableCopy() as! CNContact)
        }
        return  sendContact
    }
    return [CNContact.init()]
}

func get_LabelValue(strLabel: String) -> String {
    
    switch strLabel.lowercased() {
    
    case "Home".lowercased():
        return CNLabelHome
        
    case "Work".lowercased():
        return CNLabelWork
        
    case "iPhone".lowercased():
        return CNLabelPhoneNumberiPhone
        
    case "Mobile".lowercased():
        return CNLabelPhoneNumberMobile
        
    case "Main".lowercased():
        return CNLabelPhoneNumberMain
        
    case "Home Fax".lowercased():
        return CNLabelPhoneNumberHomeFax
        
    case "Work Fax".lowercased():
        return CNLabelPhoneNumberWorkFax
        
    case "Other Fax".lowercased():
        return CNLabelPhoneNumberOtherFax
        
    case "Pager".lowercased():
        return CNLabelPhoneNumberPager
        
    case "Other".lowercased():
        return CNLabelOther
        
    default:
        return CNLabelOther
    }
}

//MARK:- Send Contact's time using method
func get_SendContactDataFormat_inSocket(arrContact : NSArray) -> NSArray {
    
    let arrUser_PhoneNo = CoreDBManager.sharedDatabase.getFriendIdList_PhoneNo()
    
    let arrContactData : NSMutableArray = NSMutableArray.init()
    for obj in arrContact {
        let dicContact : NSMutableDictionary = obj as! NSMutableDictionary
        
        let ContactInfo : NSMutableDictionary = NSMutableDictionary.init()
        
        //Photo
        let imgData = dicContact.value(forKey: k_Img)
        ContactInfo.setValue(imgData, forKey: "vPhoto")
        //dicContact.setValue("", forKey: "vPhoto")
        
        //Name
        let strName : String = dicContact.value(forKey: k_Name) as! String
        ContactInfo.setValue(strName, forKey: "vName")
        
        //isAppUser
        ContactInfo.setValue("0", forKey: "isAppUser")
        
        //Set object
        let arrPhoneNo : NSMutableArray = NSMutableArray.init()
        let arrEmail : NSMutableArray = NSMutableArray.init()
        let arrAddress : NSMutableArray = NSMutableArray.init()
        
        let arrContactOtherInfo : NSArray = dicContact.value(forKey: k_Cell) as! NSArray
        for objInfo in arrContactOtherInfo {
            let dicContactOtherInfo : NSMutableDictionary = objInfo as! NSMutableDictionary
            let strTitle : String = dicContactOtherInfo.value(forKey: k_Title) as! String
            let strSubTitle : String = dicContactOtherInfo.value(forKey: k_Subtitle) as! String
            var strType : String = dicContactOtherInfo.value(forKey: k_Type) as! String
            strType = strType.uppercased()
            let strIsSelected : String = dicContactOtherInfo.value(forKey: k_IsSelected) as! String
            
            if (strIsSelected == "1") {
                if strType == "phoneno".uppercased() {
                    let dicPhoneNo : NSMutableDictionary = NSMutableDictionary.init()
                    dicPhoneNo.setValue(strTitle, forKey: "vNumber")
                    dicPhoneNo.setValue(strSubTitle, forKey: "vType")
                    
                    if arrUser_PhoneNo.contains(strTitle) == true {
                        dicPhoneNo.setValue("1", forKey: "isAppUser")
                    }
                    else {
                        dicPhoneNo.setValue("0", forKey: "isAppUser")
                    }
                    arrPhoneNo.add(dicPhoneNo)
                }
                if strType == "emailaddress".uppercased() {
                    let dicEmail : NSMutableDictionary = NSMutableDictionary.init()
                    dicEmail.setValue(strTitle, forKey: "vEmail")
                    dicEmail.setValue(strSubTitle, forKey: "vType")
                    arrEmail.add(dicEmail)
                }
                if strType == "address".uppercased() {
                    let dicAddress : NSMutableDictionary = NSMutableDictionary.init()
                    dicAddress.setValue(strTitle, forKey: "vAddress")
                    dicAddress.setValue(strSubTitle, forKey: "vType")
                    arrAddress.add(dicAddress)
                }
            }
        }
        ContactInfo.setValue(arrPhoneNo, forKey: "vPhoneNoList")
        ContactInfo.setValue(arrEmail, forKey: "vEmailList")
        ContactInfo.setValue(arrAddress, forKey: "vAddressList")
        
        arrContactData.add(ContactInfo)
    }
    return arrContactData.mutableCopy() as! NSArray
}

func get_SendContactDataFormat_Select(objContact : CNContact) -> NSDictionary {
    let dicData : NSMutableDictionary = NSMutableDictionary.init()
    
    //Photo
    /*if objContact.imageDataAvailable == true {
     let img = UIImage.init(named: "contact_msg")
     dicData.setValue(img?.sd_imageData(), forKey: k_Img)
     }
     else { dicData.setValue(objContact.thumbnailImageData, forKey: k_Img) }*/
    dicData.setValue("", forKey: k_Img)
    
    //Name
    let strName : String = TRIM(string: objContact.givenName + " " + objContact.familyName)
    //if strName.count > 0 { dicData.setValue(strName, forKey: k_Name) }
    dicData.setValue(strName, forKey: k_Name)
    
    //Other Cell Info
    let arrInfo : NSMutableArray = NSMutableArray.init()
    //PhoneNo List------------>
    //let arr : NSMutableArray = NSMutableArray.init()
    let arrPhoneNo : NSArray = getContact_PhoneNo(objContact: objContact)
    for obj in arrPhoneNo
    {
        let dicPhoneNo : NSDictionary = obj as! NSDictionary
        let strNo : String = dicPhoneNo.value(forKey: "number") as! String
        let strNoType : String = dicPhoneNo.value(forKey: "type") as! String
        let strType : String = "phoneno"
        let dicPhoneNoInfo : NSMutableDictionary = NSMutableDictionary.init()
        dicPhoneNoInfo.setValue(strNo, forKey: k_Title)
        dicPhoneNoInfo.setValue(strNoType, forKey: k_Subtitle)
        dicPhoneNoInfo.setValue(strType, forKey: k_Type)
        dicPhoneNoInfo.setValue("1", forKey: k_IsSelected)
        arrInfo.add(dicPhoneNoInfo)
    }
    
    //Email Address List------------>
    let arrEmailAddress : NSArray = getContact_EmailAddress(objContact: objContact)
    for obj in arrEmailAddress
    {
        let dicEmail : NSDictionary = obj as! NSDictionary
        let strEmail : String = dicEmail.value(forKey: "email") as! String
        let strEmailType : String = dicEmail.value(forKey: "type") as! String
        let strType : String = "emailaddress"
        let dicEmailAddressInfo : NSMutableDictionary = NSMutableDictionary.init()
        dicEmailAddressInfo.setValue(strEmail, forKey: k_Title)
        dicEmailAddressInfo.setValue(strEmailType, forKey: k_Subtitle)
        dicEmailAddressInfo.setValue(strType, forKey: k_Type)
        dicEmailAddressInfo.setValue("1", forKey: k_IsSelected)
        arrInfo.add(dicEmailAddressInfo)
    }
    
    //Address List------------>
    let arrAddress : NSArray = getContact_Address(objContact: objContact)
    for obj in arrAddress {
        let dicAddress : NSDictionary = obj as! NSDictionary
        let strAddress : String = dicAddress.value(forKey: "address") as! String
        let strAddressType : String = dicAddress.value(forKey: "type") as! String
        let strType : String = "address"
        
        let dicAddressInfo : NSMutableDictionary = NSMutableDictionary.init()
        dicAddressInfo.setValue(strAddress, forKey: k_Title)
        dicAddressInfo.setValue(strAddressType, forKey: k_Subtitle)
        dicAddressInfo.setValue(strType, forKey: k_Type)
        dicAddressInfo.setValue("1", forKey: k_IsSelected)
        
        arrInfo.add(dicAddressInfo)
    }
    //if arrInfo.count > 0 { dicData.setValue(arrInfo, forKey: k_Cell) }
    dicData.setValue(arrInfo, forKey: k_Cell)
    
    return dicData.mutableCopy() as! NSDictionary
}

func getContact_PhoneNo (objContact : CNContact) -> NSArray {
    let arrPhoneNo : NSMutableArray = NSMutableArray.init()
    for obj in objContact.phoneNumbers {
        let phone = obj.value
        
        var vType : String = ""
        var vNumber : String = ""
        
        if phone.stringValue.contains("*") || phone.stringValue.contains("#") {
            //PHONE NUMBER IS KIND OF *123# SO IGNORE IT
        }
        else {
            vNumber = ContactSync.shared.get_WithoutFormat_PhoneNo(phoneNo: phone.stringValue)
            vType = "Work"
            
            switch obj.label {
            case CNLabelHome?:
                vType = "Home"
                break
            case CNLabelWork?:
                vType = "Work"
                break
            case CNLabelPhoneNumberiPhone?:
                vType = "iPhone"
                break
            case CNLabelPhoneNumberMobile?:
                vType = "Mobile"
                break
            case CNLabelPhoneNumberMain?:
                vType = "Main"
                break
            case CNLabelPhoneNumberHomeFax?:
                vType = "Home Fax"
                break
            case CNLabelPhoneNumberWorkFax?:
                vType = "Work Fax"
                break
            case CNLabelPhoneNumberOtherFax?:
                vType = "Other Fax"
                break
            case CNLabelPhoneNumberPager?:
                vType = "Pager"
                break
            default:
                vType = "Other"
                break
            }
        }
        
        let dicPhoneNo : NSMutableDictionary = NSMutableDictionary.init()
        dicPhoneNo.setValue(vType, forKey: "type")
        dicPhoneNo.setValue("+" + vNumber, forKey: "number")
        
        arrPhoneNo.add(dicPhoneNo)
    }
    return arrPhoneNo
}

func getContact_EmailAddress (objContact : CNContact) -> NSArray {
    let arrEmail : NSMutableArray = NSMutableArray.init()
    for obj in objContact.emailAddresses {
        let email = obj.value
        
        var vType : String = ""
        var vEmail : String = ""
        
        vEmail = email as String
        vType = "Work"
        
        switch obj.label {
        case CNLabelHome?:
            vType = "Home"
            break
        case CNLabelWork?:
            vType = "Work"
            break
        case CNLabelOther?:
            vType = "Other"
            break
        case CNLabelEmailiCloud?:
            vType = "iCloud"
            break
        default:
            vType = "Other"
            break
        }
        
        let dicEmail : NSMutableDictionary = NSMutableDictionary.init()
        dicEmail.setValue(vType, forKey: "type")
        dicEmail.setValue(vEmail, forKey: "email")
        
        arrEmail.add(dicEmail)
    }
    return arrEmail
}

func getContact_Address (objContact : CNContact) -> NSArray {
    let arrAddress : NSMutableArray = NSMutableArray.init()
    for obj in objContact.postalAddresses {
        let address = obj.value
        
        var vType : String = ""
        var vAddress : String = ""
        
        vAddress = "\(address.street)" + " " +
            //"\(address.subLocality ?? "")" + " " +
            "\(address.city)" + " " +
            "\(address.state)" + " " +
            "\(address.postalCode)" + " " +
            "\(address.country)" + " "
        vAddress = TRIM(string: vAddress)
        vType = "Work"
        
        switch obj.label {
        case CNLabelHome?:
            vType = "Home"
            break
        case CNLabelWork?:
            vType = "Work"
            break
        case CNLabelOther?:
            vType = "Other"
            break
        default:
            vType = "Other"
            break
        }
        
        let dicAddress : NSMutableDictionary = NSMutableDictionary.init()
        dicAddress.setValue(vType, forKey: "type")
        dicAddress.setValue(vAddress, forKey: "address")
        
        arrAddress.add(dicAddress)
    }
    return arrAddress
}
