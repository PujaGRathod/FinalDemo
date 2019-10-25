//
//  ContactEntry.swift
//  AddressBookContacts
//
//  Created by Ignacio Nieto Carvajal on 20/4/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import Contacts

class ContactEntry: NSObject,NSCoding
{
    
    internal let kContactEntryCountrycodeKey: String = "countrycode"
    internal let kContactEntryImageKey: String = "image"
    internal let kContactEntryEmailKey: String = "email"
    internal let kContactEntryCountrydigitKey: String = "countrydigit"
    internal let kContactEntryPhoneKey: String = "phone"
    internal let kContactEntryNameKey: String = "name"
    internal let kContactEntryPipedPhoneKey: String = "pipedPhone"
    
    var name: String!
    var email: String?
    var phone: String?
    var countrycode: String?
    var countrydigit: String?
    var pipedPhone: String?
    var image: UIImage?
    
    var codearray = ["375", "65", "992", "1", "291", "44", "62", "266", "680", "590", "95", "258", "387", "55", "237", "670", "43", "261", "692", "54", "977", "686", "47", "853", "677", "248", "345", "998", "597", "850", "230", "976", "218", "39", "232", "993", "594", "44", "221", "856", "504", "376", "256", "421", "380", "386", "41", "245", "381", "678", "371", "353", "242", "253", "595", "63", "220", "683", "34", "229", "57", "30", "249", "508", "236", "385", "212", "672", "389", "351", "90", "503", "423", "502", "673", "239", "77", "51", "254", "93", "235", "297", "352", "255", "970", "27", "505", "501", "299", "509", "61", "340", "228", "241", "260", "690", "82", "223", "262", "674", "233", "354", "53", "216", "91", "507", "964", "965", "60", "31", "20", "675", "852", "47", "58", "968", "262", "590", "213", "32", "886", "689", "350", "382", "420", "975", "596", "268", "379", "40", "265", "44", "994", "49", "373", "244", "61", "962", "996", "378", "94", "98", "252", "358", "676", "966", "222", "961", "960", "234", "374", "61", "45", "284", "687", "257", "52", "81", "598", "537", "231", "269",  "86", "855", "872", "370", "66", "688", "967", "591", "880", "64", "251", "359", "238", "246", "227", "372", "995", "599", "44", "973", "224", "590", "356", "355", "685", "225", "84", "963", "506", "972", "250", "679", "7", "377", "36", "264", "263", "595", "56", "267", "48", "33", "92", "46", "971", "974", "226", "681", "682", "243", "290", "593", "240", "500", "691", "298"]
    
    init(name: String, email: String?, phone: String?, image: UIImage?,countrycode: String?,countryDigit: String?,pipedPhone:String?)
    {
        self.name = name
        self.email = email
        self.phone = phone
        self.image = image
        self.countrycode = countrycode
        self.countrydigit = countryDigit
        self.pipedPhone = pipedPhone
    }
    
