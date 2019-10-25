//
//  ContactsSendVC.swift
//  WakeUppApp
//
//  Created by Admin on 19/09/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

protocol ContactsSendVC_Delegate : AnyObject {
    func get_SendContactData_inContactsSendVC(dicContact: NSDictionary) -> Void
}

enum enumContact : Int {
    case None = 0
    case contact_Send
    case contact_View
}

class ContactsSendVC: UIViewController, UITableViewDelegate,UITableViewDataSource
{
    weak var delegate: ContactsSendVC_Delegate?
    var redirrectfrom = ""
    //MARK: - Outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var tblContact: UITableView!
    @IBOutlet weak var btnSendContact: UIButton!
    
    @IBOutlet weak var viewPlaceholder: UIView!
    @IBOutlet weak var imgPlaceholder: UIImageView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    
    //MARK: - Variable
     var objEnumContact : enumContact = .None
    var arrContact = [CNContact]()
    var arrData : NSMutableArray = NSMutableArray.init()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.endEditing(true)
        self.tblContact.delegate = self
        self.tblContact.dataSource = self
        self.tblContact.tableFooterView = UIView()
        //self.tblContact.setEditing(true, animated: true)
        
        self.manage_SendContact_and_ViewContact()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Other function
    func manage_SendContact_and_ViewContact() -> Void {
        
        switch self.objEnumContact {
        case .None:
            self.lblTitle.text = "Contact"
            self.btnSendContact.isHidden = true
            break
            
        case .contact_Send:
            self.lblTitle.text = "Send Contact"
            
            if (self.arrContact.count > 0) {
                self.btnSendContact.isHidden = false
                self.manageContactArray()
            } else {
                self.btnbackclicked(UIButton.init())
                showMessage(SomethingWrongMessage)
            }
            break
            
        case .contact_View:
            self.lblTitle.text = "Contact"
            
            if (self.arrContact.count > 0) {
                self.btnSendContact.isHidden = true
                self.manageContactArray()
            } else {
                self.btnbackclicked(UIButton.init())
                showMessage(SomethingWrongMessage)
            }
            break
        }
    }
    
    func manageContactArray() {
        arrData = NSMutableArray.init()
        
        for objContact in self.arrContact {
            var objDicData : NSDictionary = NSDictionary.init()
            objDicData = get_SendContactDataFormat_Select(objContact: objContact)
            
            //let strTitle : String = objDicData.value(forKey: k_Name) as! String
            //let objArr : NSArray = objDicData.value(forKey: k_Cell) as! NSArray
            //if objArr.count == 0 &&  strTitle.count > 0 { self.arrData.add(objDicData) }
            
            self.arrData.add(objDicData)
        }
        self.tblContact.reloadData()
    }
    
