//
//  ImageUploaderVC.swift
//  remone
//
//  Created by Arjav Lad on 23/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import Alamofire

class ImageUploaderVC: UIViewController {

    @IBOutlet weak var viewImageOptions: UIView!
    @IBOutlet weak var colImages: UICollectionView!
    @IBOutlet weak var btnFinish: UIBarButtonItem!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnDeviceLibrary: UIButton!
    @IBOutlet weak var lblImageOptionsTitle: UILabel!

    var pickerAdapter: ImagePickerAdapter!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        Analytics.shared.trackScreen(name: "Personal Settings")

        self.lblImageOptionsTitle.text = "Please upload 10 photos".localized
        self.btnFacebook.setTitle("Facebook".localized, for: .normal)
        self.btnInstagram.setTitle("Instagram".localized, for: .normal)
        self.btnDeviceLibrary.setTitle("Device photo library".localized, for: .normal)
        self.pickerAdapter = ImagePickerAdapter.init(with: self, col: self.colImages, backgroundView: self.viewImageOptions, images: APIManager.shared.loginSession?.user.images)
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

    @IBAction func onInstagramTap(_ sender: UIButton) {
        self.pickerAdapter.chooseInstagram()
    }

    @IBAction func onFacebookTap(_ sender: UIButton) {
        self.pickerAdapter.choosefacebook()
    }

    @IBAction func onDevideLibraryTap(_ sender: UIButton) {
        self.pickerAdapter.chooseDevicePhotoLibrary()
    }

    @IBAction func onFinishTap(_ sender: UIBarButtonItem) {
        print("Loaded Images: \(self.pickerAdapter.allImages.count)")
        if self.pickerAdapter.allImages.count < 10 {
            self.showAlert("Required".localized, message: "Please upload 10 photos.".localized)
        } else {
            self.uploadImages(self.pickerAdapter.allImages)
        }
    }

    /// Is current flow is onboarding or from Profile settings
    ///
    /// - Returns: true or false
    func isOnBoardingFlow() -> Bool {
        if self.navigationController?.viewControllers.first is LoginVC {
            return true
        }
        return false
    }

    /// Upload Image links on Remone Server
    ///
    /// - Parameter images: Array of images
    func uploadImages(_ images: [UIImage]) {
        self.showLoader()
        APIManager.shared.uploadImages(images, { (urls, error) in
            DispatchQueue.main.async {
                let session = APIManager.shared.loginSession
                if let error = error {
                    self.hideLoader()
                    session?.user.isSignupComplete = false
                    session?.save()
                    self.showAlert("Error".localized, message: error.localizedDescription)
                } else {
                    print(urls)
                    session?.user.images = self.convertURLResponse(response: urls)
                    session?.user.isSignupComplete = true
                    session?.save()
                    if let user = session?.user {
                        user.updateProfile({ (success) in
                            /// Finished Uploading Images on Remone Server
                            self.uploadLinksToDotin(false)
                        })
                    } else {
                        print("Session not found!!")
                        self.hideLoader()
                    }
                }
            }
        })
    }

    func convertURLResponse(response: [String]) -> [ImageObject] {
        var imageObjects = [ImageObject]()
        for urlString in response {
            if let url = URL.init(string: urlString) {
                imageObjects.append(ImageObject(withURL: url))
            }
        }
        return imageObjects
    }

    /// If current user is registered as Dotin user
    ///
    /// - Returns: true or false
    func isResiteredUser() -> Bool {
        if self.getCredentials().0 != "" &&
            self.getCredentials().1 != "" {
            return true
        }
        return false
    }

    /// Get Username and password for Admin account of Dotin
    ///
    /// - Returns: (username , password)
    func getAdminCredentials() -> (String, String) {
        return ("", "")
    }

    /// Get Dotin Username and password for current user
    ///
    /// - Returns: (username , password)
    func getCredentials() -> (String, String) {
        if let user = APIManager.shared.loginSession?.user {
            let username = user.dotinUserID
            let skey = user.dotinSKey
            return (username, skey)
        }
        return ("", "")
    }