    required public init(coder aDecoder: NSCoder)
    {
        self.countrycode = aDecoder.decodeObject(forKey: kContactEntryCountrycodeKey) as? String
        self.image = aDecoder.decodeObject(forKey: kContactEntryImageKey) as? UIImage
        self.email = aDecoder.decodeObject(forKey: kContactEntryEmailKey) as? String
        self.countrydigit = aDecoder.decodeObject(forKey: kContactEntryCountrydigitKey) as? String
        self.phone = aDecoder.decodeObject(forKey: kContactEntryPhoneKey) as? String
        self.name = aDecoder.decodeObject(forKey: kContactEntryNameKey) as? String
        self.pipedPhone = aDecoder.decodeObject(forKey: kContactEntryPipedPhoneKey) as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(countrycode, forKey: kContactEntryCountrycodeKey)
        aCoder.encode(image, forKey: kContactEntryImageKey)
        aCoder.encode(email, forKey: kContactEntryEmailKey)
        aCoder.encode(countrydigit, forKey: kContactEntryCountrydigitKey)
        aCoder.encode(phone, forKey: kContactEntryPhoneKey)
        aCoder.encode(name, forKey: kContactEntryNameKey)
        aCoder.encode(pipedPhone, forKey: kContactEntryPipedPhoneKey)
    }
    public func dictionaryRepresentation() -> [String : AnyObject ] {
        
        var dictionary: [String : AnyObject ] = [ : ]
        if countrycode != nil {
            dictionary.updateValue(countrycode! as AnyObject, forKey: kContactEntryCountrycodeKey)
        }
        if image != nil {
            dictionary.updateValue(image!, forKey: kContactEntryImageKey)
        }
        if email != nil {
            dictionary.updateValue(email! as AnyObject, forKey: kContactEntryEmailKey)
        }
        if countrydigit != nil {
            dictionary.updateValue(countrydigit! as AnyObject, forKey: kContactEntryCountrydigitKey)
        }
        if phone != nil {
            dictionary.updateValue(phone! as AnyObject, forKey: kContactEntryPhoneKey)
        }
        if pipedPhone != nil {
            dictionary.updateValue(pipedPhone! as AnyObject, forKey: kContactEntryPipedPhoneKey)
        }
        
        if name != nil {
            dictionary.updateValue(name! as AnyObject, forKey: kContactEntryNameKey)
        }
        return dictionary
    }
    init?(cnContact: CNContact,_ ismultiple:Bool = false , _ numberis:CNLabeledValue<CNPhoneNumber>)
    {
        super.init()
        // name
        if !cnContact.isKeyAvailable(CNContactGivenNameKey) && !cnContact.isKeyAvailable(CNContactFamilyNameKey) { return nil }
        self.name = (cnContact.givenName + " " + cnContact.familyName).trimmingCharacters(in: CharacterSet.whitespaces)
        // image
        self.image = (cnContact.isKeyAvailable(CNContactImageDataKey) && cnContact.imageDataAvailable) ? UIImage(data: cnContact.imageData!) : #imageLiteral(resourceName: "user_notification")
        // email
        if cnContact.isKeyAvailable(CNContactEmailAddressesKey)
        {
            for possibleEmail in cnContact.emailAddresses
            {
                let properEmail = possibleEmail.value as String
                self.email = properEmail;
            }
        }
        if ismultiple == false
        {
            // phone
            if cnContact.isKeyAvailable(CNContactPhoneNumbersKey)
            {
                if cnContact.phoneNumbers.count > 0
                {
                    let phone = cnContact.phoneNumbers.first?.value
                    if ((phone?.stringValue.contains("*"))! || (phone?.stringValue.contains("#"))!){
                        //PHONE NUMBER IS KIND OF *123# SO IGNORE IT
                    }else{
                        self.phone = phone?.stringValue
                        if phone?.value(forKey: "countryCode") as! String? != nil
                        {
                             self.countrycode = phone?.value(forKey: "countryCode") as! String?
                        }
                        else
                        {
                            self.countrycode = "IN"
                        }
                        self.pipedPhone = getPipedString(strval: (phone?.stringValue)!)
                    }
                }
            }
        }
        else
        {
            let phone = numberis.value
            if ((phone.stringValue.contains("*")) || (phone.stringValue.contains("#"))){
                //PHONE NUMBER IS KIND OF *123# SO IGNORE IT
            }else{
                self.phone = phone.stringValue
                if phone.value(forKey: "countryCode") as! String? != nil
                {
                    self.countrycode = phone.value(forKey: "countryCode") as! String?
                }
                else
                {
                    self.countrycode = "IN"
                }
                self.pipedPhone = getPipedString(strval: (phone.stringValue))
            }
        }
    }
    
    func Getchar(str:String,offeset:Int) -> String {
        let first4 = str.substring(to:str.index(str.startIndex, offsetBy: offeset))
        return "\(first4)"
    }
    
    func getPipedString(strval:String) -> String {
        var str = strval
        
        str = str.trimmingCharacters(in: .whitespaces)
        str = str.replacingOccurrences(of: "(", with: "")
        str = str.replacingOccurrences(of: ")", with: "")
        str = str.replacingOccurrences(of: "-", with: "")
        str = str.replacingOccurrences(of: " ", with: "")
        str = str.replacingOccurrences(of: " ", with: "") // special space for space
        
        if str.count < 4 { return str }
        
        if(str.hasPrefix("+"))
        {
            str = str.replacingOccurrences(of: "+", with: "")
            if codearray.contains(Getchar(str: str, offeset: 3))
            {
                let first3 = Getchar(str: str, offeset: 3)
                str = "\(str.dropFirst(3))"
                str = "\(first3)|\(str)" //PIPE REMOVED
            }
            else if codearray.contains(Getchar(str: str, offeset: 2))
            {
                let first2 = Getchar(str: str, offeset: 2)
                str = "\(str.dropFirst(2))"
                str = "\(first2)|\(str)" //PIPE REMOVED
            }
            else
            {
                let first1 = Getchar(str: str, offeset: 1)
                str = "\(str.dropFirst(1))"
                str = "\(first1)|\(str)" //PIPE REMOVED
            }
        }
        else
        {
            str = str.hasPrefix("0") ? "\(str.dropFirst())" : str
            str = "\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode))|\(str)"
        }
        str = str.replacingOccurrences(of: "+", with: "")
        return str
    }
}

