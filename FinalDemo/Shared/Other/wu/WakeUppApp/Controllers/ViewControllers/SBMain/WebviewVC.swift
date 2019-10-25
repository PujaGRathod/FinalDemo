//
//  WebviewVC.swift
//  WakeUppApp
//
//  Created by C025 on 05/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class WebviewVC: UIViewController, UIWebViewDelegate {

    //MARK: Outlet
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var webview: UIWebView!
    
    //MARK: Variable
    var strTitle : String = ""
    var strURL : String = ""
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set Title
        btnBack.setTitle(strTitle, for: .normal)
        
        //Load URL
        if (strURL.count != 0) {
            let url = URL (string: strURL)
            let requestObj = URLRequest(url: url!)
            self.webview.loadRequest(requestObj)
        }
        else {
            showMessage("URL not found")
        }
        
        //PV
        self.webview.scrollView.bounces = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Custo Function
    func manage_Loader(isShow : Bool) {
        
        if (isShow == true) {
            loader.startAnimating()
            loader.isHidden = false
        }
        else {
            loader.stopAnimating()
            loader.isHidden = true
        }
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    //MARK: - Webview Delegate Method
    func webViewDidStartLoad(_ webView: UIWebView) {
        manage_Loader(isShow: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        manage_Loader(isShow: false)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        manage_Loader(isShow: false)
        
        var strErrMess : String = ""
        strErrMess += "Invalid URL\n"
        strErrMess += error.localizedDescription
        showMessage(strErrMess)
    }
}