    /// Finished Uploading on Dotin account with success
    ///
    /// - Parameter success: true or false
    func uploadingFinished(_ success: Bool) {
        DispatchQueue.main.async {
            self.hideLoader()
            if success {
                self.hideLoader()
                if self.isOnBoardingFlow() {
                    self.performSegue(withIdentifier: "unwindToLoginVC", sender: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                print("Links Uploading failed!")
                self.showAlert("Error".localized, message: "Uploading Failed!".localized,
                               actionTitles: [("retry".localized, .default)],
                               cancelTitle: "Cancel".localized,
                               actionHandler: { (_ , _) in
                                self.uploadLinksToDotin()
                }, cancelActionHandler: nil)
            }
        }
    }

    /// Upload Links to Dotin
    func uploadLinksToDotin(_ showLoader: Bool = true, with credentials: (String, String)? = nil) {
        //        if !self.isResiteredUser() {
        //            self.hideLoader()
        //            self.registerNewUser()
        //            return;
        //        }

        var username: String
        var password: String

        if let credentials = credentials {
            username = credentials.0
            password = credentials.1
        } else {
            let cred = self.getCredentials()
            username = cred.0
            password = cred.1
        }

        func uploadLinks() {
            var links = [String]()
            if let images = APIManager.shared.loginSession?.user.images {
                links = images.map({ (imageObject) -> String in
                    return imageObject.url?.absoluteString ?? ""
                })
            } else {
                self.uploadingFinished(false)
                return
            }
            links = links.filter { ($0 != "") }

            let params: Parameters = [
                "link": links
            ]

            if showLoader {
                self.showLoader()
            }

            let credentialData = "\(username):\(password)".data(using: String.Encoding.utf8)!
            let base64Credentials = credentialData.base64EncodedString(options: [])
            let headers = [
                "Content-Type": "application/json",
                "Authorization": "Basic \(base64Credentials)"
            ]

            //            self.createFullAuthentication {
            Alamofire.request("http://remo-one.dotin.us/image/upload/v1.0/link",
                              method: .post,
                              parameters: params,
                              encoding: JSONEncoding.default,
                              headers: headers).responseJSON { response in
                                if let json = response.result.value as? [[String: Any]] {
                                    print("JSON: \(json)") // serialized json response
                                    self.uploadingFinished(true)
                                } else if let data = response.data {
                                    let dataString = String(data: data, encoding: .utf8)
                                    print("Data: \(String(describing: dataString))") // original server data as UTF8 string
                                    do {
                                        if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: Any]] {
                                            print("Response: \(json)")
                                            self.uploadingFinished(true)
                                        } else {
                                            self.uploadingFinished(false)
                                        }
                                    } catch {
                                        self.uploadingFinished(false)
                                    }
                                } else {
                                    self.uploadingFinished(false)
                                }
            }
            //            }
        }
        //        self.deleteOldImages(for: username, with: self.getAdminCredentials()) {
        //            uploadLinks()
        //        }
        uploadLinks()
    }

    /// Delete old images
    func deleteOldImages(for userid: String, with credentials: (String, String), _ completion: @escaping () -> Void) {
        //        self.createFullAuthentication {
        //            Alamofire.request("http://remo-one.dotin.us/image/v1.0/drop?userId=\(userid)",
        Alamofire.request("http://remo-one.dotin.us/image/manage/v1.0/drop?userId=\(userid)",
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil) .authenticate(user: credentials.0, password: credentials.1)
            .responseJSON { response in
                DispatchQueue.main.async {
                    completion()
                }
        }
        //        }
    }

    /// Create Unique login key
    /// It uses uuid and timestamp
    /// - Returns: unique login key
    func getUniqueLogin() -> String {
        let uuid = UUID().uuidString.trimString()
        let timeStamp = Date().timeIntervalSinceReferenceDate
        let login = uuid.replacingOccurrences(of: "-", with: "").appending("\(timeStamp)")
        print("New login: \(login)")
        return login
    }

    /// Create Unique skey
    /// It uses uuid and timestamp
    /// - Returns: unique skey
    func getUniqueSkey() -> String {
        let skey = self.getUniqueLogin() + "1234"
        print("New skey: \(skey)")
        return skey
    }

    /// Create full authentication for Dotin API calls
    ///
    /// - Parameter completion: completion
    func createFullAuthentication(_ completion: @escaping ()-> Void) {
        let credentials = self.getAdminCredentials()
        let username = credentials.0
        let password = credentials.1
        Alamofire.request("http://remo-one.dotin.us/",
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil) .authenticate(user: username, password: password).responseJSON { response in
                            DispatchQueue.main.async {
                                completion()
                            }
        }
    }

    /// Register User with admin credenrials
    func registerNewUser() {
        let credentials = self.getAdminCredentials()
        let username = credentials.0
        let password = credentials.1
        let login = self.getUniqueLogin()
        let skey = self.getUniqueSkey()

        func handleCorrectResponse(with id: String, skey: String) {
            DispatchQueue.main.async {
                APIManager.shared.loginSession?.user.dotinSKey = skey
                APIManager.shared.loginSession?.user.dotinUserID = id
                APIManager.shared.loginSession?.save()
                let params: [String: Any] = [
                    "dotinid": id,
                    "skey": skey
                ]
                APIManager.shared.updateUserProfileDetail(with: params, completion: { (error) in
                    self.uploadLinksToDotin(false)
                })
            }
        }

        func wrongResponse(with errorMessage: String?) {
            DispatchQueue.main.async {
                self.hideLoader()
                self.showAlert("Error".localized, message: errorMessage)
            }
        }

        func handleResponse(_ response: [String: Any]) {
            if let id = response["id"] as? String {
                handleCorrectResponse(with: id, skey: skey)
            } else {
                wrongResponse(with: "Uploading Failed!".localized)
            }
        }
        self.showLoader()
        //        self.createFullAuthentication {
        Alamofire.request("http://remo-one.dotin.us/users/manage/createWithLogin/v1.0?login=\(login)&skey=\(skey)",
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil)
            .authenticate(user: username, password: password)
            .responseJSON { response in
                if let json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                    handleResponse(json)
                } else if let data = response.data {
                    let dataString = String(data: data, encoding: .utf8)
                    print("Data: \(String(describing: dataString))") // original server data as UTF8 string
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                            handleResponse(json)
                        } else {
                            wrongResponse(with: "Uploading Failed!".localized)
                        }
                    } catch {
                        wrongResponse(with: "Uploading Failed!".localized)
                    }
                } else {
                    wrongResponse(with: "Uploading Failed!".localized)
                }
        }
    }
    //    }
}

