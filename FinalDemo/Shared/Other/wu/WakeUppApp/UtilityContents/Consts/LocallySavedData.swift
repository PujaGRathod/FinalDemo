//
//  LocallySavedData.swift
//  WakeUppApp
//
//  Created by C025 on 20/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SystemConfiguration
import AVFoundation
import SwiftMessages
import CloudKit
import CoreData

import Sync
import Zip

//MARK:- Comman
func createFolder_inDirectory() {
    let fileManager = FileManager.default
    if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        
        //AppName
        let url_WakeUpp : URL = createFolder(folderName: Folder_WakeUpp, inDirectory: tDocumentDirectory)!
        UserDefaultManager.setStringToUserDefaults(value: "\(url_WakeUpp)", key: kFolderURL_WakeUpp)
        //print("url_WakeUpp : \(getURL_WakeUpp_Directory())")
        
        //Chat
        runAfterTime(time: 0.10) {
            let url_Chat : URL = createFolder(folderName: Folder_Chat, inDirectory: url_WakeUpp)!
            UserDefaultManager.setStringToUserDefaults(value: "\(url_Chat)", key: kFolderURL_Chat)
            //print("url_Chat : \(getURL_Chat_Directory())")
        }
        
        //Group
        runAfterTime(time: 0.14) {
            let url_Group : URL = createFolder(folderName: Folder_Group, inDirectory: url_WakeUpp)!
            UserDefaultManager.setStringToUserDefaults(value: "\(url_Group)", key: kFolderURL_Group)
            //print("url_Group : \(getURL_Group_Directory())")
        }
        
        //Broadcast
        runAfterTime(time: 0.18) {
            let url_Broadcast : URL = createFolder(folderName: Folder_Broadcast, inDirectory: url_WakeUpp)!
            UserDefaultManager.setStringToUserDefaults(value: "\(url_Broadcast)", key: kFolderURL_Broadcast)
            //print("url_Broadcast : \(getURL_Group_Directory())")
        }
        
        //Hidden Chat
        runAfterTime(time: 0.22) {
            let url_HiddenChatDir : URL = createFolder(folderName: Folder_HiddenChat, inDirectory: url_WakeUpp)!
            UserDefaultManager.setStringToUserDefaults(value: "\(url_HiddenChatDir)", key: kFolderURL_HinndenChat)
            //print("url_HiddenChatDir : \(url_HiddenChatDir)")
            //print("url_Broadcast : \(getURL_HiddenChat_Directory())")
        }
        
        //Chat Backup
        runAfterTime(time: 0.26) {
            let url_Backup : URL = createFolder(folderName: Folder_Backup, inDirectory: tDocumentDirectory)!
            //UserDefaultManager.setStringToUserDefaults(value: "\(url_Broadcast)", key: kFolderURL_Broadcast)
            //print("url_Backup : \(getURL_Group_Directory())")
            //print("url_Backup : \(url_Backup)")
        }
    }
    else {
        showMessage("Something was wrong.")
        //exit(1) //Exit the App OR re-install the app show mess.
    }
}

func createFolder(folderName:String, inDirectory:URL) -> URL? {
    if (inDirectory.absoluteString.count == 0) { return URL(fileURLWithPath: "") }
    
    let fileManager = FileManager.default
    let filePath =  inDirectory.appendingPathComponent("\(folderName)")
    if !fileManager.fileExists(atPath: filePath.path) {
        do {
            try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            NSLog("Couldn't create directory : \(error.localizedDescription)")
            //return nil
            return filePath as URL
        }
    }
    NSLog("create folder path : \(filePath)")
    return filePath as URL
}

//MARK: Save Content
func save_Content(withContentName : String, inDirectory: URL) -> URL {
    let contentURL =  inDirectory.appendingPathComponent(withContentName)
    return contentURL
}

