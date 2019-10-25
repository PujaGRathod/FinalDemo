//
//  PostCaptionVC.swift
//  WakeUppApp
//
//  Created by Admin on 30/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol PostCaptionVCDelegate {
    func didProvideCaption(caption:String)
}

class PostCaptionVC: UIViewController {

    @IBOutlet weak var txtDescription: IQTextView!
    @IBOutlet weak var tableView: UITableView!
    
    var prefilledCaption = ""
    
    var delegate : PostCaptionVCDelegate?
    
    
    var currentWordIndex:Int?
    var matchingSearchResults = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtDescription.text = prefilledCaption
        txtDescription.becomeFirstResponder()
        
        txtDescription.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    }

    @IBAction func btnOkClicked(_ sender: Any) {
        view.endEditing(true)
        delegate?.didProvideCaption(caption: txtDescription.text)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PostCaptionVC : UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        txtDescription.setNeedsDisplay()
        let selectedRange: NSRange = txtDescription.selectedRange
        let beginning: UITextPosition? = txtDescription.beginningOfDocument
        var start: UITextPosition? = nil
        if let aBeginning = beginning {
            start = txtDescription.position(from: aBeginning, offset: Int(selectedRange.location))
        }
        var end: UITextPosition? = nil
        if let aStart = start {
            end = txtDescription.position(from: aStart, offset: Int(selectedRange.length))
        }
        var textRange: UITextRange? = nil
        if let anEnd = end {
            textRange = txtDescription.tokenizer.rangeEnclosingPosition(anEnd, with: .word, inDirection: UITextLayoutDirection.left.rawValue)
        }
        var wordTyped: String? = nil
        if let aRange = textRange {
            wordTyped = txtDescription.text(in: aRange)
        }
        //NSArray *wordsInSentence = [self.text componentsSeparatedByString:@" "];(This is Bug, according to me)
        let wordsInSentence = txtDescription.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        var indexInSavedArray: Int = 0
        
        for string: String in wordsInSentence {
            let textRange:NSRange = (txtDescription.text as NSString?)!.range(of: string)
            
            if selectedRange.location >= textRange.location && selectedRange.location <= (textRange.location + textRange.length) {
                //print("STRING: \(string)")
                if string.hasPrefix("#") && string.count > 1 {
                    //print("Hashtag: \(wordTyped ?? "")")
                    refreshSearchResults(withHashTag: string)
                    currentWordIndex = indexInSavedArray
                } else {
                    matchingSearchResults = [String]()
                    tableView.reloadData()
                }
            }
            indexInSavedArray += 1
            
        }
    }
    
}

extension PostCaptionVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let tag = matchingSearchResults[indexPath.row]
        cell.textLabel?.text = "#\(tag)"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenWord = matchingSearchResults[indexPath.row]
        var array = txtDescription.text.components(separatedBy: " ")
        let indexWord = array[currentWordIndex!]
        if indexWord.hasPrefix("#") {
            array[currentWordIndex!] = "#\(chosenWord) "
        }
        let totalString = array.joined(separator: " ")
        txtDescription.text = totalString
        matchingSearchResults = [String]()
        tableView.reloadData()
    }
}

extension PostCaptionVC{
    func refreshSearchResults(withHashTag:String){
        
        /*let parameter:NSDictionary = ["service":"get_all_tags",
                                      "request":[
                                        "tag_val":"\(withHashTag.replacingOccurrences(of: "#", with: ""))"
            ],
                                      "auth" : getAuthForService()
        ]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddGroupAdmin, parameters: parameter, keyname: "", message: "", showLoader: true){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD()
            
            self.matchingSearchResults = [String]()
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.refreshSearchResults(withHashTag: withHashTag)
                })
                return
            }
            else
            {
                if responseDict!["success"] as! Int  == 0{
                    return
                }
                let arrResponse = responseDict!["data"] as! Array<[String:String]>
                for dict in arrResponse{
                    self.matchingSearchResults.append(dict["tag_val"]!)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }*/
        
        // prepare json data
        let json: [String: Any] = ["service": APIGetTags,
                                   "request": [
                                    "tag_val":"\(withHashTag.replacingOccurrences(of: "#", with: ""))"
            ],
                                   "auth" : getAuthForService()
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: Server_URL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                self.matchingSearchResults = [String]()
                if responseJSON["success"] as! Int == 1{
                    let arrResponse = responseJSON["data"] as! Array<[String:String]>
                    for dict in arrResponse{
                        self.matchingSearchResults.append(dict["tag_val"]!)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        task.resume()
        
       
    }
}
