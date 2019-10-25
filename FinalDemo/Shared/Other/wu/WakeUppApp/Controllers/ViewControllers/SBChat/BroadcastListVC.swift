//
//  BroadcastListVC.swift
//  WakeUppApp
//
//  Created by Admin on 31/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class BroadcastListVC: UIViewController {

    @IBOutlet weak var tbllist: UITableView!
    @IBOutlet var vwnodata: UIView!
    
    var arrBroadcastLists = [StructBroadcastList]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadTable()
    }
    
    @objc func reloadTable(){
        
        self.arrBroadcastLists = CoreDBManager.sharedDatabase.getBroadcastLists() as! [StructBroadcastList]
        
        if arrBroadcastLists.count == 0{
            tbllist.isHidden = true
            vwnodata.isHidden = false
        }else{
            tbllist.isHidden = false
            vwnodata.isHidden = true
        }
        
        tbllist.reloadData()
    }
    
    func layoutUI()
    {
        self.automaticallyAdjustsScrollViewInsets = false
        tbllist.contentInset = UIEdgeInsets.zero
        
        let footervw = UIView.init(frame: .zero)
        self.tbllist.tableFooterView = footervw
        tbllist.delegate = self
        tbllist.dataSource = self
        isStatusBarHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnNewBroadcastListClicked(_ sender: Any) {
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
        //vc.forBroadcastList = true
        vc.objEnumSelectMember = .enumSelectMember_BroadcastChat
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
}

extension BroadcastListVC:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBroadcastLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastListCell") as! BroadcastListCell
        
        let broadcastList = arrBroadcastLists[indexPath.row]
        
        let dtvalr = broadcastList.lastMessageDate == "" ? "" : timeAgoSinceStrDate(strDate: broadcastList.lastMessageDate, numericDates: true)
        cell.lbltime.text = dtvalr
        
        cell.btnselected.isHidden = true
        cell.lblname.text = broadcastList.name
        cell.lblrecentmsg.text = broadcastList.lastMessage.base64Decoded
        //cell.imgprofile.sd_setImage(with: URL.init(string: chatGroup.icon), placeholderImage: GroupPlaceholderImage)
        cell.imgprofile.image = #imageLiteral(resourceName: "boradcast_profile")
        
        cell.widthgroupuser.constant = 0
        cell.widthmsgtype.constant = 0
        cell.widthreadreceipt.constant = 0
        
        cell.btncount.titleLabel?.text = ""
        cell.btncount.isHidden = true
        
        cell.lblrecentmsg.textColor = .darkGray
        
        switch broadcastList.lastMessageType {
        case "0":
            cell.widthmsgtype.constant = 0
            cell.leadingmsg.constant = -5
        case "1":
            cell.widthmsgtype.constant = 12
            cell.leadingmsg.constant = 5
            
            if isPathForImage(path: broadcastList.lastMediaURL){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "image_msg")
                cell.lblrecentmsg.text = "Photo"
            }
            else if isPathForContact(path: broadcastList.lastMediaURL){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "contact_msg")
                cell.lblrecentmsg.text = "Contact"
            }
            else if isPathForVideo(path: broadcastList.lastMediaURL){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "video_msg")
                cell.lblrecentmsg.text = "Video"
            }else if isPathForAudio(path: broadcastList.lastMediaURL){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "voice_msg-1")
                cell.lblrecentmsg.text = "Audio"
            }
            else{
                cell.imgmsgtype.image = #imageLiteral(resourceName: "doc_msg")
                cell.lblrecentmsg.text = getFileType(for: broadcastList.lastMediaURL)
            }
            
        case "2":
            cell.widthmsgtype.constant = 12
            cell.leadingmsg.constant = 5
            
            cell.imgmsgtype.image = #imageLiteral(resourceName: "location_msg")
            cell.lblrecentmsg.text = "Location"
        default:
            break
        }
        
        cell.imgreceipt.image = nil
        cell.widthreadreceipt.constant = 0
        cell.imgsound.image = nil
        cell.soundWidth.constant = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let convo = loadVC(strStoryboardId: SB_CHAT, strVCId: idBroadcastChatVC) as! BroadcastChatVC
        let broadcastDetails = arrBroadcastLists[indexPath.row]
        convo.calledfrom = "messages"
        convo.selectedBroadcastListID = broadcastDetails.broadcastListID
        convo.broadcastListName = broadcastDetails.name
        APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
    }
    
}