func save_Content(image : UIImage, imageName : String, inDirectory:URL) -> URL? {
    let imgURL : URL = inDirectory.appendingPathComponent(imageName)
    
    let img : UIImage = image
    if let data = UIImageJPEGRepresentation(img, 1.0),
        !FileManager.default.fileExists(atPath: imgURL.path) {
        do {
            // writes the image data to disk
            try data.write(to: imgURL)
            //print("file saved")
        } catch {
            //print("error saving file:", error)
            //return nil
            return imgURL
        }
    }
    //print("imgURL: \(imgURL)")
    return imgURL
}

func save_Content(contentURL : URL, withName : String, inDirectory:URL) -> URL? {
    let saveContentURL : URL = inDirectory.appendingPathComponent(withName)
    //print("saveContentURL: \(saveContentURL)")
    
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: saveContentURL.path) {
        do {
            //Copy File and Move to currWorking Dic.
            try fileManager.copyItem(at: contentURL, to: saveContentURL)
            return saveContentURL
        }
        catch let error as NSError {
            //print("Ooops! Something went wrong: \(error)")
            //return nil
            return saveContentURL
        }
    }
    return saveContentURL
}

//MARK: Get Content

//func getAllContent(inDirectoryURL:URL) -> Array<URL> {
func getAllContent(inDirectoryURL:URL) -> [URL] {
    var arrData : [URL] = []
    
    do {
        let directoryContents = try FileManager.default.contentsOfDirectory(at: inDirectoryURL, includingPropertiesForKeys: nil, options: [])
        //print("getAllContent_inDir Total : \(directoryContents.count)")
        for filePath : URL in directoryContents {
            arrData.append(filePath)
            //print("getAllContent_inDir - FilePath: \(filePath)")
        }
    }
    catch {
        //print("Error for getting dir content: \(error)")
        //print("Error: \(error.localizedDescription)")
    }
    return arrData
}

func isFileLocallyExist(fileName:String, inDirectory:URL) -> Bool {
    let filePath = inDirectory.appendingPathComponent(fileName)
    let fileManager = FileManager.default
    
    // Check if file exists
    if fileManager.fileExists(atPath: filePath.path) { return true }
    else { return false }
}

func getURL_LocallyFileExist(fileName:String, inDirectory:URL) -> URL {
    if isFileLocallyExist(fileName: fileName, inDirectory: inDirectory) == true {
        let filePath = inDirectory.appendingPathComponent(fileName)
        return filePath
    }
    //return NSURL.init() as URL
    return inDirectory
    
}

/*func getSize_Of_LocallyFile(Name:String, inDirectory:URL) -> URL {
}
*/

//MARK: Delete Content
func removeFile(fileName : String, inDirectory:URL) -> Void {
    let contentURL =  inDirectory.appendingPathComponent(fileName)
    removeFile_onURL(fileURL: contentURL)
}

func removeFile_onURL(fileURL:URL) -> Void {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fileURL.path) {
        do {
            try fileManager.removeItem(at: fileURL)
            NSLog("SUCCESS : Remove file")
        } catch {
            NSLog("Error : Remove file.")
        }
    }
    //NSLog("SUCCESS : Remove file")
}

func renameFile(At fileURL:URL, withNewName newName:String){
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fileURL.path) {
        let fileName = fileURL.lastPathComponent
        var pathComponents = fileURL.absoluteString.components(separatedBy: "/")
        if let index = pathComponents.index(of: fileName){
            pathComponents.remove(at: index)
        }
        let destination = pathComponents.joined(separator: "/").appendingPathComponent(newName).replacingOccurrences(of: "file:", with: "")
        let destinationPath = URL.init(fileURLWithPath: destination)
        try? FileManager.default.moveItem(at: fileURL, to: destinationPath)
    }
}

//MARK:- App Dir
func getURL_WakeUpp_Directory() -> URL {
    let dirURL : URL = UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_WakeUpp).url!
    //print("getURL_WakeUpp_Directory : \(dirURL)")
    return dirURL
}

//MARK:- Chat Dir
func getURL_Chat_Directory() -> URL {
    let dirURL : URL = UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_Chat).url!
    //print("getURL_Chat_Directory : \(dirURL)")
    return dirURL
}

