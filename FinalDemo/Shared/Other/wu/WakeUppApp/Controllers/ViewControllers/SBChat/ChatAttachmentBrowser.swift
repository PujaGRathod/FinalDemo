//
//  ChatAttachmentBrowser.swift
//  WakeUppApp
//
//  Created by Admin on 17/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation
import MediaBrowser

class ChatAttachmentBrowser{
    
    var arrMedia = [Media]()
    var currentIndex = 0
    var startFromGrid = true
    var startingMediaURL = ""
    
    var currentLocalDirectory:URL?
    
    init(userID:String, startingFromMediaURL:String = "", currentLocalDir:URL) {
        startingMediaURL = startingFromMediaURL
        
        //PV
        //let arrMediaURLs = CoreDBManager.sharedDatabase.getPhotosAndVideosWithUser(userId: userID)
        let arrMediaURLInLocalDir = getAllContent(inDirectoryURL: currentLocalDir)
        var arrMediaURLs : [String] = []
        for localURL in arrMediaURLInLocalDir {
            if isPathForImage(path: localURL.absoluteString){ arrMediaURLs.append(localURL.absoluteString) }
            if isPathForVideo(path: localURL.absoluteString){ arrMediaURLs.append(localURL.absoluteString) }
            
            if localURL.lastPathComponent == startingFromMediaURL.lastPathComponent {
                startingMediaURL = localURL.absoluteString
            }
        }
        currentLocalDirectory = currentLocalDir
        prepareMedia(with: arrMediaURLs)
    }
    
    init(groupID:String, startingFromMediaURL:String = "", currentLocalDir:URL) {
        startingMediaURL = startingFromMediaURL
        
        //PV
        //let arrMediaURLs = CoreDBManager.sharedDatabase.getPhotosAndVideosForGroup(groupId: groupID)
        let arrMediaURLInLocalDir = getAllContent(inDirectoryURL: currentLocalDir)
        var arrMediaURLs : [String] = []
        for localURL in arrMediaURLInLocalDir {
            if isPathForImage(path: localURL.absoluteString) { arrMediaURLs.append(localURL.absoluteString) }
            if isPathForVideo(path: localURL.absoluteString) { arrMediaURLs.append(localURL.absoluteString) }
            
            if localURL.lastPathComponent == startingFromMediaURL.lastPathComponent {
                startingMediaURL = localURL.absoluteString
            }
        }
        
        currentLocalDirectory = currentLocalDir
        prepareMedia(with: arrMediaURLs)
    }
    
    init(broadcastListID:String, startingFromMediaURL:String = "", currentLocalDir:URL) {
        startingMediaURL = startingFromMediaURL
        
        //PV
        //let arrMediaURLs = CoreDBManager.sharedDatabase.getPhotosAndVideosForBroadcastList(broadcastListId: broadcastListID)
        let arrMediaURLInLocalDir = getAllContent(inDirectoryURL: currentLocalDir)
        var arrMediaURLs : [String] = []
        for localURL in arrMediaURLInLocalDir {
            if isPathForImage(path: localURL.absoluteString) { arrMediaURLs.append(localURL.absoluteString) }
            if isPathForVideo(path: localURL.absoluteString) { arrMediaURLs.append(localURL.absoluteString) }
            
            if localURL.lastPathComponent == startingFromMediaURL.lastPathComponent {
                startingMediaURL = localURL.absoluteString
            }
        }
        
        currentLocalDirectory = currentLocalDir
        prepareMedia(with: arrMediaURLs)
    }
    
    func prepareMedia(with mediaURLs:[String]){
        
        if let index = mediaURLs.index(of: startingMediaURL){
            currentIndex = index
        }
        
        var arrMediaURLs = [String]()
        for mediaURL in mediaURLs{
            if isPathForVideo(path: mediaURL){
                let url = mediaURL.toUrl!
                /*if isFileLocallySaved(fileUrl: url){
                    arrMediaURLs.append(getLocallySavedFileURL(with: url)!.absoluteString)
                }else{
                    arrMediaURLs.append(mediaURL)
                }*/
                if isFileLocallyExist(fileName: url.lastPathComponent, inDirectory: self.currentLocalDirectory!){
                    arrMediaURLs.append(getURL_LocallyFileExist(fileName: url.lastPathComponent, inDirectory: self.currentLocalDirectory!).absoluteString)
                }else{
                    arrMediaURLs.append(mediaURL)
                }
            }else{
                arrMediaURLs.append(mediaURL)
            }
        }
        
        arrMedia = [Media]()
        for strURL in arrMediaURLs /*mediaURLs*/ {
            if isPathForVideo(path: strURL){
                let fileName = strURL.lastPathComponent
                let replacedFileName = fileName.components(separatedBy: ".").first! + "_thumb.jpg"
                var strThumbURL = strURL.replacingOccurrences(of: fileName, with: replacedFileName)
                
                if strThumbURL.contains("http") == false{
                    strThumbURL = Get_Chat_Attachment_URL + replacedFileName
                }
                
                var fileURL = strURL.toUrl!
                
                if currentLocalDirectory != nil{
                    if isFileLocallyExist(fileName: fileURL.lastPathComponent, inDirectory: currentLocalDirectory!) {
                        fileURL = currentLocalDirectory!.appendingPathComponent(fileURL.lastPathComponent)
                    }
                }
                
                else{
                    if isFileLocallySaved(fileUrl: fileURL){
                        fileURL = getLocallySavedFileURL(with: fileURL)!
                    }
                }
                
                let video = Media(videoURL: fileURL, previewImageURL: strThumbURL.toUrl)
                arrMedia.append(video)
            }else if isPathForImage(path: strURL){
                let photo = Media(url: strURL.toUrl!)
                arrMedia.append(photo)
            }
        }
    }
    
    func openBrowser(){
        //let browser = MediaBrowser(delegate: self)
        let browser = MediaBrowser.init(delegate: self)
        browser.displayActionButton = true
        browser.displayMediaNavigationArrows = true
        browser.displaySelectionButtons = false
        browser.alwaysShowControls = false
        browser.zoomPhotosToFill = true
        browser.enableGrid = true
        browser.startOnGrid = startFromGrid
        browser.enableSwipeToDismiss = true
        browser.autoPlayOnAppear = false
        browser.cachingImageCount = 2
        browser.setCurrentIndex(at: currentIndex)
        browser.delegate = self
        APP_DELEGATE.appNavigation?.pushViewController(browser, animated: true)
    }
    
}

extension ChatAttachmentBrowser : MediaBrowserDelegate{
    func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int {
        return arrMedia.count
    }
    
    func media(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        return arrMedia[index]
    }
    
    func thumbnail(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        return arrMedia[index]
    }
}
