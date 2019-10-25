//
//  SearchVC.swift
//  WakeUppApp
//
//  Created by Admin on 23/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

enum searchCriteria {
    case populer
    case people
    case tags
    case places
}

class SearchVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionResult: UICollectionView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchCriteria: UICollectionView!
    @IBOutlet weak var searchCriteriaHeight: NSLayoutConstraint!
    @IBOutlet weak var historyCriteria: UICollectionView!
    @IBOutlet weak var historyCriteriaHeight: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    var objCurrentCriteria:searchCriteria = .populer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }

    func setupUI()  {
        txtSearch.addPaddingLeft(40.0)
        isStatusBarHidden = false
    
        collectionResult.delegate = self
        collectionResult.dataSource = self
        
        searchCriteria.delegate = self
        searchCriteria.dataSource = self
        
        historyCriteria.delegate = self
        historyCriteria.dataSource = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(collectionView == searchCriteria)
        {
            return 4
        }
        else if(collectionView == historyCriteria)
        {
            return 6
        }
        else
        {
            return 21
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if(collectionView == searchCriteria)
        {
            let cell:SearchCriteriaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath as IndexPath) as! SearchCriteriaCell
        
            
            cell.lblCriteria.alpha = 0.5
           
            
           
            
            switch indexPath.row {
            case 0:
                cell.imgCriteria.image = UIImage(named: "popular_search")
                cell.lblCriteria.text = "Populer"
                cell.lblCriteria.alpha = objCurrentCriteria == .populer ? 1.0 : 0.5
               break
            case 1:
                cell.imgCriteria.image = UIImage(named: "people_search")
                cell.lblCriteria.text = "People"
                 cell.lblCriteria.alpha = objCurrentCriteria == .people ? 1.0 : 0.5
                break
            case 2:
                cell.imgCriteria.image = UIImage(named: "hashtag_search")
                cell.lblCriteria.text = "Tags"
                 cell.lblCriteria.alpha = objCurrentCriteria == .tags ? 1.0 : 0.5
                break
            case 3:
                cell.imgCriteria.image = UIImage(named: "places_search")
                cell.lblCriteria.text = "Place"
                cell.lblCriteria.alpha = objCurrentCriteria == .places ? 1.0 : 0.5
               break
            default:
                break
            }
        
            return cell
        }
        else if(collectionView == historyCriteria)
        {
            
            let cell:SearchCriteriaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath as IndexPath) as! SearchCriteriaCell
            
            return cell
        }
        else
        {
            if(indexPath.row == 0)
            {
                let cell:PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCountCell", for: indexPath as IndexPath) as! PhotoCell
                
                return cell
            }
            else
            {
                let cell:PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
                  cell.imgPic.sd_setImage(with: URL.init(string: "https://itechway.net/wp-content/uploads/2017/08/cute-baby-1.jpg"), placeholderImage: ProfilePlaceholderImage)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == searchCriteria)
        {
             return CGSize.init(width: SCREENWIDTH()/4 , height: 100 )
        }
        else if (collectionView == historyCriteria)
        {
            return CGSize.init(width: SCREENWIDTH()/4 , height: 100 )
        }
        else
        {
            if(indexPath.row == 0)
            {
                return CGSize.init(width: SCREENWIDTH() , height: 34 )
            }
            else
            {
                return CGSize.init(width: SCREENWIDTH()/3 , height: SCREENWIDTH()/3 )
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if(collectionView == collectionResult)
        {
            return UIEdgeInsets(top: 268, left: 0, bottom: 0, right: 0)
        }
        else
        {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print(indexPath.row)
        if(collectionView ==  searchCriteria)
        {
            switch indexPath.row {
            case 0:
                objCurrentCriteria = .populer
                break
            case 1:
                objCurrentCriteria = .people
                break
            case 2:
                objCurrentCriteria = .tags
                break
            case 3:
                objCurrentCriteria = .places
            default:
                break
            }
            searchCriteria.reloadData()
        }
    }
   
    @IBAction func btnBack(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
}