func getURL_ChatWithUser_Directory(countryCode:String, PhoneNo : String) -> URL {
    let strFullContactNo : String = "\(countryCode)\(PhoneNo)"
    if (strFullContactNo.count == 0) { return URL.init(string: "")! }
    
    var strFolderName : String = "\(Folder_Chat)_\(strFullContactNo)"
    strFolderName = strFolderName.replacingOccurrences(of: " ", with: "")
    
    let chatBackupFolderURL : URL = createFolder(folderName: strFolderName, inDirectory:getURL_Chat_Directory())!
    
    return chatBackupFolderURL
}

//MARK:- Group Dir
func getURL_Group_Directory() -> URL {
    let dirURL : URL = UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_Group).url!
    //print("getURL_Group_Directory : \(dirURL)")
    return dirURL
}

func getURL_GroupChat_Directory(groupID:String) -> URL {
    let strGroupName : String = "\(groupID)"
    //if (strGroupName.count == 0) { return NSURL.init().baseURL! }
    
    var strFolderName : String = "\(Folder_Group)_\(strGroupName)"
    strFolderName = strFolderName.replacingOccurrences(of: " ", with: "")
    
    let groupChatBackupFolderURL : URL = createFolder(folderName: strFolderName, inDirectory:getURL_Group_Directory())!
    return groupChatBackupFolderURL
}


//MARK:- Broadcast Dir
func getURL_Broadcast_Directory() -> URL {
    let dirURL : URL = UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_Broadcast).url!
    //print("getURL_Broadcast_Directory : \(dirURL)")
    return dirURL
}

func getURL_BroadcastChat_Directory(BroadcastID:String) -> URL {
    let strBroadcastName : String = "\(BroadcastID)"
    if (strBroadcastName.count == 0) { return NSURL.init().baseURL! }
    
    var strFolderName : String = "\(Folder_Broadcast)_\(strBroadcastName)"
    strFolderName = strFolderName.replacingOccurrences(of: " ", with: "")
    
    let BroadcastChatBackupFolderURL : URL = createFolder(folderName: strFolderName, inDirectory:getURL_Broadcast_Directory())!
    return BroadcastChatBackupFolderURL
}

//MARK:- Hidden Chat
func getURL_HiddenChat_Directory() -> URL {
    let dirURL : URL = UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_HinndenChat).url!
    //print("getURL_HiddenChat_Directory : \(dirURL)")
    return dirURL
}

//MARK:- Other
func get_fileName_asCurretDateTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmmss"
    
    var strName : String = ""
    strName = formatter.string(from: Date())
    return strName
}

func get_RandomNo(noOfDigit : Int ) -> String {
    var number = ""
    for i in 0..<noOfDigit {
        var randomNumber = arc4random_uniform(10)
        while randomNumber == 0 && i == 0 { randomNumber = arc4random_uniform(10) }
        number += "\(randomNumber)"
    }
    return number
}

//MARK:- Coredata Export
func export_Coredata_Entity(fetchRequest:NSFetchRequest<NSFetchRequestResult>) -> NSArray {
    
    let arrMess : NSMutableArray = NSMutableArray.init()
    do {
        let result_Friends = try CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest ) as! [NSManagedObject]
        for objFriends in result_Friends {
            let dicData_Friends : [String : Any] = objFriends.export() //Export in Dic.
            arrMess.add(dicData_Friends) //Stored One-by-One Dic. in array
        }
    } catch {
        //print("Error with request: \(error)")
    }
    //print("arrMess : \(arrMess.count)")
    //print("arrMess : \(arrMess)")
    return arrMess.mutableCopy() as! NSArray
}

func export_ToJSONFile(array : NSArray, strFileName: String, inDirectory:URL) {
    //Export CoreData Array in JSON File
    if (array.count == 0) { return }
    let fileUrl = inDirectory.appendingPathComponent("\(strFileName).json")
    
    // Transform array into data and save it into file
    do {
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        try data.write(to: fileUrl, options: [])
        //print("JSONFile URL: \(fileUrl)")
        
        //let zipFilePath = try Zip.quickZipFiles([fileUrl], fileName: fileUrl.lastPathComponent) // Zip
        //print("zipFilePath: \(zipFilePath)")
        
        //let unZipFilePath = try Zip.quickUnzipFile(zipFilePath)
        //print("unZipFilePath: \(unZipFilePath)")
    }
    catch {
        //print("error : \(error)")
    }
}

