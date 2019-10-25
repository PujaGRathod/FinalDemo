//
//  StoryViewerView.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 21/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class StoryViewerView: UIView
{
    var storyID = "0"
    var arrViewers = [StructStoryViewers]()
    
    @IBOutlet var vwMain: UIView!
    @IBOutlet var vwHeader: UIView!
    @IBOutlet var tblViewers: UITableView!
    @IBOutlet var btnvwCount: UIButton!
    @IBOutlet var heightViewer: NSLayoutConstraint!
    @IBOutlet var btnNodata: UIButton!
    
    var sid = String()
    var dicviewer = NSDictionary()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        //self.vwmain.roundCorners([.topLeft,.topRight], radius: 15)
        self.vwMain.clipsToBounds = true
        self.tblViewers.register(UINib(nibName: "ViewerCell", bundle: nil), forCellReuseIdentifier: "ViewerCell")
        self.tblViewers.tableFooterView = UIView()
        self.tblViewers.delegate = self
        self.tblViewers.dataSource = self
        reloadTable()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: NC_ViewerRefresh), object: nil)

    }
}

extension StoryViewerView:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrViewers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewerCell") as! ViewerCell
        let obj = arrViewers[indexPath.row]
        var url = obj.profileURL
        if obj.profileURL.count > 0 && obj.profileURL.hasPrefix("http") == false
        {
            //print("DO NOW")
            url = Get_Profile_Pic_URL + url
        }
        cell.imgprofile.sd_setImage(with: url.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: nil)
        cell.lblname.text = obj.userName
        
        let strDate = obj.createdDate//.replacingOccurrences(of: " ", with: "T")
        let dtvalr = strDate == "" ? "" : timeAgoSinceStrDate(strDate: strDate, numericDates: true)
        cell.lbltime.text = dtvalr
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
    @objc func reloadTable()
    {
        arrViewers = CoreDBManager.sharedDatabase.getViewers(ForMyStoryID: storyID)
        btnvwCount.setTitle("\(arrViewers.count)", for: .normal)
        
        //heightViewer.constant = CGFloat(Float(arrViewers.count * 50) + 70.0)

        if arrViewers.count == 0{
            tblViewers.isHidden = true
            btnNodata.isHidden = false
            heightViewer.constant = CGFloat(120.0)
        }else{
            if arrViewers.count > 6{
                heightViewer.constant = 400
            }
            else{
                heightViewer.constant = CGFloat(Float(arrViewers.count * 50) + 70.0)
            }
            tblViewers.isHidden = false
            btnNodata.isHidden = true
            tblViewers.reloadData()
        }
        /*if dicviewer.count > 0 {
            arrvw = dicviewer[sid]! as! [StructViewers]
            self.btnvwcount.setTitle("\(self.arrvw.count)", for: .normal)
            if self.arrvw.count == 0
            {
                self.tblviewers.isHidden = true
                self.btnnodata.isHidden = false
            }
            else
            {
                if self.arrvw.count > 6
                {
                    self.heightviewer.constant = 400
                }
                else
                {
                    self.heightviewer.constant = CGFloat(Float(self.arrvw.count * 50) + 70.0)
                }
                self.tblviewers.isHidden = false
                self.btnnodata.isHidden = true
                self.tblviewers.reloadData()
            }
        }
        else
        {
            self.btnvwcount.setTitle("0", for: .normal)
            self.tblviewers.isHidden = true
            self.btnnodata.isHidden = false
            self.heightviewer.constant = 140
        }*/
    }
}