    //MARK: - Button action method
    @IBAction func btnbackclicked(_ sender: Any) {
        self.view.endEditing(true)
        _ = APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnSendContactAction(_ sender: Any) {
        
        //Create Dic. for send in chat message.
        var arrContact : NSMutableArray = NSMutableArray.init()
        arrContact = get_SendContactDataFormat_inSocket(arrContact: self.arrData).mutableCopy() as! NSMutableArray
        //print("ContactInfo : \(arrContact)")
        
        if arrContact.count == 0 {
            showMessage("please select contact details for send it")
        }
        else {
            //showMessage("Done... :)")
            
            let dicFinal : NSMutableDictionary = NSMutableDictionary.init()
            dicFinal.setValue("Contact", forKey: "title")
            dicFinal.setValue(arrContact, forKey: "data")
            
            //Update title
            var strJSONString : String = ""
            strJSONString = convertDictionaryToJSONString(dic: dicFinal.mutableCopy() as! NSDictionary) ?? "Contact"
            let title : String = get_ContactName(strMess: strJSONString.base64Encoded ?? "")
            dicFinal.setValue(title, forKey: "title")
            
            self.delegate?.get_SendContactData_inContactsSendVC(dicContact: dicFinal)
            
            //Dismiss view / Back the view
            self.btnbackclicked(UIButton.init())
        }
    }
}

//MARK:- Tableview Delegate method
extension  ContactsSendVC {
    func numberOfSections(in tableView: UITableView) -> Int {
        //return arrData.count
        let noOfSection = arrData.count
        
        self.tblContact.isHidden = true
        self.viewPlaceholder.isHidden = true
        if (noOfSection == 0) {
            self.viewPlaceholder.isHidden = false
            //self.imgPlaceholder.image = #imageLiteral(resourceName: "contact_msg")
            //self.lblPlaceholder.text = ""
        }
        else { self.tblContact.isHidden = false }
        
        return noOfSection
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /*func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let obj : NSDictionary = self.arrData[section] as! NSDictionary
        let title : String = obj.value(forKey: k_Name) as! String
        return title
    }*/
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        switch self.objEnumContact {
        case .contact_Send:
            let cell : UITableViewCell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            
            let obj : NSDictionary = self.arrData[section] as! NSDictionary
            let title : String = obj.value(forKey: k_Name) as! String
            
            //let imgData : Data = obj.value(forKey: k_Img) as! Data
            /*if (imgData.count == 0) {
             cell.imageView?.image = UIImage.init(named: "contact_msg")
             }
             else {
             let imgPhoto : UIImage = UIImage.init(data: imgData)!
             cell.imageView?.image = imgPhoto
             }
             let imgPhoto : UIImage = UIImage.init(data: imgData)!
             cell.imageView?.image = imgPhoto
             cell.imageView?.cornerRadius = (cell.imageView?.frame.height)!/2*/
            cell.imageView?.image = UIImage.init(named: "contact_msg")
            
            cell.textLabel?.textColor = themeWakeUppColor
            cell.textLabel?.font = FontWithSize(FT_Bold, 16)
            cell.textLabel?.text = title
            
            let frame = CGRect(x:0,y: 0,width: tableView.frame.size.width,height:tableView.sectionHeaderHeight)
            let view = UIView(frame:frame)
            view.backgroundColor = UIColor.white
            view.addSubview(cell)
            
            //Why add following button
            // Bcoz., remove header selection action remove.
            let btn = UIButton.init(frame: frame)
            btn.backgroundColor = UIColor.clear
            view.addSubview(btn)
            return view
            
        case .contact_View:
            let cell : ContactsSend_HeaderCell = tableView.dequeueReusableCell(withIdentifier: "cell_header") as! ContactsSend_HeaderCell
            
            let obj : NSDictionary = self.arrData[section] as! NSDictionary
            var title : String = obj.value(forKey: k_Name) as! String
            
            //let imgData : Data = obj.value(forKey: k_Img) as! Data
            /*if (imgData.count == 0) {
             cell.imageView?.image = UIImage.init(named: "contact_msg")
             }
             else {
             let imgPhoto : UIImage = UIImage.init(data: imgData)!
             cell.imageView?.image = imgPhoto
             }
             let imgPhoto : UIImage = UIImage.init(data: imgData)!
             cell.imageView?.image = imgPhoto
             cell.imageView?.cornerRadius = (cell.imageView?.frame.height)!/2*/
            cell.imgPhoto.image = UIImage.init(named: "contact_msg")
           
           
            cell.lblTitle.numberOfLines = 0
            cell.btnAction.setTitle("Add", for: .normal)
            cell.btnAction.tag = section
            cell.btnAction.addTarget(self, action: #selector(btnAddContactAction(sender:)), for: .touchUpInside)
           
            if title.count == 0 {
                cell.btnAction.isHidden = true
                cell.lblTitle.text = self.lblPlaceholder.text
                cell.lblTitle.textColor = themeTextColor
                cell.lblTitle.font = FontWithSize(FT_Regular, 14)
            }
            else
            {
                if !title.hasPrefix("+")
                {
                    title = "+" + title
                }
                cell.lblTitle.textColor = themeWakeUppColor
                cell.lblTitle.font = FontWithSize(FT_Bold, 16)
                cell.lblTitle.text = title
                cell.btnAction.isHidden = false
            }
            if redirrectfrom != "ChatContactReceiverCell"
            {
                cell.btnAction.isHidden = false
            }
            else
            {
                cell.btnAction.isHidden = true
            }
            cell.backgroundColor = UIColor.white
            return cell
            
        default:
            return UIView.init()
        }
        //return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let objData : NSDictionary = self.arrData[section] as! NSDictionary
        let objArr : NSArray = objData.value(forKey: k_Cell) as! NSArray
        return objArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        
        let objData : NSDictionary = self.arrData[indexPath.section] as! NSDictionary
        let objArr : NSArray = objData.value(forKey: k_Cell) as! NSArray
        let objDataInfo : NSDictionary = objArr[indexPath.row] as! NSDictionary
        let strSelectedStatus : String = objDataInfo.value(forKey: k_IsSelected) as! String
        
        cell.textLabel?.text = objDataInfo.value(forKey: k_Title) as? String
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.font = FontWithSize(FT_Regular, 14)
        cell.textLabel?.numberOfLines = 0
        
        cell.detailTextLabel?.text = objDataInfo.value(forKey: k_Subtitle) as? String
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.detailTextLabel?.font = FontWithSize(FT_Light, 10)
        cell.detailTextLabel?.numberOfLines = 0
        
        switch self.objEnumContact {
        case .contact_Send:
            let checkmark_img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 15, height: 15))
            cell.accessoryView = checkmark_img
            
            if (strSelectedStatus == "1") { checkmark_img.image = #imageLiteral(resourceName: "checkbox_setting_checked") }
            else { checkmark_img.image = #imageLiteral(resourceName: "checkbox_setting") }
            
            cell.accessoryView = checkmark_img
        case .contact_View:
            cell.accessoryView = UIView.init()
        default:
            cell.accessoryView = UIView.init()
        }
        
        cell.selectionStyle = .none
        tableView.allowsSelection = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.objEnumContact {
        case .contact_Send:
            selectOrDeselectCell(at: indexPath)
        case .contact_View:
            return
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch self.objEnumContact {
        case .contact_Send:
            selectOrDeselectCell(at: indexPath)
        case .contact_View:
            return
        default:
            return
        }
    }
    
    //MARK: Tableview button action method
    
    @objc func btnAddContactAction(sender: UIButton) {
        let obj = self.arrContact[sender.tag]
        
        /*let controller = CNContactViewController(forUnknownContact : obj)
        controller.contactStore = CNContactStore()
        controller.allowsActions = false
        controller.delegate = self
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.title = "Back"
        APP_DELEGATE.appNavigation?.pushViewController(controller, animated: true)*/
        
        //let contact = ContactSync.shared.get_ContactObject(strCountryCode: self.selectedUser?.kcountrycode ?? "", strPhoneNo: self.selectedUser?.kphonenumber ?? "")
        let controller = CNContactViewController(forNewContact: obj)
        controller.delegate = self
        controller.allowsActions = false
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.title = "Back"
        APP_DELEGATE.appNavigation?.pushViewController(controller, animated: true)
    }
    
    func selectOrDeselectCell(at indexPath:IndexPath) {
        let objSelected_Data : NSMutableDictionary = self.arrData[indexPath.section] as! NSMutableDictionary
        let objSelected_Arr : NSMutableArray = objSelected_Data.value(forKey: k_Cell) as! NSMutableArray
        let objSelected_Info : NSMutableDictionary = objSelected_Arr[indexPath.row] as! NSMutableDictionary
        
        let strSelectedStatus : String = objSelected_Info.value(forKey: k_IsSelected) as! String
        if (strSelectedStatus == "1") { objSelected_Info.setValue("0", forKey: k_IsSelected) }
        else { objSelected_Info.setValue("1", forKey: k_IsSelected) }
        
        objSelected_Arr.replaceObject(at: indexPath.row, with: objSelected_Info)
        objSelected_Data.setValue(objSelected_Arr, forKey: k_Cell)
        self.arrData.replaceObject(at: indexPath.section, with: objSelected_Data)
        
        self.tblContact.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
}

extension ContactsSendVC : CNContactViewControllerDelegate
{
    //MARK: Add Contact Delegate Method
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if contact != nil {
            if contact!.phoneNumbers.count > 0
            {
                let objContact = ContactEntry.init(cnContact: contact!, false, contact!.phoneNumbers.first!)
                ContactSync.shared.AddContact_In_DeviceContactInfo(contact: objContact!)
            }
        }
        APP_DELEGATE.appNavigation?.popViewController(animated: false)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
}