/*
//MARK:- Coredata Import
func import_Coredata() -> Void {
    let fileManager = FileManager.default
    if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        
        //Get Zip file in Document dir.
        let strZipFileName : String = "\(Folder_Backup).zip"
        if isFileLocallyExist(fileName: strZipFileName, inDirectory: documentDirectory) {
            //print("Zip file exist")
            
            //Unzip the backup file
            let dirURL = getURL_LocallyFileExist(fileName: strZipFileName, inDirectory: documentDirectory)
            do {
                //Unzip
                //let unZipFilePath = try Zip.quickUnzipFile(dirURL)
                let unzipFilePath = try Zip.quickUnzipFile(dirURL, progress: { (progress) in
                    //print("Unzip progress: \(progress)")
                })
                //print("unzipFilePath: \(unzipFilePath)")
                
                import_Coredata_Directory(inDirectoryURL: unzipFilePath, directoryName: Folder_Backup)
            }
            catch {
                //print("Unzip File Error : \(error)")
            }
        }
        else {
            //print("Zip file not-exist")
            showMessage("Not possible to import chat")
        }
    }
}

func import_Coredata_Directory(inDirectoryURL : URL, directoryName : String) -> Void {
    let arrDirContent = getAllContent(inDirectoryURL: inDirectoryURL)
    if (arrDirContent.count == 1) {
        let dirName : String = (arrDirContent.first?.lastPathComponent)!
        //if dirName.uppercased() == Folder_Backup.uppercased() {
        if dirName.uppercased() == directoryName.uppercased() {
            // Get All file one-by-one
            //import_Coredata_Directory(inDirectoryURL: arrDirContent.first!)
            import_Coredata_Directory(inDirectoryURL: arrDirContent.first!, directoryName: directoryName)
        }
        else {
            let arrFile = arrDirContent.first?.lastPathComponent.components(separatedBy: ".")
            if (arrFile?.last?.uppercased() == "json".uppercased()) {
                import_Coredata_ContentURL(arrContent: arrDirContent)
            }
        }
    }
    else {
        //print("Multiple file exist")
        
        for filePath : URL in arrDirContent {
            let arrFile = arrDirContent.last?.lastPathComponent.components(separatedBy: ".")
            if (arrFile?.last?.uppercased() == "json".uppercased()) {
                import_Coredata_ContentURL(arrContent: [filePath])
            }
            else {
                //Check attach content is Dir. if YES , import the content in Wakeupp dir.
            }
        }
    }
}

func import_Coredata_ContentURL(arrContent : [URL]) -> Void {
    for filePath : URL in arrContent {
        //print("file : \(filePath.lastPathComponent)")
        
        guard let data = try? Data(contentsOf: filePath) else { return }
        guard let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return }
        
        //Get JSON file name
        let arrJSONFile = filePath.lastPathComponent.components(separatedBy: ".")
        var strJSONFileName = arrJSONFile.first?.uppercased()
        strJSONFileName = strJSONFileName?.uppercased()
        
        var strEntityName : String = ""
        if (strJSONFileName == ENTITY_FRIENDS.uppercased()) { strEntityName = ENTITY_FRIENDS }
        else if (strJSONFileName == ENTITY_CHAT.uppercased()) { strEntityName = ENTITY_CHAT }
        else if (strJSONFileName == ENTITY_GROUPS.uppercased()) { strEntityName = ENTITY_GROUPS }
        else if (strJSONFileName == ENTITY_GROUP_CHAT.uppercased()) { strEntityName = ENTITY_GROUP_CHAT }
        else if (strJSONFileName == ENTITY_BROADCASTLIST.uppercased()) { strEntityName = ENTITY_BROADCASTLIST }
        else if (strJSONFileName == ENTITY_BROADCAST_MESSAGE.uppercased()) { strEntityName = ENTITY_BROADCAST_MESSAGE }
        else if (strJSONFileName == ENTITY_STORIES.uppercased()) { strEntityName = ENTITY_STORIES }
        else if (strJSONFileName == ENTITY_STORIES_VIEWERS.uppercased()) { strEntityName = ENTITY_STORIES_VIEWERS }
        else if (strJSONFileName == ENTITY_CALL_HISTORY.uppercased()) { strEntityName = ENTITY_CALL_HISTORY }
        
        //Import JSON Data in Coredata entity
        if (strEntityName.count != 0) { import_Coredata_Entity(entityName: strEntityName, jsonData: json) }
        else {
            let arrName = strJSONFileName?.components(separatedBy: "_")
            if (arrName?.first?.uppercased()  == Folder_Chat.uppercased()) {
                strEntityName = ENTITY_CHAT
                import_Coredata_Entity(entityName: strEntityName, jsonData: json)
            }
            if (arrName?.first?.uppercased()  == Folder_Group.uppercased()) {
                strEntityName = ENTITY_GROUP_CHAT
                import_Coredata_Entity(entityName: strEntityName, jsonData: json)
            }
        }
        
        //Remove file
        removeFile_onURL(fileURL: arrContent.first!)
    }
}

func import_Coredata_Entity(entityName:String, jsonData:[[String: Any]]) -> Void {
    
    let dataStack : DataStack = DataStack(modelName: "WakeUppApp")
    
    //dataStack.sync(jsonData, inEntityNamed: entityName) { (error : NSError?) in
    dataStack.sync(jsonData, inEntityNamed: entityName) { error in
        if (error != nil) {
            //print("Error : Import JSON file : \(entityName) | \(jsonData.count)")
        } else {
            //print("Success : Import JSON file : \(entityName) | \(jsonData.count)")
        }
    }
}*/

