//
//  InstagramVC.swift
//  ImagePicker
//
//  Created by Arjav Lad on 23/12/17.
//  Copyright © 2017 Arjav Lad. All rights reserved.
//

import UIKit

fileprivate let InstagramAuthURL = "https://api.instagram.com/oauth/authorize/"
fileprivate let InstagramScope = "basic"
fileprivate let InstagramClietID = "e2f29800ad3342f0812656757fb04e19"
fileprivate let InstagramClientSecret = "b68ea896e71645c0be6f96bb1a376334"
fileprivate let InstagramRedirectURI = "http://com.app.remone.instagram"

class InstagramVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var completionBlock: ImageFetcherCompletion?
    var imagesToBeloaded: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let urlString = "\(InstagramAuthURL)?client_id=\(InstagramClietID)&redirect_uri=\(InstagramRedirectURI)&response_type=token&scope=\(InstagramScope)&DEBUG=True"
        if let url = URL.init(string: urlString) {
            let request = URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 20)
            self.webView.loadRequest(request)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    class func loadImages(on vc: UIViewController, limit: Int, completion: @escaping ImageFetcherCompletion) {
        let story = UIStoryboard.init(name: "ImagePicker", bundle: nil)
        if let instaVC = story.instantiateViewController(withIdentifier: "InstagramVC") as? InstagramVC {
            instaVC.completionBlock = completion
            instaVC.imagesToBeloaded = limit
            vc.navigationController?.pushViewController(instaVC, animated: true)
        }
    }

    func showActivityIndicator(_ show: Bool) {
        if show {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }

    func loadInstaImages(with token: String) {
        func complete(with error: String) {
            DispatchQueue.main.async {
                self.completionBlock?(NSError.init(domain: "InstagramImageFetcher", code: 0, userInfo: [NSLocalizedDescriptionKey: error]), [ImageObject]())
                self.navigationController?.popViewController(animated: true)
            }
        }
        self.showActivityIndicator(true)
        if let url = URL.init(string: "https://api.instagram.com/v1/users/self/media/recent?access_token=\(token)") {
            var request = URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 20)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "Cache-Control": "no-cache",
                "Postman-Token": "45807e7e-db5a-a446-841b-5d31a8d8d3e7"
            ]

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error,
                    data == nil {
                    print("Error: \(error.localizedDescription)")
                    complete(with: error.localizedDescription)
                } else {
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                            if let jsonData = json as? [String: Any],
                                let images = jsonData["data"] as? [[String: Any]] {
                                var imagesArray = [ImageObject]()
                                for imageData in images {
                                    if imagesArray.count >= self.imagesToBeloaded {
                                        break
                                    }
                                    if let singleImageData = imageData["images"] as? [String: [String: Any]],
                                        let standardImage = singleImageData["standard_resolution"],
                                        let standardURLString = standardImage["url"] as? String{
                                        if let imageURL = URL.init(string: standardURLString) {
                                            imagesArray.append(ImageObject.init(withURL: imageURL))
                                        }
                                    }
                                }
                                print("Total Instagram images: \(imagesArray.count)")
                                DispatchQueue.main.async {
                                    self.completionBlock?(nil, imagesArray)
                                    self.navigationController?.popViewController(animated: true)
                                }
                            } else {
                                complete(with: "Unknown error!".localized)
                            }
                        } catch {
                            print("Error: \(error.localizedDescription)")
                            complete(with: error.localizedDescription)
                        }
                    }
                }
            })
            dataTask.resume()
        } else {
            complete(with: "request failed!".localized)
        }
    }

    func checkRequest(for callbackURL: URLRequest) -> Bool {
        if let urlString = callbackURL.url?.absoluteString {
            if urlString.hasPrefix(InstagramRedirectURI) {
                if let range = urlString.range(of: "\(InstagramRedirectURI)/#access_token=") {
                    let token = urlString[range.upperBound...]
                    print("Instagram Token: \(token)")
                    self.loadInstaImages(with: String(token))
                    return false
                }
            }
        }
        return true
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        self.showActivityIndicator(true)
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.showActivityIndicator(false)
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Error Loading request: \(error.localizedDescription)")
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return self.checkRequest(for: request)
    }

}
