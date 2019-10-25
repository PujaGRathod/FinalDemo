


//
//  NotificationVC.swift
//  WakeUppApp
//
//  Created by Admin on 28/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblNotification: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblNotification.delegate  = self
        tblNotification.dataSource = self
        tblNotification.estimatedRowHeight = 65
        tblNotification.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnchatclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_CHAT, strVCId: "chatlistvc") as! ChatListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
        
    }
    @IBAction func btnstoryclicked(_ sender: Any) {
        /*let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: "storylistvc") as! StoryListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
        
        let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoriesVC)
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    @IBAction func btnpostclicked(_ sender: Any) {
        /*let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: "feedlistvc") as! FeedListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
        
        let feeds = loadVC(strStoryboardId: SB_FEEDS, strVCId: idFeedVC) as! FeedVC
        APP_DELEGATE.appNavigation?.pushViewController(feeds, animated: false)
    }
    
    @IBAction func btnnotifclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: "NotificationVC") as! NotificationVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    @IBAction func btnuserclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idProfileVC) as! ProfileVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
  
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
 

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect.init(x: 0, y: 0, width: SCREENWIDTH(), height: 34)
        headerView.backgroundColor = RGBA(249, 245, 242, 1)
        
        let lblTitle = UILabel()
        lblTitle.frame = CGRect.init(x: 10, y: 0, width: SCREENWIDTH() - 10.0, height: 34)
        lblTitle.font = FontWithSize(FT_Medium, 13)
        lblTitle.text = "ALL NOTIFICATION"
        lblTitle.textColor = UIColor.darkGray
        headerView.addSubview(lblTitle)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tblNotification.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        cell.lblNotification.text = "Sara Micheal and Payal Umraliya and 10 others started following you."
        cell.lblNotification.numberOfLines = 0
        cell.lblNotification.sizeToFit()
       cell.selectionStyle = .none
        return cell;
    }
}