/*
// PV
func import_Coredata_HiddenChat() -> Void {
    let fileManager = FileManager.default
    if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        
        //Get Zip file in Document dir.
        let strZipFileName : String = "\(Folder_HiddenChat).zip"
        if isFileLocallyExist(fileName: strZipFileName, inDirectory: documentDirectory) {
            //print("Zip file exist")
            
            //Unzip the backup file
            let dirURL = getURL_LocallyFileExist(fileName: strZipFileName, inDirectory: documentDirectory)
            do {
                //Unzip
                //let unZipFilePath = try Zip.quickUnzipFile(dirURL)
                let unzipFilePath = try Zip.quickUnzipFile(dirURL, progress: { (progress) in
                    //print("Unzip progress: \(progress)")
                })
                //print("unzipFilePath: \(unzipFilePath)")
                
                import_Coredata_Directory(inDirectoryURL: unzipFilePath, directoryName: Folder_HiddenChat)
            }
            catch {
                //print("Unzip File Error : \(error)")
            }
        }
        else {
            //print("Zip file not-exist")
            showMessage("Not possible to import chat")
        }
    }
}
*/

/*
func import_Coredata_HiddentChat_Directory(inDirectoryURL : URL) -> Void {
    let arrDirContent = getAllContent(inDirectoryURL: inDirectoryURL)
    if (arrDirContent.count == 1) {
        let dirName : String = (arrDirContent.first?.lastPathComponent)!
        if dirName.uppercased() == Folder_Backup.uppercased() {
            // Get All file one-by-one
            import_Coredata_Directory(inDirectoryURL: arrDirContent.first!)
        }
        else {
            let arrFile = arrDirContent.first?.lastPathComponent.components(separatedBy: ".")
            if (arrFile?.last?.uppercased() == "json".uppercased()) {
                import_Coredata_ContentURL(arrContent: arrDirContent)
            }
        }
    }
    else {
        //print("Multiple file exist")
 
        for filePath : URL in arrDirContent {
            let arrFile = arrDirContent.last?.lastPathComponent.components(separatedBy: ".")
            if (arrFile?.last?.uppercased() == "json".uppercased()) {
                import_Coredata_ContentURL(arrContent: [filePath])
            }
            else {
                //Check attach content is Dir. if YES , import the content in Wakeupp dir.
            }
        }
    }
}
*/
//MARK:- iCloud
/*
func rootDirectory(forICloud completionHandler: @escaping (_: URL) -> Void) {
    DispatchQueue.global(qos: .default).async(execute: {() -> Void in
        let rootDirectory: URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(Folder_Backup)
        if rootDirectory != nil {
            if let aPath = rootDirectory?.path {
                if !FileManager.default.fileExists(atPath: aPath, isDirectory: nil) {
                    //print("Create directory")
                    if let aDirectory = rootDirectory {
                        try? FileManager.default.createDirectory(at: aDirectory, withIntermediateDirectories: true, attributes: nil)
                    }
                }
            }
        }
        DispatchQueue.main.async(execute: {() -> Void in
            completionHandler(rootDirectory!)
        })
    })
}
*/
/*
//MARK: iCloud Upload/Export Content
//PV
func iCloud_uploadContent(localURL:URL) -> Void  {
    if iCloudAvailable() {
        storeFileToiCloud(localURL: localURL)
    }
    else { showMessage("iCloud Unavailable") } //PV
}

func storeFileToiCloud(localURL:URL?) -> Void {
    // Let's get the root directory for storing the file on iCloud Drive
    rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
        //print("1. ubiquityURL = \(ubiquityURL)\n")
        
        var ubqtURL = ubiquityURL
        // We also need the 'local' URL to the file we want to store
        //print("2. localURL = \(String(describing: localURL))\n")
        
        // Now, append the local filename to the ubqtURL
        if let aComponent = localURL?.lastPathComponent {
            let aComponent1 = ubqtURL.appendingPathComponent(aComponent)
            ubqtURL = aComponent1
        }
        //print("3. ubqtURL = \(ubqtURL)\n")
        
        if let aURL = localURL {
            //Remove already exists file in iCloud
            if FileManager.default.fileExists(atPath: ubqtURL.path){
                iCloud_RemoveContent(contentName: (localURL?.lastPathComponent)!)
            }
            
            runAfterTime(time: 0.10, block: {
            //Upload file in icloud
            do {
                try FileManager.default.copyItem(at: aURL, to: ubqtURL)
                showMessage("iCloud upload success")
                
                //PV
                //Remove iCloud Upload file in Local Directory
                removeFile_onURL(fileURL: aURL)
            }
            catch{
                //print("Error occurred: \(String(describing: error))")
                showMessage("Error: \(error.localizedDescription)")
            }})
        }
    })
}*/

