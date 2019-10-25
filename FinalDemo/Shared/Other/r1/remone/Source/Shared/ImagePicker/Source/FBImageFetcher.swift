//
//  FBImageFetcher.swift
//  ImagePicker
//
//  Created by Arjav Lad on 23/12/17.
//  Copyright © 2017 Arjav Lad. All rights reserved.
//

import UIKit
import FBSDKLoginKit

typealias ImageFetcherCompletion = (Error?, [ImageObject]) -> Void

class FBImageFetcher: NSObject {
    static let shared: FBImageFetcher = FBImageFetcher()
    private let loginManager: FBSDKLoginManager
    private var loadedImages: [ImageObject] = [ImageObject]()
    private var completionBlock: ImageFetcherCompletion?
    var token: String? {
        return FBSDKAccessToken.current().tokenString
    }

    override init() {
        self.loginManager = FBSDKLoginManager.init()
    }

    func login(from vc: UIViewController, limit: Int, completion: @escaping ImageFetcherCompletion) {
        self.completionBlock = completion
        self.loadedImages = []
        func complete(with error: String?) {
            DispatchQueue.main.async {
                if let errorMessage = error {
                    self.completionBlock?(NSError.init(domain: "FBImageFetcher", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]), self.loadedImages)
                } else {
                    self.completionBlock?(nil, self.loadedImages)
                }

            }
        }
        self.loginManager.logIn(withReadPermissions: ["user_photos"], from: vc) { (result, error) in
            if let error = error {
                print("Error in Login with FB: \(error.localizedDescription)")
                complete(with: error.localizedDescription)
            } else if let result = result {
                if result.isCancelled {
                    print("Login with FB: Cancelled by user")
                    complete(with: nil)
                } else {
                    print("Rejected permissions: \(result.declinedPermissions)")
                    DispatchQueue.main.async {
                        self.loadImages(limit)
                    }
                }
            } else {
                self.loginManager.logOut()
                print("Login with FB: Unknown Error")
                complete(with: "Unknown error!".localized)
            }
        }
    }

    private func loadImages(_ limit: Int) {
        func complete(with error: String) {
            DispatchQueue.main.async {
                self.completionBlock?(NSError.init(domain: "FBImageFetcher", code: 0, userInfo: [NSLocalizedDescriptionKey: error]), self.loadedImages)
            }
        }
        if let albumRequest = FBSDKGraphRequest.init(graphPath: "/me/photos",
                                                     parameters: ["fields": "images,width", "limit": "\(limit)", "type": "uploaded"],
                                                     httpMethod: "GET") {
            albumRequest.start(completionHandler: { (connection, result, error) in
                if let error = error {
                    print("Error albums fetching: \(error.localizedDescription)")
                    complete(with: error.localizedDescription)
                } else if let result = result as? [String: Any] {
                    if let data = result["data"] as? [[String: Any]] {
                        for dict in data {
                            if let width = dict["width"] as? Int,
                            let images = dict["images"] as? [[String: Any]] {
                                if  let urlString = self.getHighestResolution(from: images, width: width),
                                    let url = URL.init(string: urlString) {
                                    let image = ImageObject.init(withURL: url)
                                    self.loadedImages.append(image)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.completionBlock?(nil, self.loadedImages)
                        }
                    } else {
                        complete(with: "Unknown error!".localized)
                        print("Wrong response: \(result)")
                    }
                } else {
                    complete(with: "Unknown error!".localized)
                }
            })
        } else {
            complete(with: "request failed!".localized)
        }

    }

    private func getHighestResolution(from reso: [[String: Any]], width: Int) -> String? {
        for imageData in reso {
            if let widthImage = imageData["width"] as? Int {
                if width <= widthImage {
                    return imageData["source"] as? String
                }
            }
        }
        return nil
    }
}

