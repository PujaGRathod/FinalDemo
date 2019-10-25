//
//  ChatAttachmentDownloader.swift
//  WakeUppApp
//
//  Created by Admin on 23/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation
import Alamofire
import SDWebImage

struct StructChatAttachment {
    var remoteURL : URL
    var saveToURL : URL
}

class ChatAttachmentDownloader
{
    static let sharedInstance = ChatAttachmentDownloader()
    
    var arrAttachments = [StructChatAttachment]()
    
    func startDownloading(remoteURL:URL, saveToURL:URL){
        if isDownloading(remoteURL:remoteURL){
            return
        }
        
        let chatAttachment = StructChatAttachment.init(remoteURL: remoteURL, saveToURL: saveToURL)
        arrAttachments.append(chatAttachment)
        performDownload()
        
    }
    
    func isDownloading(remoteURL:URL)->Bool{
        if arrAttachments.map({$0.remoteURL}).contains(remoteURL){
            return true
        }
        return false
    }
    
    private func performDownload(){
        if let lastAttachment = arrAttachments.last {
            
            Downloader.startDownloading(url: lastAttachment.remoteURL, completion: { (remoteURL, localURL) in
                if let localURL = localURL{
                    if let attachment = self.arrAttachments.first(where: {$0.remoteURL == remoteURL}){
                        
                        //Move downloaded file from Documents directory to desired local path
                        let downloadContentLocalURL = save_Content(contentURL: localURL, withName: localURL.lastPathComponent, inDirectory: attachment.saveToURL)
                        //print("downloadContentLocalURL: \(downloadContentLocalURL?.absoluteString ?? "---")")
                        
                        if isPathForImage(path: remoteURL.absoluteString){
                            do{
                                let data = try Data.init(contentsOf: localURL)
                                let img = UIImage.init(data: data)
                                SDWebImageManager.shared().saveImage(toCache: img, for: remoteURL)
                            }catch{
                                print(error.localizedDescription)
                            }
                            
                        }
                        
                        //Remove Download file from Document Dir.
                        removeFile_onURL(fileURL: localURL)
                        
                        self.postNotificationForDownloaded()
                    }
                }else{
                    //showStatusBarMessage("Download failed.")
                    self.postNotificationForFailed()
                }
                self.removeURLFromDownloading(remoteURL: remoteURL)
                
                //self.performDownload()
            })
        }
    }
    
    func removeURLFromDownloading(remoteURL:URL){
        //Remove from Download Queue
        Downloader.cancelDownloadTaskFor(url: remoteURL)
        if let index = self.arrAttachments.index(where: {$0.remoteURL == remoteURL}){
            self.arrAttachments.remove(at: index)
        }
    }
    
    func postNotificationForDownloaded(){
        postNotification(with: NC_ChatAttachmentDownloadFailed)
    }
    
    func postNotificationForFailed(){
        postNotification(with: NC_ChatAttachmentDownloadFailed)
    }
    
}