//MARK: iCloud Download/Import
//PV
/*
func iCloud_RestoreChatHistory() -> Void {
    if iCloudAvailable() == true {
        rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
            //print("ubiquityURL = \(ubiquityURL)\n")
            
            var ubqtURL = ubiquityURL
            ubqtURL = ubqtURL.appendingPathComponent(iCloudUpload_FileName)
            
            //Check file already exists file in iCloud
            if FileManager.default.fileExists(atPath: ubqtURL.path) {
                //print("ubqtURL = \(ubqtURL)\n")
                //print("Success : Get file already exist in iCloud - YES")
                
                let alert = UIAlertController(title: "Restore backup", message: "\nChat backup found\nRestore your chat messages and media from your phone's storage. If you don't restore now, you won't be able to restore leter.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Restore".uppercased(), style: .default, handler: { _ in
                    //print("Tap - Restore")
                    
                    let downloadContentURL = getFileFromiCloud(ubiquityURL: ubqtURL)
                    //print("downloadContentURL : \(downloadContentURL)")
                    
                    if (downloadContentURL.absoluteString != getDocumentsDirectoryURL()?.absoluteString) {
                        //import_Coredata()
                        
                        let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                        objVC.strImgURL = ""
                        objVC.strTitle = "Import chat"
                        objVC.objEnumImpExpoAction = .Import_AppChat
                        objVC.Popup_Show(onViewController: self)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Skip Restore".uppercased(), style: .destructive, handler: { _ in
                    //print("Tap - Skip Restore")
                    
                    let alert_skip = UIAlertController(title: "Skip restoring your messages and media? You won't be able to restore later.", message: nil, preferredStyle: .alert)
                    alert_skip.addAction(UIAlertAction(title: "Skip Restore".uppercased(), style: .default, handler: { _ in
                        //print("Tap - Skip Restore")
                    }))
                    alert_skip.addAction(UIAlertAction(title: "Cancel".uppercased(), style: .destructive, handler: { _ in
                        //print("Tap - Cancel")
                        iCloud_RestoreChatHistory()
                    }))
                    APP_DELEGATE.appNavigation?.visibleViewController?.present(alert_skip, animated: true, completion: nil)
                }))
                
                //self.present(alert, animated: true, completion: nil)
                APP_DELEGATE.appNavigation?.visibleViewController?.present(alert, animated: true, completion: nil)
            }
            else {
                //print("Ooops : Get file already exist in iCloud - NO")
            }
            //print("Backup not avalable in iCloud")
        })
    }
}*/

//PV
/*
func iCloud_downloadContent() -> Void {
    if iCloudAvailable() {
        rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
            let fileURL = ubiquityURL.appendingPathComponent(iCloudUpload_FileName)
            //print("fileURL : \(fileURL)")
            
            let downloadContentURL = getFileFromiCloud(ubiquityURL: fileURL)
            //print("downloadContentURL : \(downloadContentURL)")
            
            //PV
            //Download zip file and import into Coredata
            import_Coredata()
        })
    }
}*/

/*
//PV
func iCloud_Download_HiddenChat() -> Void {
    if iCloudAvailable() {
        rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
            let fileURL = ubiquityURL.appendingPathComponent("\(Folder_HiddenChat).zip")
            //print("fileURL : \(fileURL)")
            
            let downloadContentURL = getFileFromiCloud(ubiquityURL: fileURL)
            //print("downloadContentURL : \(downloadContentURL)")
            
            //PV
            if (downloadContentURL.absoluteString != getDocumentsDirectoryURL()?.absoluteString) {
                //Download zip file and import into Coredata
                import_Coredata_HiddenChat()
            }
        })
    }
}
*/

/*
//PV
func getFileFromiCloud(ubiquityURL:URL?) -> URL {
    let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last
    let myLocalFile = localDocumentsURL?.appendingPathComponent((ubiquityURL?.lastPathComponent)!)
    //print("Locally Saved File : \(myLocalFile!)\n")
    
    //Download file name related content already exists in Document directory (Local directory), To remove file in Document directory (Local directory).
    if FileManager.default.fileExists(atPath: (myLocalFile?.path)!){
        //PV
        //removeFile(fileName: (myLocalFile?.lastPathComponent)!, inDirectory: myLocalFile!)
        removeFile(fileName: (myLocalFile?.lastPathComponent)!, inDirectory: getDocumentsDirectoryURL()!)
    }
    
    do{
        try FileManager.default.copyItem(at: ubiquityURL!, to: myLocalFile!)
        //print("iCloud download ubiquityURL: \(String(describing: ubiquityURL))")
        //showMessage("iCloud download success") //PV
        
        return ubiquityURL!
    }
    catch {
        //print("getFileFromiCloud Download iCloud file Error:: \(error)")
        showMessage("Error: \(error.localizedDescription)")
        
        //return URL.init(string: "")!
        return getDocumentsDirectoryURL()!
    }
}*/

//PV
/*
//MARK: iCloud Remove/Delete
func iCloud_RemoveContent(contentName:String) -> Void {
    // Let's get the root directory for storing the file on iCloud Drive
    rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
        //print("ubiquityURL = \(ubiquityURL)\n")
        
        var ubqtURL = ubiquityURL
        ubqtURL = ubqtURL.appendingPathComponent(contentName)
        //print("ubqtURL = \(ubqtURL)\n")
        
        //Remove already exists file in iCloud
        if FileManager.default.fileExists(atPath: ubqtURL.path) {
            do {
                try FileManager.default.removeItem(at: ubqtURL)
                //print("Success : Already exist file remove in iCloud :\(ubqtURL)")
            }
            catch {
                //print("Error : Already exist file remove in iCloud : \(String(describing: error))")
            }
        }
    })
}*/
