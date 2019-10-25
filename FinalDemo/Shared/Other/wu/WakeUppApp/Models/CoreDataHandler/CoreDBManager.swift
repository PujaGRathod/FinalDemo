//
//  CD_Messages+CoreDataClass.swift
//
//
//  Created by Admin on 31/03/18.
//
//

import UIKit
import CoreData
import Contacts

class CoreDBManager: NSObject {
    
    static let sharedDatabase = CoreDBManager()
    var persistentContainerQueue = OperationQueue.init()
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        
        persistentContainerQueue.maxConcurrentOperationCount = 1
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "WakeUppApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
       
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("WakeUppApp.sqlite")
        NSLog("Database Path: \(url)")

        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        //TO RESOLVE ERROR : NSMergeConflict for NSManagedObject
        managedObjectContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType);
        
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    @objc func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
               
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDBManager {
    //MARK: CHAT MESSAGES
    func saveMessageInLocalDB(objmessgae:StructChat) -> Bool {
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Messages>(entityName: ENTITY_CHAT)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CHAT, in: objContext)!
        let predicate = NSPredicate(format:"id == %@",objmessgae.kid)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Messages]
            if(results.count > 0) {
                let chatObj = results[0] as CD_Messages
                chatObj.id = objmessgae.kid
                chatObj.createddate = objmessgae.kcreateddate
                chatObj.platform = objmessgae.kdevicetype
                chatObj.textmessage = objmessgae.kchatmessage
                chatObj.receiverid = objmessgae.kreceiverid
                chatObj.senderid = objmessgae.ksenderid
                chatObj.sendername = objmessgae.ksendername
                chatObj.isdeleted = objmessgae.kisdeleted
                chatObj.isread = objmessgae.kisread
                chatObj.mediaurl = objmessgae.kmediaurl
                chatObj.messagetype = objmessgae.kmessagetype
                chatObj.chatid = objmessgae.kchatid
                chatObj.image = objmessgae.kuserprofile
                chatObj.is_online = objmessgae.kuseronline
                chatObj.last_login = objmessgae.kuserlastlogin
                chatObj.username = objmessgae.kusername
                chatObj.user_id = objmessgae.kuserid
                chatObj.parentid = objmessgae.parentid
                chatObj.mediasize = objmessgae.mediasize
                chatObj.receivetime = objmessgae.receivetime
                chatObj.readtime = objmessgae.readtime
            }
            else {
                let  chatObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_CHAT,into:managedObjectContext) as? CD_Messages)!
                chatObj.id = objmessgae.kid
                chatObj.createddate = objmessgae.kcreateddate
                chatObj.platform = objmessgae.kdevicetype
                chatObj.textmessage = objmessgae.kchatmessage
                chatObj.receiverid = objmessgae.kreceiverid
                chatObj.senderid = objmessgae.ksenderid
                chatObj.sendername = objmessgae.ksendername
                chatObj.isdeleted = objmessgae.kisdeleted
                chatObj.isread = objmessgae.kisread
                chatObj.mediaurl = objmessgae.kmediaurl
                chatObj.messagetype = objmessgae.kmessagetype
                chatObj.chatid = objmessgae.kchatid
                chatObj.image = objmessgae.kuserprofile
                chatObj.is_online = objmessgae.kuseronline
                chatObj.last_login = objmessgae.kuserlastlogin
                chatObj.username = objmessgae.kusername
                chatObj.user_id = objmessgae.kuserid
                chatObj.parentid = objmessgae.parentid
                chatObj.mediasize = objmessgae.mediasize
                //UPDATE FRIENDS TABLE'S RECORD FOR USERID
                chatObj.receivetime = objmessgae.receivetime
                chatObj.readtime = objmessgae.readtime
                updateFriend(for: objmessgae)
                
            }
            self.saveContext()
            return true
        } catch {
            return false
        }
    }
    
    func replaceMessageInLocalDB(objmessgae:StructChat, with messageId:String) {
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Messages>(entityName: ENTITY_CHAT)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CHAT, in: objContext)!
        let predicate = NSPredicate(format:"id == %@", messageId)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Messages]
            if(results.count > 0)
            {
                let chatObj = results[0] as CD_Messages
                chatObj.id = objmessgae.kid
                chatObj.createddate = objmessgae.kcreateddate
                chatObj.platform = objmessgae.kdevicetype
                chatObj.textmessage = objmessgae.kchatmessage
                chatObj.receiverid = objmessgae.kreceiverid
                chatObj.senderid = objmessgae.ksenderid
                chatObj.sendername = objmessgae.ksendername
                chatObj.isdeleted = objmessgae.kisdeleted
                chatObj.isread = objmessgae.kisread
                chatObj.mediaurl = objmessgae.kmediaurl
                chatObj.messagetype = objmessgae.kmessagetype
                chatObj.chatid = objmessgae.kchatid
                chatObj.image = objmessgae.kuserprofile
                chatObj.is_online = objmessgae.kuseronline
                chatObj.last_login = objmessgae.kuserlastlogin
                chatObj.username = objmessgae.kusername
                chatObj.user_id = objmessgae.kuserid
                chatObj.parentid = objmessgae.parentid
                chatObj.mediasize = objmessgae.mediasize
                chatObj.readtime = objmessgae.readtime
                chatObj.receivetime = objmessgae.receivetime
            }
            self.saveContext()
        }
        catch
        {
            
        }
    }
    
    func getChatMessagesForUserID(userId:String, includeDeleted:Bool) -> [StructChat]{
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Messages>(entityName: ENTITY_CHAT)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CHAT, in: objContext)!
        fetchRequest.entity = disentity
        let predicate1 = NSPredicate(format:"senderid == %@",userId)
        let predicate2 = NSPredicate(format:"receiverid == %@",userId)
        fetchRequest.predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Messages]
            if(results.count > 0)
            {
                var arr = [StructChat]()
                for result  in results {
                    var friendObj = StructChat(dictionary: [:])
                    friendObj.kid = result.id ?? ""
                    friendObj.kcreateddate = result.createddate ?? ""
                    friendObj.kdevicetype = result.platform ?? ""
                    friendObj.kchatmessage = result.textmessage ?? ""
                    friendObj.kreceiverid = result.receiverid ?? ""
                    friendObj.ksenderid = result.senderid ?? ""
                    friendObj.ksendername = result.sendername ?? ""
                    friendObj.kisdeleted = result.isdeleted ?? ""
                    friendObj.kisread = result.isread ?? ""
                    friendObj.kmessagetype = result.messagetype ?? ""
                    friendObj.kmediaurl = result.mediaurl ?? ""
                    friendObj.kchatid = result.chatid ?? ""
                    friendObj.kuserprofile = result.image ?? ""
                    friendObj.kuseronline = result.is_online ?? ""
                    friendObj.kuserlastlogin = result.last_login ?? ""
                    friendObj.kusername = result.username ?? ""
                    friendObj.kuserid = result.user_id ?? ""
                    friendObj.isstarred = result.isstarred ?? "0"
                    friendObj.parentid = result.parentid ?? "0"
                    friendObj.mediasize = result.mediasize ?? "0 KB"
                    friendObj.readtime = result.readtime ?? ""
                    friendObj.receivetime = result.receivetime ?? ""
                    if includeDeleted == false {
                        if result.isdeleted! != "1"{
                            arr.append(friendObj)
                        }
                    }else{
                        arr.append(friendObj)
                    }
                }
                return arr
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    
    func updateReadStatusForChatMessage(chatId:String, readStatus:String){
        let operation = BlockOperation.init {
            
            let predicate = NSPredicate(format:"id = %@", chatId)
            
            let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
            
            fetchRequest.propertiesToUpdate = [ "isread" : readStatus ]
            fetchRequest.predicate = predicate
            fetchRequest.resultType = .updatedObjectsCountResultType
            do{
                _ = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
                self.perform(#selector(self.saveContext), with: nil, afterDelay: 2.5)
            }catch{
            }
        }
        self.persistentContainerQueue.addOperation(operation)
    }
    
    func updateReadStatus(newReadStatus:String, forChatIDs chatIDs:[String]){
        let predicate = NSPredicate(format:"id IN %@", chatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
        fetchRequest.propertiesToUpdate = [ "isread" : newReadStatus ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            _ = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            self.perform(#selector(self.saveContext), with: nil, afterDelay: 2.5)
        }catch{
        }
    }
    
    func updateTimeForchat(readtime:String, receivetime:String,forChatIDs chatIDs:[String]){
        let predicate = NSPredicate(format:"id IN %@", chatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
        fetchRequest.propertiesToUpdate = [ "readtime" : readtime,"receivetime":receivetime ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            _ = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            self.perform(#selector(self.saveContext), with: nil, afterDelay: 2.5)
        }catch{
        }
    }
    
    func updateReadStatusForFriendListByChatId(_ senderId:String, _ receiverId:String, _ newReadStatus:String,chatid:String)
    {
        let predi0_1 = NSPredicate(format:"receiverid == %@", receiverId)
        let predi0_2 = NSPredicate(format:"senderid == %@", senderId)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", senderId)
        let predi1_2 = NSPredicate(format:"senderid == %@", receiverId)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        
        //Manage if Delete status = "1" , no take any action.
        do {
            let fetchRequest = NSFetchRequest<CD_Friends>(entityName: ENTITY_FRIENDS)
            fetchRequest.predicate = predicate
            let results = try managedObjectContext.fetch(fetchRequest)
            if (results.count != 0) {
                let friendObj = results[0] as CD_Friends
                if (friendObj.isdeleted == "1" ) { return }
            }
        }
        catch {
            //---> Manage Error..
        }
        
        fetchRequest.propertiesToUpdate = [ "isread" : newReadStatus ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            _ = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            self.saveContext()
            
            /*UPDATE READSTATUS IN MESSAGES TABLE*/
            var predicate3 = NSPredicate.init()
            predicate3 = NSPredicate(format:"id == %@", chatid)
            predicate3 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate, predicate3])
            
            let fetchRequest2 = NSBatchUpdateRequest(entityName : ENTITY_CHAT)
            fetchRequest2.propertiesToUpdate = [ "isread" :  newReadStatus == "1" ? "2" : "1"]
            fetchRequest2.predicate = predicate3
            fetchRequest2.resultType = .updatedObjectsCountResultType
            do{
                //print(predicate3)
                _ = try managedObjectContext.execute(fetchRequest2) as! NSBatchUpdateResult
                self.saveContext()
                postNotification(with: NC_ReadReceiptUpdate, andUserInfo: ["sid":senderId,"rid":receiverId])
            }catch{
                
            }
            
        }catch{
        }
    }
    
    func deleteForEveryoneChatMessage(chatIDs:[String]){
        let predicate = NSPredicate(format:"id IN %@", chatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
        
        fetchRequest.propertiesToUpdate = [
            "textmessage" : "This message was deleted.".base64Encoded!,
            "messagetype" : "0",
            "mediaurl" : ""
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            //print("deleteForEveryoneChatMessage : Success")
            self.perform(#selector(self.saveContext), with: nil, afterDelay: 2.5)
        }catch{
            //print("deleteForEveryoneChatMessage : Error : \(error.localizedDescription)")
        }
        saveContext()
    }
    
    func deleteForMeChatMessage(chatIDs:[String]){
        let predicate = NSPredicate(format:"id IN %@", chatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
        
        fetchRequest.propertiesToUpdate = [
            "isdeleted" : "1"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            
            //print("deleteForMeChatMessage : Success")
            //self.perform(#selector(self.saveContext), with: nil, afterDelay: 0.5)
            self.saveContext()
        }catch{
            //print("deleteForMeChatMessage : Error : \(error.localizedDescription)")            
        }
    }
    
    func deleteAllChatMessagesWith(userId:String){
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
        
        fetchRequest.propertiesToUpdate = [ "isdeleted" : "1" ]
        
        let predicate1 = NSPredicate(format:"senderid == %@",userId)
        let predicate2 = NSPredicate(format:"receiverid == %@",userId)
        fetchRequest.predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            //print("Success : \(result)")
            self.saveContext()
        }catch{
            //print("Error: \(error.localizedDescription)")
        }
        
        let updateRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        updateRequest.propertiesToUpdate = [
            "chatid" : "0",
            //"isdeleted" : "0",
            "isdeleted" : "1",
            //"isread" : "0",
            "isread" : "",
            "mediaurl" : "",
            //"messagetype" : "0",
            "messagetype" : "",
            "platform" : "0",
            "textmessage" : "",
            "unreadCount" : "0"
        ]
        updateRequest.predicate = fetchRequest.predicate
        updateRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(updateRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            //print("result: \(result)")
            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
   
    func starUnstarChatMessage(chatIDs:[String], shouldStar:Bool){
        let predicate = NSPredicate(format:"id IN %@", chatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
        
        fetchRequest.propertiesToUpdate = [
            "isstarred" : shouldStar == true ? "1" : "0"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            //print(result)
            //print(predicate)
            //print("Success")
            //self.perform(#selector(self.saveContext), with: nil, afterDelay: 0.5)
            self.saveContext()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func getStarredChatMessages() -> [StructChat] {
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Messages>(entityName: ENTITY_CHAT) //PV //02-08-2018 05:37pm
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CHAT, in: objContext)!
        fetchRequest.entity = disentity
        let predicate = NSPredicate(format:"isstarred == %@","1")
        fetchRequest.predicate = predicate
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Messages]
            if(results.count > 0)
            {
                var arr = [StructChat]()
                for result  in results {
                    var friendObj = StructChat(dictionary: [:])
                    friendObj.kid = result.id ?? ""
                    friendObj.kcreateddate = result.createddate ?? ""
                    friendObj.kdevicetype = result.platform ?? ""
                    friendObj.kchatmessage = result.textmessage ?? ""
                    friendObj.kreceiverid = result.receiverid ?? ""
                    friendObj.ksenderid = result.senderid ?? ""
                    friendObj.ksendername = result.sendername ?? ""
                    friendObj.kisdeleted = result.isdeleted ?? ""
                    friendObj.kisread = result.isread ?? ""
                    friendObj.kmessagetype = result.messagetype ?? ""
                    friendObj.kmediaurl = result.mediaurl ?? ""
                    friendObj.kchatid = result.chatid ?? ""
                    friendObj.kuserprofile = result.image ?? ""
                    friendObj.kuseronline = result.is_online ?? ""
                    friendObj.kuserlastlogin = result.last_login ?? ""
                    friendObj.kusername = result.username ?? ""
                    friendObj.kuserid = result.user_id ?? ""
                    friendObj.isstarred = result.isstarred ?? "0"
                    friendObj.parentid = result.parentid ?? "0"
                    friendObj.mediasize = result.mediasize ?? "0 KB"
                    friendObj.readtime = result.readtime ?? ""
                    friendObj.receivetime = result.receivetime ?? ""
                    
                    if result.isdeleted! != "1"{
                        arr.append(friendObj)
                    }
                }
                return arr
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    func getPhotosAndVideosWithUser(userId:String)->[String]{
        let messages = getChatMessagesForUserID(userId: userId, includeDeleted: false)
        var msgs = messages.filter({$0.kmessagetype == "1"})
        msgs = msgs.filter({isPathForVideo(path: $0.kmediaurl)||isPathForImage(path: $0.kmediaurl)}).sorted(by: { Float($0.kid)! < Float($1.kid)! })
        return msgs.map({$0.kmediaurl})
    }
    
    func getDocumentForUser(userId:String, filename: String) -> StructChat {
        let messages = getChatMessagesForUserID(userId: userId, includeDeleted: false)
        var msgs = messages.filter({$0.kmessagetype == "1"})
 
        msgs = msgs.filter({ (isPathForImage(path: $0.kmediaurl) != true)
            || (isPathForVideo(path: $0.kmediaurl) != true)
            //|| (isPathForContact(path: $0.kmediaurl) != true)
            //||(isPathForAudio(path: $0.kmediaurl) != true)
        })
 
        msgs = msgs.filter({$0.kmediaurl.lastPathComponent == filename})
        
        return msgs.first ?? StructChat.init(dictionary: [:])
    }
    
    func personalChat_GetChatMessages(userId:String, includeDeleted:Bool, fetchLimit:NSInteger, fetchOffSet:NSInteger) -> [StructChat] {
        //return getChatMessagesForUserID(userId: userId, includeDeleted: includeDeleted)
       
        if fetchLimit == 0 { return [] }
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Messages>(entityName: ENTITY_CHAT)
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.fetchLimit = fetchLimit
        
        if fetchOffSet < 0 { fetchRequest.fetchOffset = 0 }
        else { fetchRequest.fetchOffset = fetchOffSet }
        
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CHAT, in: objContext)!
        fetchRequest.entity = disentity
        let predicate1 = NSPredicate(format:"senderid == %@",userId)
        let predicate2 = NSPredicate(format:"receiverid == %@",userId)
        fetchRequest.predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Messages]
            if(results.count > 0)
            {
                var arr = [StructChat]()
                for result  in results {
                    var friendObj = StructChat(dictionary: [:])
                    friendObj.kid = result.id ?? ""
                    friendObj.kcreateddate = result.createddate ?? ""
                    friendObj.kdevicetype = result.platform ?? ""
                    friendObj.kchatmessage = result.textmessage ?? ""
                    friendObj.kreceiverid = result.receiverid ?? ""
                    friendObj.ksenderid = result.senderid ?? ""
                    friendObj.ksendername = result.sendername ?? ""
                    friendObj.kisdeleted = result.isdeleted ?? ""
                    friendObj.kisread = result.isread ?? ""
                    friendObj.kmessagetype = result.messagetype ?? ""
                    friendObj.kmediaurl = result.mediaurl ?? ""
                    friendObj.kchatid = result.chatid ?? ""
                    friendObj.kuserprofile = result.image ?? ""
                    friendObj.kuseronline = result.is_online ?? ""
                    friendObj.kuserlastlogin = result.last_login ?? ""
                    friendObj.kusername = result.username ?? ""
                    friendObj.kuserid = result.user_id ?? ""
                    friendObj.isstarred = result.isstarred ?? "0"
                    friendObj.parentid = result.parentid ?? "0"
                    friendObj.mediasize = result.mediasize ?? "0 KB"
                    friendObj.readtime = result.readtime ?? ""
                    friendObj.receivetime = result.receivetime ?? ""
                    
                    if includeDeleted == false {
                        if result.isdeleted! != "1"{
                            arr.append(friendObj)
                        }
                    }else{
                        arr.append(friendObj)
                    }
                }
                return arr
            }
        }
        catch { return [] }
        return []
    }
    
    func personalChat_Get_StarredChatMessages_with(userId : String) -> [StructChat] {
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Messages>(entityName: ENTITY_CHAT)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CHAT, in: objContext)!
        fetchRequest.entity = disentity
        
        let predicate1 = NSPredicate(format:"senderid == %@",userId)
        let predicate2 = NSPredicate(format:"receiverid == %@",userId)
        let predicate3 = NSPredicate(format:"isstarred == 1 AND isdeleted == 0")
        //fetchRequest.predicate = predicate
        fetchRequest.predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2,predicate3])
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Messages]
            if(results.count > 0)
            {
                var arr = [StructChat]()
                for result  in results {
                    var friendObj = StructChat(dictionary: [:])
                    friendObj.kid = result.id ?? ""
                    friendObj.kcreateddate = result.createddate ?? ""
                    friendObj.kdevicetype = result.platform ?? ""
                    friendObj.kchatmessage = result.textmessage ?? ""
                    friendObj.kreceiverid = result.receiverid ?? ""
                    friendObj.ksenderid = result.senderid ?? ""
                    friendObj.ksendername = result.sendername ?? ""
                    friendObj.kisdeleted = result.isdeleted ?? ""
                    friendObj.kisread = result.isread ?? ""
                    friendObj.kmessagetype = result.messagetype ?? ""
                    friendObj.kmediaurl = result.mediaurl ?? ""
                    friendObj.kchatid = result.chatid ?? ""
                    friendObj.kuserprofile = result.image ?? ""
                    friendObj.kuseronline = result.is_online ?? ""
                    friendObj.kuserlastlogin = result.last_login ?? ""
                    friendObj.kusername = result.username ?? ""
                    friendObj.kuserid = result.user_id ?? ""
                    friendObj.isstarred = result.isstarred ?? "0"
                    friendObj.parentid = result.parentid ?? "0"
                    friendObj.mediasize = result.mediasize ?? "0 KB"
                    friendObj.readtime = result.readtime ?? ""
                    friendObj.receivetime = result.receivetime ?? ""
                    
                    if result.isdeleted! != "1"{
                        arr.append(friendObj)
                    }
                }
                return arr
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    func personalChat_Update_DeleteStatus(deleteStatus:String, forChatIDs chatIDs:[String]){
        let predicate = NSPredicate(format:"id IN %@", chatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
        fetchRequest.propertiesToUpdate = [ "isdeleted" : deleteStatus ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //print("personalChat_Update_DeleteStatus : Success : \(result)")
            self.perform(#selector(self.saveContext), with: nil, afterDelay: 2.5)
        }catch{
            //print("personalChat_Update_DeleteStatus : Error : \(error.localizedDescription)")
        }
    }
    
    func personalChat_Delete_AllChatMessages_ExceptStarred_with(userId:String) {
        
        let arrMsgs : [StructChat] = getChatMessagesForUserID(userId: userId, includeDeleted: false)
        var arrDeleteMess : [String] = []
        for obj in arrMsgs {
            if obj.isstarred != "1" { arrDeleteMess.append(obj.kid) }
        }
        personalChat_Update_DeleteStatus(deleteStatus: "1", forChatIDs: arrDeleteMess)
        //------------->
        
        //Update Friend List
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_CHAT)
        let predicate1 = NSPredicate(format:"senderid == %@",userId)
        let predicate2 = NSPredicate(format:"receiverid == %@",userId)
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        let updateRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        updateRequest.propertiesToUpdate = [ "chatid" : "0",
                                             "isdeleted" : "1",
                                             "isread" : "",
                                             "mediaurl" : "",
                                             "messagetype" : "",
                                             "platform" : "0",
                                             "textmessage" : "",
                                             "unreadCount" : "0"]
        
        fetchRequest.predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        updateRequest.predicate = fetchRequest.predicate
        updateRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(updateRequest) as! NSBatchUpdateResult
            //print("result: \(result)")
            self.saveContext()
        }catch{
            //--> Code
            //print("Error: --")
        }
    }
    
    //MARK:- CALL HISTORY
    func saveCallHistoryInLocalDB(objcall: StructCallHistory) -> Bool {
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_CallHistory>(entityName: ENTITY_CALL_HISTORY)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CALL_HISTORY, in: objContext)!
        let predicate = NSPredicate(format:"call_id == %@",objcall.call_id)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_CallHistory]
            if(results.count > 0)
            {
                let callHistoryObj = results[0] as CD_CallHistory
                callHistoryObj.image = objcall.image
                callHistoryObj.name = objcall.name
                callHistoryObj.status = objcall.status
                callHistoryObj.date = objcall.date
                callHistoryObj.is_video_call = objcall.is_video_call
                callHistoryObj.call_from = objcall.call_from
                callHistoryObj.call_to = objcall.call_to
                callHistoryObj.call_id = objcall.call_id
                callHistoryObj.isseen = "0"
            }
            else
            {
                let callHistoryObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_CALL_HISTORY,into:managedObjectContext) as? CD_CallHistory)!
                callHistoryObj.image = objcall.image
                callHistoryObj.name = objcall.name
                callHistoryObj.status = objcall.status
                callHistoryObj.date = objcall.date
                callHistoryObj.is_video_call = objcall.is_video_call
                callHistoryObj.call_from = objcall.call_from
                callHistoryObj.call_to = objcall.call_to
                callHistoryObj.call_id = objcall.call_id
                callHistoryObj.isseen = "0"
                
                //UPDATE CALL HISTORY RECORD
                updateCallHsitoryFor(objcall: objcall)
            }
            self.saveContext()
            return true
            
        } catch {
            return false
        }
    }
    
    func updateIsSeenHistory() {
        let predicate = NSPredicate(format:"isseen = 0")
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_CALL_HISTORY)
        
        fetchRequest.propertiesToUpdate = [
            "isseen":"1"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //print(result)
            //print(predicate)
            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func updateCallHsitoryFor(objcall: StructCallHistory){
        let predicate = NSPredicate(format:"call_id = %@", objcall.call_id)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_CALL_HISTORY)
        
        fetchRequest.propertiesToUpdate = [
            "image" : objcall.image,
            "name" : objcall.name,
            "status" : objcall.status,
            "date" : objcall.date,
            "is_video_call" : objcall.is_video_call,
            "call_from" : objcall.call_from,
            "call_to" : objcall.call_to,
            "call_id" : objcall.call_id,
            "isseen":"0"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //print(result)
            //print(predicate)
            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func getCallHistory() -> NSMutableArray{
        
        self.updateIsSeenHistory()
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_CallHistory>(entityName: ENTITY_CALL_HISTORY)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CALL_HISTORY, in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_CallHistory]
            if(results.count > 0)
            {
                var arr = NSMutableArray()
                for result  in results {
                    
                    var callObj = StructCallHistory(dictionary: [:])
                    callObj.image = result.image ?? ""
                    callObj.name = result.name ?? ""
                    callObj.status = result.status ?? ""
                    callObj.date = result.date ?? ""
                    callObj.is_video_call = result.is_video_call ?? ""
                    callObj.call_from = result.call_from ?? ""
                    callObj.call_to = result.call_to ?? ""
                    callObj.call_id = result.call_id ?? ""
                    callObj.isseen = result.isseen ?? ""
                    arr.add(callObj)
                }
                
                var arrCalls = arr as! [StructCallHistory]
                arrCalls = arrCalls.sorted(by: {Int($0.call_id)! > Int($1.call_id)! })
                arr = NSMutableArray(array: arrCalls)
                return arr
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    func deleteSingleCallHistory(callID:String){
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let predicate = NSPredicate(format:"call_id = %@", callID)
        let fetchRequest = NSFetchRequest<CD_CallHistory>(entityName: ENTITY_CALL_HISTORY)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CALL_HISTORY, in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_CallHistory]
            for object in results {
                CoreDBManager.sharedDatabase.managedObjectContext.delete(object)
            }
            self.saveContext()
        }
        catch
        {
            
        }
    }
    
    func deleteAllCallHistoryFromLocalDB()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_CALL_HISTORY)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.managedObjectContext.execute(deleteRequest)
            try self.managedObjectContext.save()
        } catch {
            print (error)
        }
    }
    
    func getHistoryId(callId:String)->StructCallHistory?{
        let callHis = getCallHistory() as! [StructCallHistory]
        return callHis.first(where: {$0.call_id == callId})!
    }
    
    func getUnReadCountCall()-> String{
        
        let objContext = self.managedObjectContext
        
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CALL_HISTORY, in: objContext)!
        
        let fetchRequest = NSFetchRequest<CD_CallHistory>(entityName: ENTITY_CALL_HISTORY)
        fetchRequest.entity = disentity
        
        
        let predicate = NSPredicate.init(format: "isseen == %@", "0")
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_CallHistory]
            return "\(results.count)"
        }
        catch{
            return "0"
        }
    }
    
    //MARK:- GROUP MESSAGES
    
    func saveGroupMessageInLocalDB(objmessgae:StructGroupChat) -> Bool
    {
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_GroupMessages>(entityName: ENTITY_GROUP_CHAT)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_GROUP_CHAT, in: objContext)!
        let predicate = NSPredicate(format:"id == %@",objmessgae.id)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_GroupMessages]
            if(results.count > 0)
            {
                let chatObj = results[0] as CD_GroupMessages
                chatObj.id = objmessgae.id
                chatObj.groupid = objmessgae.groupid
                chatObj.senderid = objmessgae.senderid
                chatObj.sendername = objmessgae.sendername
                chatObj.receiverid = objmessgae.receiverid
                chatObj.textmessage = objmessgae.textmessage
                chatObj.isread = objmessgae.isread
                chatObj.platform = objmessgae.platform
                chatObj.isdeleted = objmessgae.isdeleted
                chatObj.createddate = objmessgae.createddate
                chatObj.messagetype = objmessgae.messagetype
                chatObj.mediaurl = objmessgae.mediaurl
                chatObj.isstarred = objmessgae.isstarred
                chatObj.parent_id = objmessgae.parent_id
                chatObj.countrycode = objmessgae.countrycode
                chatObj.phonenumber = objmessgae.phonenumber
                chatObj.mediasize = objmessgae.mediasize
            }
            else
            {
                
                let  chatObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_GROUP_CHAT,into:managedObjectContext) as? CD_GroupMessages)!
                chatObj.id = objmessgae.id
                chatObj.groupid = objmessgae.groupid
                chatObj.senderid = objmessgae.senderid
                chatObj.sendername = objmessgae.sendername
                chatObj.receiverid = objmessgae.receiverid
                chatObj.textmessage = objmessgae.textmessage
                chatObj.isread = objmessgae.isread
                chatObj.platform = objmessgae.platform
                chatObj.isdeleted = objmessgae.isdeleted
                chatObj.createddate = objmessgae.createddate
                chatObj.messagetype = objmessgae.messagetype
                chatObj.mediaurl = objmessgae.mediaurl
                chatObj.isstarred = objmessgae.isstarred
                chatObj.parent_id = objmessgae.parent_id
                chatObj.countrycode = objmessgae.countrycode
                chatObj.phonenumber = objmessgae.phonenumber
                chatObj.mediasize = objmessgae.mediasize
                //UPDATE GROUP TABLE'S RECORD FOR GROUPID
                updateGroupFor(groupMessage: objmessgae)
                
                
            }
            self.saveContext()
            return true
            
        }
        catch
        {
            return false
        }
    }
    
    func replaceGroupMessageInLocalDB(objmessgae:StructGroupChat, with messageId:String){
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_GroupMessages>(entityName: ENTITY_GROUP_CHAT)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_GROUP_CHAT, in: objContext)!
        let predicate = NSPredicate(format:"id == %@", messageId)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_GroupMessages]
            if(results.count > 0)
            {
                let chatObj = results[0] as CD_GroupMessages
                chatObj.id = objmessgae.id
                chatObj.groupid = objmessgae.groupid
                chatObj.senderid = objmessgae.senderid
                chatObj.sendername = objmessgae.sendername
                chatObj.receiverid = objmessgae.receiverid
                chatObj.textmessage = objmessgae.textmessage
                chatObj.isread = objmessgae.isread
                chatObj.platform = objmessgae.platform
                chatObj.isdeleted = objmessgae.isdeleted
                chatObj.createddate = objmessgae.createddate
                chatObj.messagetype = objmessgae.messagetype
                chatObj.mediaurl = objmessgae.mediaurl
                chatObj.isstarred = objmessgae.isstarred
                chatObj.parent_id = objmessgae.parent_id
                chatObj.countrycode = objmessgae.countrycode
                chatObj.phonenumber = objmessgae.phonenumber
            }
            self.saveContext()
        }
        catch
        {
            
        }
    }
   
    func getMessagesForGroupID(groupId:String, includeDeleted:Bool) -> [StructGroupChat]
    {
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_GroupMessages>(entityName: ENTITY_GROUP_CHAT) //PV //02-08-2018
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_GROUP_CHAT, in: objContext)!
        fetchRequest.entity = disentity
        let predicate = NSPredicate(format:"groupid == %@",groupId)
        fetchRequest.predicate = predicate
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_GroupMessages]
            if(results.count > 0)
            {
                var arr = [StructGroupChat]()
                for result  in results {
                    var friendObj = StructGroupChat(dictionary: [:])
                    friendObj.id = result.id ?? ""
                    friendObj.groupid = result.groupid ?? ""
                    friendObj.senderid = result.senderid ?? ""
                    friendObj.sendername = result.sendername ?? ""
                    friendObj.receiverid = result.receiverid ?? ""
                    friendObj.textmessage = result.textmessage ?? ""
                    friendObj.isread = result.isread ?? ""
                    friendObj.platform = result.platform ?? ""
                    friendObj.isdeleted = result.isdeleted ?? ""
                    friendObj.createddate = result.createddate ?? ""
                    friendObj.messagetype = result.messagetype ?? ""
                    friendObj.mediaurl = result.mediaurl ?? ""
                    friendObj.isstarred = result.isstarred ?? "0"
                    friendObj.parent_id = result.parent_id ?? "0"
                    friendObj.countrycode = result.countrycode ?? "0"
                    friendObj.phonenumber = result.phonenumber ?? "0"
                    friendObj.mediasize = result.mediasize ?? "0 KB"
                    /*if includeDeleted == false {
                        if result.isdeleted! != "1"{
                            arr.append(friendObj)
                        }
                    }else{
                        arr.append(friendObj)
                    }*/
                    
                    //------------------------->
                    //Get only own ID included to do not show newly added user to previous message
                    let arrReceivedIDs : NSArray = friendObj.receiverid.components(separatedBy: ",") as NSArray
                    let strUserID : String = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
                    
                    if arrReceivedIDs.contains(strUserID)
                    {
                        if includeDeleted == false {
                            if result.isdeleted! != "1" { arr.append(friendObj) }
                        }
                        else
                        {
                            arr.append(friendObj)
                        }
                    }
                    //<-------------------------
                }
                return arr
            }
        }
        catch {
            return []
        }
        return []
    }
    
    func deleteAllGroupChatMessagesOf(groupId:String){

        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_GROUP_CHAT)
        
        fetchRequest.propertiesToUpdate = [
            "isdeleted" : "1",
            //PV
            "mediaurl" : "",
            "textmessage":"",
            "messagetype":"",
            //"unreadCount" = ""
        ]
        let predicate = NSPredicate(format:"groupid == %@",groupId)
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
             //print("result: \(result)")
            self.saveContext()
        }catch{
//            print(error.localizedDescription)
        }
        
        let updateRequest = NSBatchUpdateRequest(entityName: ENTITY_GROUPS)
        updateRequest.propertiesToUpdate = [
            "lastMessageId" : "0",
            "lastMediaURL" : "",
            "lastMessage" : "",
            "lastMessageType" : "0",
            "lastMessageSenderId" : "0",
            "lastMessageReceiverIds" : "0",
        ]
        let updatePredicate = NSPredicate(format: "group_id = %@", groupId)
        updateRequest.predicate = updatePredicate
        updateRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try self.managedObjectContext.execute(updateRequest) as! NSBatchUpdateResult
             //print("result: \(result)")
            self.saveContext()
        }catch{
//            print(error.localizedDescription)
        }
    }
    
    func starUnstarGroupMessage(groupChatIDs:[String], shouldStar:Bool){
        let predicate = NSPredicate(format:"id IN %@", groupChatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_GROUP_CHAT)
        
        fetchRequest.propertiesToUpdate = [
            "isstarred" : shouldStar == true ? "1" : "0"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            print(result)
            print(predicate)
            //print("Success")
            //self.perform(#selector(self.saveContext), with: nil, afterDelay: 0.5)
            self.saveContext()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func getStarredGroupMessages() -> [StructGroupChat]{
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_GroupMessages>(entityName: ENTITY_GROUP_CHAT) //PV //02-08-2018
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_GROUP_CHAT, in: objContext)!
        fetchRequest.entity = disentity
        let predicate = NSPredicate(format:"isstarred == %@","1")
        fetchRequest.predicate = predicate
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_GroupMessages]
            if(results.count > 0)
            {
                var arr = [StructGroupChat]()
                for result  in results {
                    var friendObj = StructGroupChat(dictionary: [:])
                    friendObj.id = result.id ?? ""
                    friendObj.groupid = result.groupid ?? ""
                    friendObj.senderid = result.senderid ?? ""
                    friendObj.sendername = result.sendername ?? ""
                    friendObj.receiverid = result.receiverid ?? ""
                    friendObj.textmessage = result.textmessage ?? ""
                    friendObj.isread = result.isread ?? ""
                    friendObj.platform = result.platform ?? ""
                    friendObj.isdeleted = result.isdeleted ?? ""
                    friendObj.createddate = result.createddate ?? ""
                    friendObj.messagetype = result.messagetype ?? ""
                    friendObj.mediaurl = result.mediaurl ?? ""
                    friendObj.isstarred = result.isstarred ?? "0"
                    friendObj.parent_id = result.parent_id ?? "0"
                    friendObj.countrycode = result.countrycode ?? "0"
                    friendObj.phonenumber = result.phonenumber ?? "0"
                    friendObj.mediasize = result.mediasize ?? "0 KB"
                    if result.isdeleted! != "1"{
                        arr.append(friendObj)
                    }
                }
                return arr
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    func deleteForEveryoneGroupChatMessage(groupChatIDs:[String]){
        let predicate = NSPredicate(format:"id IN %@", groupChatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_GROUP_CHAT)
        
        fetchRequest.propertiesToUpdate = [
            "textmessage" : "This message was deleted.".base64Encoded!,
            "messagetype" : "0",
            "mediaurl" : ""
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            //print("result: \(result)")
//            print(predicate)
//            //print("Success")
            self.perform(#selector(self.saveContext), with: nil, afterDelay: 2.5)
        }catch{
//            print(error.localizedDescription)
        }
        saveContext()
    }
    
    func deleteForMeGroupChatMessage(groupChatIDs:[String]){
        let predicate = NSPredicate(format:"id IN %@", groupChatIDs)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_GROUP_CHAT)
        
        fetchRequest.propertiesToUpdate = [ "isdeleted" : "1" ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            //print("deleteForMeGroupChatMessage - result: \(result)")
//            print(predicate)
//            //print("Success")
            //self.perform(#selector(self.saveContext), with: nil, afterDelay: 0.5)
            self.saveContext()
        }catch{
//            print(error.localizedDescription)
        }
    }
    
    func getPhotosAndVideosForGroup(groupId:String)->[String]{
        let messages = getMessagesForGroupID(groupId: groupId, includeDeleted: false)
        var msgs = messages.filter({$0.messagetype == "1"})
        msgs = msgs.filter({isPathForVideo(path: $0.mediaurl)||isPathForImage(path: $0.mediaurl)}).sorted(by: { Float($0.id)! < Float($1.id)! })
        return msgs.map({$0.mediaurl})
    }
    
    func getDocumentForGroup(groupId:String, filename: String) -> StructGroupChat {
        let messages = getMessagesForGroupID(groupId: groupId, includeDeleted: false)
        var msgs = messages.filter({$0.messagetype == "1"})
        
        msgs = msgs.filter({ (isPathForImage(path: $0.mediaurl) != true)
            || (isPathForVideo(path: $0.mediaurl) != true)
            //|| (isPathForContact(path: $0.kmediaurl) != true)
            //||(isPathForAudio(path: $0.kmediaurl) != true)
        })
        msgs = msgs.filter({$0.mediaurl.lastPathComponent == filename})
        
        return msgs.first ?? StructGroupChat.init(dictionary: [:])
    }
    
    func GroupChat_Get_StarredChatMessages_with(GroupId : String) -> [StructGroupChat] {
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_GroupMessages>(entityName: ENTITY_GROUP_CHAT) //PV //02-08-2018
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_GROUP_CHAT, in: objContext)!
        fetchRequest.entity = disentity
        let predicate = NSPredicate(format:"isstarred == %@","1")
        let predicate3 = NSPredicate(format:"isdeleted == 0")
        fetchRequest.predicate = predicate
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_GroupMessages]
            if(results.count > 0)
            {
                var arr = [StructGroupChat]()
                for result  in results {
                    var friendObj = StructGroupChat(dictionary: [:])
                    friendObj.id = result.id ?? ""
                    friendObj.groupid = result.groupid ?? ""
                    friendObj.senderid = result.senderid ?? ""
                    friendObj.sendername = result.sendername ?? ""
                    friendObj.receiverid = result.receiverid ?? ""
                    friendObj.textmessage = result.textmessage ?? ""
                    friendObj.isread = result.isread ?? ""
                    friendObj.platform = result.platform ?? ""
                    friendObj.isdeleted = result.isdeleted ?? ""
                    friendObj.createddate = result.createddate ?? ""
                    friendObj.messagetype = result.messagetype ?? ""
                    friendObj.mediaurl = result.mediaurl ?? ""
                    friendObj.isstarred = result.isstarred ?? "0"
                    friendObj.parent_id = result.parent_id ?? "0"
                    friendObj.countrycode = result.countrycode ?? "0"
                    friendObj.phonenumber = result.phonenumber ?? "0"
                    friendObj.mediasize = result.mediasize ?? "0 KB"
                    if result.isdeleted! != "1"{
                        arr.append(friendObj)
                    }
                }
                return arr
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    func GroupChat_Delete_AllChatMessages_ExceptStarred_with(groupId:String) {
        let arrMsgs : [StructGroupChat] = getMessagesForGroupID(groupId: groupId, includeDeleted: false)
        var arrDeleteMess : [String] = []
        for obj in arrMsgs {
            if obj.isstarred != "1" { arrDeleteMess.append(obj.id) }
        }
        deleteForMeGroupChatMessage(groupChatIDs: arrDeleteMess)
        //------------->
        
        //Update Group List
        let updateRequest = NSBatchUpdateRequest(entityName: ENTITY_GROUPS)
        updateRequest.propertiesToUpdate = [
            "lastMessageId" : "0",
            "lastMediaURL" : "",
            "lastMessage" : "",
            "lastMessageType" : "0",
            "lastMessageSenderId" : "0",
            "lastMessageReceiverIds" : "0",
        ]
        let updatePredicate = NSPredicate(format: "group_id = %@", groupId)
        updateRequest.predicate = updatePredicate
        updateRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try self.managedObjectContext.execute(updateRequest) as! NSBatchUpdateResult
            //print("result: \(result)")
            self.saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK:- FRIEND LIST
    func saveFriendInLocalDB(objFriend:StructChat) -> Bool{
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Friends>(entityName: ENTITY_FRIENDS)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_FRIENDS, in: objContext)!
        let predicate = NSPredicate(format:"user_id == %@",objFriend.kuserid)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Friends]
            if(results.count > 0)
            {
                let friendObj = results[0] as CD_Friends
                
                //PV | Date : 21-08-2018 | Manag for clear and Delete chat manage
                if (friendObj.isdeleted == "1" ) {
                    friendObj.chatid = "0"
                    friendObj.isdeleted = "1"
                    friendObj.isread = "0"
                    friendObj.messagetype = ""
                    friendObj.mediaurl = ""
                    friendObj.messagetype = ""
                    friendObj.textmessage = ""
                    friendObj.platform = "0"
                }
                else {
                    friendObj.id = objFriend.kid
                    friendObj.createddate = objFriend.kcreateddate
                    friendObj.platform = objFriend.kdevicetype
                    friendObj.textmessage = objFriend.kchatmessage
                    friendObj.receiverid = objFriend.kreceiverid
                    friendObj.senderid = objFriend.ksenderid
                    friendObj.isdeleted = objFriend.kisdeleted
                    friendObj.isread = objFriend.kisread
                    friendObj.mediaurl = objFriend.kmediaurl
                    friendObj.messagetype = objFriend.kmessagetype
                    friendObj.chatid = objFriend.kchatid
                    friendObj.image = objFriend.kuserprofile
                    friendObj.is_online = objFriend.kuseronline
                    friendObj.last_login = objFriend.kuserlastlogin
                    friendObj.username = objFriend.kusername
                    friendObj.user_id = objFriend.kuserid
                    friendObj.muted_by_me = objFriend.kmuted_by_me
                    friendObj.countrycode = objFriend.kcountrycode
                    friendObj.phonenumber = objFriend.kphonenumber
                    friendObj.blocked_contacts = objFriend.blocked_contacts
                    //friendObj.ishidden = objFriend.ishidden
                    friendObj.bio = objFriend.bio //PV
                    //--> PV
                    friendObj.about_privacy = objFriend.about_privacy
                    friendObj.photo_privacy = objFriend.photo_privacy
                    friendObj.read_receipts_privacy = objFriend.read_receipts_privacy
                    friendObj.status_privacy = objFriend.status_privacy
                    friendObj.lastseen_privacy = objFriend.lastseen_privacy
                }
            }
            else {
                let  friendObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_FRIENDS,into:managedObjectContext) as? CD_Friends)!
                friendObj.id = objFriend.kid
                friendObj.createddate = objFriend.kcreateddate
                friendObj.platform = objFriend.kdevicetype
                friendObj.textmessage = objFriend.kchatmessage
                friendObj.receiverid = objFriend.kreceiverid
                friendObj.senderid = objFriend.ksenderid
                friendObj.isdeleted = objFriend.kisdeleted
                friendObj.isread = objFriend.kisread
                friendObj.mediaurl = objFriend.kmediaurl
                friendObj.messagetype = objFriend.kmessagetype
                friendObj.chatid = objFriend.kchatid
                friendObj.image = objFriend.kuserprofile
                friendObj.is_online = objFriend.kuseronline
                friendObj.last_login = objFriend.kuserlastlogin
                friendObj.username = objFriend.kusername
                friendObj.user_id = objFriend.kuserid
                if objFriend.ksenderid != objFriend.kuserid
                {
                    friendObj.unreadCount = "0"
                }
                else
                {
                     friendObj.unreadCount = "1"
                }
                friendObj.muted_by_me = objFriend.kmuted_by_me
                friendObj.countrycode = objFriend.kcountrycode
                friendObj.phonenumber = objFriend.kphonenumber
                friendObj.blocked_contacts = objFriend.blocked_contacts
                //friendObj.ishidden = objFriend.ishidden
                friendObj.bio = objFriend.bio //PV
                
                //--> PV
                friendObj.about_privacy = objFriend.about_privacy
                friendObj.photo_privacy = objFriend.photo_privacy
                friendObj.read_receipts_privacy = objFriend.read_receipts_privacy
                friendObj.status_privacy = objFriend.status_privacy
                friendObj.lastseen_privacy = objFriend.lastseen_privacy
            }
            self.saveContext()
            return true
            
        }
        catch
        {
            return false
        }
    }
    
    func getFriendList(includeHiddens:Bool) -> NSMutableArray{
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Friends>(entityName: ENTITY_FRIENDS)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_FRIENDS, in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Friends]
            if(results.count > 0)
            {
                var arr = NSMutableArray()
                for result  in results
                {
                    var friendObj = StructChat(dictionary: [:])
                    friendObj.kid = result.id ?? ""
                    friendObj.kcreateddate = result.createddate ?? ""
                    friendObj.kdevicetype = result.platform ?? ""
                    friendObj.kchatmessage = result.textmessage ?? ""
                    friendObj.kreceiverid = result.receiverid ?? ""
                    friendObj.ksenderid = result.senderid ?? ""
                    friendObj.kisdeleted = result.isdeleted ?? ""
                    friendObj.kisread = result.isread ?? ""
                    friendObj.kmessagetype = result.messagetype ?? ""
                    friendObj.kmediaurl = result.mediaurl ?? ""
                    friendObj.kchatid = result.chatid ?? ""
                    friendObj.kuserprofile = result.image ?? ""
                    friendObj.kuseronline = result.is_online ?? ""
                    friendObj.kuserlastlogin = result.last_login ?? ""
                    friendObj.kusername = result.username ?? ""
                    friendObj.kuserid = result.user_id ?? ""
                    friendObj.kunreadcount = result.unreadCount ?? "0"
                    friendObj.kmuted_by_me = result.muted_by_me ?? ""
                    friendObj.kcountrycode = result.countrycode ?? ""
                    friendObj.kphonenumber = result.phonenumber ?? ""
                    friendObj.blocked_contacts = result.blocked_contacts ?? ""
                    friendObj.ishidden = result.ishidden ?? "0"
                    friendObj.ispinned = result.ispinned ?? "0"
                    friendObj.bio = result.bio ?? ""
                    friendObj.about_privacy = result.about_privacy ?? ""
                    friendObj.photo_privacy = result.photo_privacy ?? ""
                    friendObj.read_receipts_privacy = result.read_receipts_privacy ?? ""
                    friendObj.status_privacy = result.status_privacy ?? ""
                    friendObj.lastseen_privacy = result.lastseen_privacy ?? ""
                    if includeHiddens == false{
                        if friendObj.ishidden == "0" { arr.add(friendObj) }
                    }
                    else {
                        arr.add(friendObj)
                    }
                }
                
                var arrFriends = arr as! [StructChat]
                arrFriends = arrFriends.sorted(by: {Float($0.kid)! > Float($1.kid)! })
                
                //COMMENT FOLLOWING 3 LINES IF SORT FAILS
                /*let pinnedFriends = arrFriends.filter({$0.ispinned == "1"})
                let unPinnedFriends = arrFriends.filter({$0.ispinned == "0"})
                arrFriends = pinnedFriends + unPinnedFriends*/
                
                arr = NSMutableArray(array: arrFriends)
                return arr
            }
        }
        catch { return [] }
        return []
    }
    
    func getHiddenFriendList() -> [StructChat] {
        let allFriends = getFriendList(includeHiddens: true) as! [StructChat]
        let hiddenFriends = allFriends.filter({$0.ishidden == "1"})
        return hiddenFriends
    }
    
    func getFriendById(userID:String)->StructChat?{
        if userID.count > 0 {
            let friendList = getFriendList(includeHiddens: true) as! [StructChat]
            return friendList.first(where: {$0.kuserid == userID || $0.ksenderid == userID || $0.kreceiverid == userID})
        }
        return StructChat.init(dictionary: [:])        
    }
    
    func getFriendInfoByPhoneNo(userPhoneNo:String) -> StructChat? {
        if userPhoneNo.count > 0 {
            let friendList = getFriendList(includeHiddens: true) as! [StructChat]
            return friendList.first(where: {$0.kphonenumber == userPhoneNo})
        }
        return StructChat.init(dictionary: [:])
    }
    
    func get_UserInfo (userID:String) -> StructChat? {
        if userID.count > 0 {
            let arrAppUser = getFriendIdList_ID()
            if (arrAppUser.contains(userID) == false) { return StructChat.init(dictionary: [:]) }
            
            let friendList = getFriendList(includeHiddens: true) as! [StructChat]
            return friendList.first(where: {$0.kuserid == userID })
        }
        return StructChat.init(dictionary: [:])
    }
    
    func getFriendIdList_ID() -> [String] {
        let friendList = getFriendList(includeHiddens: true) as! [StructChat]
        let arr = friendList.map({ $0.kuserid })
        if arr.count > 0 { return arr }
        return []
    }
    
    func getFriendIdList_PhoneNo() -> [String] {
        let friendList = getFriendList(includeHiddens: true) as! [StructChat]
        
        //let arr = friendList.map({ $0.kphonenumber })
        //return arr
        
        if friendList.count > 0 {
            var arr : [String] = []
            for obj in friendList {
                arr.append(obj.kphonenumber)
                let fullPhoneNo : String = "\(obj.kcountrycode)\(obj.kphonenumber)"
                arr.append(fullPhoneNo)
            }
            return arr
        }
        return []
    }
    
   
    
    func updateFriend(for ChatMessage:StructChat) {
        let predi0_1 = NSPredicate(format:"receiverid == %@", ChatMessage.kreceiverid)
        let predi0_2 = NSPredicate(format:"senderid == %@", ChatMessage.ksenderid)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", ChatMessage.ksenderid)
        let predi1_2 = NSPredicate(format:"senderid == %@", ChatMessage.kreceiverid)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
                 let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        fetchRequest.propertiesToUpdate = [
            "chatid" : ChatMessage.kchatid,
            "createddate" : ChatMessage.kcreateddate,
            "isdeleted" : ChatMessage.kisdeleted,
            "isread" : ChatMessage.kisread,
            "mediaurl" : ChatMessage.kmediaurl,
            "messagetype" : ChatMessage.kmessagetype,
            "platform" : ChatMessage.kdevicetype,
            "textmessage" : ChatMessage.kchatmessage,
            "senderid" : ChatMessage.ksenderid,
            "receiverid" : ChatMessage.kreceiverid,
            //"unreadCount" : ""
            //PV
            "about_privacy" : ChatMessage.about_privacy,
            "photo_privacy" : ChatMessage.photo_privacy,
            "read_receipts_privacy" : ChatMessage.read_receipts_privacy,
            "status_privacy" : ChatMessage.status_privacy,
            "lastseen_privacy" : ChatMessage.lastseen_privacy
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            //print("updateFriend result: \(result)")
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func getUnreadCountForFriend(chatUser:StructChat) -> Int{
        let friends = getFriendList(includeHiddens: true) as! [StructChat]
        for friend in friends{
            if (chatUser.kreceiverid == friend.kreceiverid && chatUser.ksenderid == friend.ksenderid) || (chatUser.kreceiverid == friend.ksenderid && chatUser.ksenderid == friend.kreceiverid) {
                return Int(friend.kunreadcount)!
            }
        }
        return 0
    }
    
    func increaseUnreadCount(for chatUser:StructChat){
        
        let predi0_1 = NSPredicate(format:"receiverid == %@", chatUser.kreceiverid)
        let predi0_2 = NSPredicate(format:"senderid == %@", chatUser.ksenderid)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", chatUser.ksenderid)
        let predi1_2 = NSPredicate(format:"senderid == %@", chatUser.kreceiverid)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        
        let unreadCount = getUnreadCountForFriend(chatUser: chatUser)
        
        fetchRequest.propertiesToUpdate = [
            "chatid" : chatUser.kchatid,
            "id" : chatUser.kid,
            "createddate" : chatUser.kcreateddate,
            "isdeleted" : chatUser.kisdeleted,
            "isread" : chatUser.kisread,
            "mediaurl" : chatUser.kmediaurl,
            "messagetype" : chatUser.kmessagetype,
            "platform" : chatUser.kdevicetype,
            "textmessage" : chatUser.kchatmessage,
            "senderid" : chatUser.ksenderid,
            "receiverid" : chatUser.kreceiverid,
            "unreadCount" : "\(unreadCount + 1)" //INCREASE HERE
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            _ = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func setUnreadCount(To:Int, forChatMessage chatUser:StructChat){
        let predi0_1 = NSPredicate(format:"receiverid == %@", chatUser.kreceiverid)
        let predi0_2 = NSPredicate(format:"senderid == %@", chatUser.ksenderid)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", chatUser.ksenderid)
        let predi1_2 = NSPredicate(format:"senderid == %@", chatUser.kreceiverid)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        
        fetchRequest.propertiesToUpdate = [
            "unreadCount" : "\(To)"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            _ = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }
        catch {
            //--->
        }
    }
    
    func updateReadTimeForFriendList(senderId:String, receiverId:String, newReadStatus:String,readtime:String)
    {
        let predi0_1 = NSPredicate(format:"receiverid == %@", receiverId)
        let predi0_2 = NSPredicate(format:"senderid == %@", senderId)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", senderId)
        let predi1_2 = NSPredicate(format:"senderid == %@", receiverId)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        var predicate3 = NSPredicate.init()
        let fetchRequest2 = NSBatchUpdateRequest(entityName : ENTITY_CHAT)
        if newReadStatus == "1"
        {
             predicate3 =  NSPredicate.init(format: "isread = 0" )
            let predicate4 = NSPredicate(format: "receivetime == %@", "")
             predicate3 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate, predicate3,predicate4])
             fetchRequest2.propertiesToUpdate = [ "isread" : newReadStatus,"receivetime" : readtime]
        }
        else
        {
            predicate3 =  NSPredicate.init(format: "isread == 1 OR isread = 0" )
            let predicate4 = NSPredicate(format: "readtime == %@", "")
            predicate3 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate, predicate3,predicate4])
             fetchRequest2.propertiesToUpdate = [ "isread" : newReadStatus,"readtime" : readtime]
        }
        
        fetchRequest2.predicate = predicate3
        fetchRequest2.resultType = .updatedObjectsCountResultType
        do{
            _ = try managedObjectContext.execute(fetchRequest2) as! NSBatchUpdateResult
            self.saveContext()
        }catch{
            
        }
    }
    
    func updateReadStatusForFriendList(senderId:String, receiverId:String, newReadStatus:String){
        let predi0_1 = NSPredicate(format:"receiverid == %@", receiverId)
        let predi0_2 = NSPredicate(format:"senderid == %@", senderId)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", senderId)
        let predi1_2 = NSPredicate(format:"senderid == %@", receiverId)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        
        //Manage if Delete status = "1" , no take any action.
        do {
            let fetchRequest = NSFetchRequest<CD_Friends>(entityName: ENTITY_FRIENDS)
            fetchRequest.predicate = predicate
            let results = try managedObjectContext.fetch(fetchRequest)
            if (results.count != 0) {
            let friendObj = results[0] as CD_Friends
            if (friendObj.isdeleted == "1" ) { return }
            }
        }
        catch {
            //---> Manage Error..
        }
        
        fetchRequest.propertiesToUpdate = [
            "isread" : newReadStatus
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            _ = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            self.saveContext()
            
            /*UPDATE READSTATUS IN MESSAGES TABLE*/
            var predicate3 = NSPredicate.init()
            if newReadStatus == "1"{
                predicate3 = NSPredicate.init(format: "isread == 0" )
                predicate3 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate, predicate3])
            }else{
                predicate3 = NSPredicate.init(format: "isread == 1" )
                predicate3 = NSCompoundPredicate.init(type: .and, subpredicates: [predicate, predicate3])
            }
            
            let fetchRequest2 = NSBatchUpdateRequest(entityName : ENTITY_CHAT)
            fetchRequest2.propertiesToUpdate = [ "isread" : newReadStatus]
            fetchRequest2.predicate = predicate3
            fetchRequest2.resultType = .updatedObjectsCountResultType
            do{
                //print(predicate3)
                _ = try managedObjectContext.execute(fetchRequest2) as! NSBatchUpdateResult
                self.saveContext()
            }catch{
                
            }
            
        }catch{
        }
    }
    
    func hideUnhidePersonalChat(for chatUser:StructChat, shouldHide:Bool){
        let predi0_1 = NSPredicate(format:"receiverid == %@", chatUser.kreceiverid)
        let predi0_2 = NSPredicate(format:"senderid == %@", chatUser.ksenderid)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", chatUser.ksenderid)
        let predi1_2 = NSPredicate(format:"senderid == %@", chatUser.kreceiverid)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        fetchRequest.propertiesToUpdate = [
            "ishidden" : shouldHide ? "1" : "0",
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func pinUnpinPersonalChat(for chatUser:StructChat, shouldPin:Bool){
        let predi0_1 = NSPredicate(format:"receiverid == %@", chatUser.kreceiverid)
        let predi0_2 = NSPredicate(format:"senderid == %@", chatUser.ksenderid)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", chatUser.ksenderid)
        let predi1_2 = NSPredicate(format:"senderid == %@", chatUser.kreceiverid)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        fetchRequest.propertiesToUpdate = [
            "ispinned" : shouldPin ? "1" : "0",
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            //print("result : \(result)")
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func amIMutedByUser(receiverId:String)->Bool{
        let friendList = getFriendList(includeHiddens: true) as! [StructChat]
        for friend in friendList{
            if friend.kuserid == receiverId{
                let mutedList = friend.kmuted_by_me.components(separatedBy: ",")
                if mutedList.contains(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)){
                    return true
                }
            }
        }
        return false
    }
    
    //MARK:- GROUP LIST
    
    func saveGroupListInDB(objGroup:StructGroupDetails) -> Bool{
        let strGroupID : String = TRIM(string: objGroup.group_id)
        if (strGroupID.count == 0 ) { return false }
    
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Groups>(entityName: ENTITY_GROUPS)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_GROUPS, in: objContext)!
        let predicate = NSPredicate(format:"group_id == %@",objGroup.group_id)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Groups]
            if(results.count > 0)
            {
                let groupObj = results[0] as CD_Groups
                //PV | Date : 21-08-2018 | Manag for clear and Delete chat manage
                if (groupObj.isdelete == "1" ) {
                    groupObj.isdelete = "1"
                    groupObj.lastMediaURL = ""
                    groupObj.lastMessage = ""
                    groupObj.lastMessageType = ""
                    groupObj.unreadCount = ""
                }
                else {
                    groupObj.group_id = objGroup.group_id
                    groupObj.name = objGroup.name
                    groupObj.icon = objGroup.icon
                    groupObj.members = objGroup.members
                    groupObj.muted_by = objGroup.muted_by
                    groupObj.createdby = objGroup.createdby
                    groupObj.admins = objGroup.admins
                    groupObj.isalladmin = objGroup.isalladmin
                    groupObj.isdelete = objGroup.isdelete
                    
                    groupObj.lastMessageId = objGroup.lastMessageId
                    groupObj.lastMediaURL = objGroup.lastMediaURL
                    groupObj.lastMessage = objGroup.lastMessage
                    groupObj.lastMessageType = objGroup.lastMessageType
                    groupObj.lastMessageDate = objGroup.lastMessageDate
                    groupObj.lastMessageSenderId = objGroup.lastMessageSenderId
                    groupObj.lastMessageReceiverIds = objGroup.lastMessageReceiverIds
                    
                    groupObj.edit_permission = objGroup.edit_permission
                    groupObj.msg_permission = objGroup.msg_permission
                }
                //groupObj.ishidden = objGroup.ishidden
            }
            else
            {
                let  groupObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_GROUPS,into:managedObjectContext) as? CD_Groups)!
                groupObj.group_id = objGroup.group_id
                groupObj.name = objGroup.name
                groupObj.icon = objGroup.icon
                groupObj.members = objGroup.members
                groupObj.muted_by = objGroup.muted_by
                groupObj.createdby = objGroup.createdby
                groupObj.admins = objGroup.admins
                groupObj.isalladmin = objGroup.isalladmin
                groupObj.isdelete = objGroup.isdelete
                
                groupObj.lastMessageId = objGroup.lastMessageId
                groupObj.lastMediaURL = objGroup.lastMediaURL
                groupObj.lastMessage = objGroup.lastMessage
                groupObj.lastMessageType = objGroup.lastMessageType
                groupObj.lastMessageDate = objGroup.lastMessageDate
                groupObj.lastMessageSenderId = objGroup.lastMessageSenderId
                groupObj.lastMessageReceiverIds = objGroup.lastMessageReceiverIds
                groupObj.unreadCount = "0"
                
                groupObj.edit_permission = objGroup.edit_permission
                groupObj.msg_permission = objGroup.msg_permission
                
                //groupObj.ishidden = objGroup.ishidden
            }
            self.saveContext()
            return true
            
        }
        catch
        {
            return false
        }
    }
    
    func getGroupsList(includeHiddens:Bool) -> NSMutableArray{
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Groups>(entityName: ENTITY_GROUPS)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_GROUPS, in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Groups]
            if(results.count > 0)
            {
                let arr = NSMutableArray()
                for result  in results {
                    
                    let strGroupID : String = TRIM(string: result.group_id ?? "")
                    if (strGroupID.count == 0 ) {
                        //Remove Record
                         CoreDBManager.sharedDatabase.managedObjectContext.delete(result)
                    }
                    else {
                    var groupObj = StructGroupDetails(dictionary: [:])
                    groupObj.group_id = result.group_id ?? ""
                    groupObj.name = result.name ?? ""
                    groupObj.icon = result.icon ?? ""
                    groupObj.members = result.members ?? ""
                    groupObj.muted_by = result.muted_by ?? ""
                    groupObj.createdby = result.createdby ?? ""
                    groupObj.admins = result.admins ?? ""
                    groupObj.isalladmin = result.isalladmin ?? ""
                    groupObj.isdelete = result.isdelete ?? ""
                    
                    groupObj.lastMessageId = result.lastMessageId ?? ""
                    groupObj.lastMediaURL = result.lastMediaURL ?? ""
                    groupObj.lastMessage = result.lastMessage ?? ""
                    groupObj.lastMessageType = result.lastMessageType ?? ""
                    groupObj.lastMessageDate = result.lastMessageDate ?? ""
                    groupObj.lastMessageSenderId = result.lastMessageSenderId ?? ""
                    groupObj.lastMessageReceiverIds = result.lastMessageReceiverIds ?? ""
                    groupObj.unreadCount = result.unreadCount ?? "0"
                    
                    groupObj.edit_permission = result.edit_permission ?? "0"
                    groupObj.msg_permission = result.msg_permission ?? "0"
                    
                    groupObj.ishidden = result.ishidden ?? "0"
                    groupObj.ispinned = result.ispinned ?? "0"
                    
                    if groupObj.icon.contains("http") == false{
                        groupObj.icon = Get_Group_Icon_URL + groupObj.icon
                    }

                    if includeHiddens == false {
                        if groupObj.ishidden == "0" { arr.add(groupObj) }
                    }
                    else{ arr.add(groupObj) }
                    }
                }
                
                //Code comment by Piyush Vyas
                //REASON : Application chat restore/import time all chat succesfully impoted, but get the all group info in "ChatListVC" - screen, crash the application in following code. Bcoz, here get values - "lastMessageId" return "0"-Value.
                /*
                //PV
                var arrGroups = arr as! [StructGroupDetails]
                arrGroups = arrGroups.sorted(by: {Float($0.lastMessageId)! > Float($1.lastMessageId)! })
                */
                
                //COMMENT FOLLOWING 3 LINES IF SORT FAILS
                /*let pinnedGroups = arrGroups.filter({$0.ispinned == "1"})
                let unPinnedGroups = arrGroups.filter({$0.ispinned == "0"})
                arrGroups = pinnedGroups + unPinnedGroups*/
                
                //arr = NSMutableArray(array: arrGroups) //PV
                return arr
            
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    func getHiddenGroupList()->[StructGroupDetails]{
        let allGroups = getGroupsList(includeHiddens: true) as! [StructGroupDetails]
        let hiddenGroups = allGroups.filter({$0.ishidden == "1"})
        return hiddenGroups
    }
    
    func getCommonGroupsListWithUserID(userId:String)->[StructGroupDetails]{
        var arrResult = [StructGroupDetails]()
        let groupList = getGroupsList(includeHiddens: true) as! [StructGroupDetails]
        
        let loggedInId = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        
        arrResult = groupList.filter({
            let members = $0.members.components(separatedBy: ",")
            if members.contains(userId) && members.contains(loggedInId){ return true }
            else { return false }
        })
        return arrResult
    }
    
    func getGroupById(groupId:String) -> StructGroupDetails?{
        let groupList = getGroupsList(includeHiddens: true) as! [StructGroupDetails]
        return groupList.first(where: {$0.group_id == groupId})
    }
    
    func updateGroupFor(groupMessage:StructGroupChat){
        let predicate = NSPredicate(format:"group_id = %@", groupMessage.groupid)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_GROUPS)
        fetchRequest.propertiesToUpdate = [
            "lastMessageId" : groupMessage.id,
            "lastMediaURL" : groupMessage.mediaurl,
            "lastMessage" : groupMessage.textmessage,
            "lastMessageType" : groupMessage.messagetype,
            "lastMessageDate" : groupMessage.createddate,
            "lastMessageSenderId" : groupMessage.senderid,
            "lastMessageReceiverIds" : groupMessage.receiverid,
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func updateGroupInfo(groupInfo:GroupInfo){
        let predicate = NSPredicate(format:"group_id = %@", groupInfo.groupId!)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_GROUPS)
        
        let members = groupInfo.members!.map({ $0.userId! })
        fetchRequest.propertiesToUpdate = [
            "admins" : groupInfo.admins!,
            "icon" : groupInfo.icon!,
            "members" : members.joined(separator: ","),
            "muted_by" : groupInfo.mutedBy!,
            "name" : groupInfo.name!,
            "edit_permission" : groupInfo.edit_permission!,
            "msg_permission" : groupInfo.msg_permission!
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func updateMuteIDsForGroup(muteIDs:String, groupID:String) {
        let predicate = NSPredicate(format:"group_id = %@", groupID)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_GROUPS)
        fetchRequest.propertiesToUpdate = [
            "muted_by" : muteIDs
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func getUnreadCountForGroup(selectedGroup:StructGroupChat) -> Int{
        let groups = getGroupsList(includeHiddens: true) as! [StructGroupDetails]
        for group in groups{
            if (group.group_id == selectedGroup.groupid) {
                return Int(group.unreadCount)!
            }
        }
        return 0
    }
    
    func increaseUnreadCountForGroup(for group:StructGroupChat){
        
        let predicate = NSPredicate(format:"group_id = %@", group.groupid)
        
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_GROUPS)
        
        let unreadCount = getUnreadCountForGroup(selectedGroup: group)
        
        fetchRequest.propertiesToUpdate = [
            "lastMessageId" : group.id,
            "lastMediaURL" : group.mediaurl,
            "lastMessage" : group.textmessage,
            "lastMessageType" : group.messagetype,
            "lastMessageDate" : group.createddate,
            "lastMessageSenderId" : group.senderid,
            "lastMessageReceiverIds" : group.receiverid,
            "unreadCount" : "\(unreadCount + 1)" //INCREASE HERE
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func setUnreadCountToZeroGroup(for group:StructGroupDetails){
        let predicate = NSPredicate(format:"group_id = %@", group.group_id)

        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_GROUPS)
        
        fetchRequest.propertiesToUpdate = [
            "unreadCount" : "0"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func deleteGroup(groupID:String){
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let predicate = NSPredicate(format:"group_id = %@", groupID)
        let fetchRequest = NSFetchRequest<CD_Groups>(entityName: ENTITY_GROUPS)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_GROUPS, in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Groups]
            for object in results {
                CoreDBManager.sharedDatabase.managedObjectContext.delete(object)
            }
            self.saveContext()
        }
        catch
        {
            
        }
    }
    
    func hideUnhideGroupChat(for groupID:String, shouldHide:Bool){
        let predicate = NSPredicate(format:"group_id = %@", groupID)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_GROUPS)
        
        fetchRequest.propertiesToUpdate = [
            "ishidden" : shouldHide ? "1" : "0"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func readUnreadPersonalChat(for chatUser:StructChat, shouldread:Bool)
    {
        let predi0_1 = NSPredicate(format:"receiverid == %@", chatUser.kreceiverid)
        let predi0_2 = NSPredicate(format:"senderid == %@", chatUser.ksenderid)
        let predicate1 = NSCompoundPredicate.init(type: .and, subpredicates: [predi0_1, predi0_2])
        
        let predi1_1 = NSPredicate(format:"receiverid == %@", chatUser.ksenderid)
        let predi1_2 = NSPredicate(format:"senderid == %@", chatUser.kreceiverid)
        let predicate2 = NSCompoundPredicate.init(type: .and, subpredicates: [predi1_1, predi1_2])
        
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1, predicate2])
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_FRIENDS)
        fetchRequest.propertiesToUpdate = [
            "isread" : chatUser.kisread == "1" || chatUser.kisread == "0"  ? "2" : "1",
            "unreadCount" : chatUser.kisread == "1" || chatUser.kisread == "0"  ? "0" : "1"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            print(result)
            //            print(predicate)
            //            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func pinUnpinGroupChat(for groupID:String, shouldPin:Bool){
        let predicate = NSPredicate(format:"group_id = %@", groupID)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_GROUPS)
        
        fetchRequest.propertiesToUpdate = [
            "ispinned" : shouldPin ? "1" : "0"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    //MARK:- BROADCAST LIST
    func saveBroadcastListInDB(objBroadcastList:StructBroadcastList) -> Bool{
        let  broadcastListObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_BROADCASTLIST,into:managedObjectContext) as? CD_BroadcastList)!
        broadcastListObj.broadcastListID = objBroadcastList.broadcastListID
        broadcastListObj.lastMediaURL = objBroadcastList.lastMediaURL
        broadcastListObj.lastMessage = objBroadcastList.lastMessage
        broadcastListObj.lastMessageDate = objBroadcastList.lastMessageDate
        broadcastListObj.lastMessageId = objBroadcastList.lastMessageId
        broadcastListObj.lastMessageType = objBroadcastList.lastMessageType
        broadcastListObj.members = objBroadcastList.members
        broadcastListObj.memberNames = objBroadcastList.memberNames
        broadcastListObj.memberPhotos = objBroadcastList.memberPhotos
        broadcastListObj.name = objBroadcastList.name
        broadcastListObj.ispinned = objBroadcastList.ispinned
        self.saveContext()
        return true
    }
    
    func getBroadcastLists() -> NSMutableArray{
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_BroadcastList>(entityName: ENTITY_BROADCASTLIST)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_BROADCASTLIST, in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_BroadcastList]
            if(results.count > 0)
            {
                var arr = NSMutableArray()
                for result  in results {
                    
                    var broadcastListObj = StructBroadcastList(dictionary: [:])
                    broadcastListObj.broadcastListID = result.broadcastListID ?? ""
                    broadcastListObj.lastMediaURL = result.lastMediaURL ?? ""
                    broadcastListObj.lastMessage = result.lastMessage ?? ""
                    broadcastListObj.lastMessageDate = result.lastMessageDate ?? ""
                    broadcastListObj.lastMessageId = result.lastMessageId ?? ""
                    broadcastListObj.lastMessageType = result.lastMessageType ?? ""
                    broadcastListObj.members = result.members ?? ""
                    broadcastListObj.memberNames = result.memberNames ?? ""
                    broadcastListObj.memberPhotos = result.memberPhotos ?? ""
                    broadcastListObj.name = result.name ?? ""
                    broadcastListObj.ispinned = result.ispinned ?? "0"
                    arr.add(broadcastListObj)
                }
                
                var arrBroadcastLists = arr as! [StructBroadcastList]
                arrBroadcastLists = arrBroadcastLists.sorted(by: {Float($0.lastMessageId)! > Float($1.lastMessageId)! })
                arr = NSMutableArray(array: arrBroadcastLists)
                return arr
                
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    func getBroadcastListById(Id:String) -> StructBroadcastList{
        let broadcastList = getBroadcastLists() as! [StructBroadcastList]
        return broadcastList.first(where: {$0.broadcastListID == Id})!
    }
    
    func updateBroadcastListFor(broadcastMessage:StructBroadcastMessage){
        let predicate = NSPredicate(format:"broadcastListID = %@", broadcastMessage.broadcastListID)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_BROADCASTLIST)
        fetchRequest.propertiesToUpdate = [
            "lastMediaURL" : broadcastMessage.mediaurl,
            "lastMessage" : broadcastMessage.textmessage,
            "lastMessageDate" : broadcastMessage.createddate,
            "lastMessageId" : broadcastMessage.id,
            "lastMessageType" : broadcastMessage.messagetype
            //"members" : broadcastMessage.receiverid,
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func updateBroadcastListDetails(updatedBroadcastlist broadcastList:StructBroadcastList){
        let predicate = NSPredicate(format:"broadcastListID = %@", broadcastList.broadcastListID)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_BROADCASTLIST)
        fetchRequest.propertiesToUpdate = [
            "members" : broadcastList.members,
            "memberPhotos" : broadcastList.memberPhotos,
            "memberNames" : broadcastList.memberNames,
            "name" : broadcastList.name
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    func deleteBroadcastList(broadcastListID:String) -> Bool{
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let predicate = NSPredicate(format:"broadcastListID = %@", broadcastListID)
        let fetchRequest = NSFetchRequest<CD_BroadcastList>(entityName: ENTITY_BROADCASTLIST)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_BROADCASTLIST, in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_BroadcastList]
            for object in results {
                CoreDBManager.sharedDatabase.managedObjectContext.delete(object)
            }
            self.saveContext()
            return true
        }
        catch
        {
            return false
        }
    }
    
    func pinUnpinBroadcastList(for broadcastListID:String, shouldPin:Bool){
        let predicate = NSPredicate(format:"broadcastListID = %@", broadcastListID)
        let fetchRequest = NSBatchUpdateRequest.init(entityName: ENTITY_BROADCASTLIST)
        
        fetchRequest.propertiesToUpdate = [
            "ispinned" : shouldPin ? "1" : "0"
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
//            print(result)
//            print(predicate)
//            //print("Success")
            self.saveContext()
        }catch{
        }
    }
    
    //MARK:- BROADCAST MESSAGES
    
    func saveBroadcastMessageInLocalDB(objmessgae:StructBroadcastMessage) -> Bool
    {
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_BoardcastMessages>(entityName: ENTITY_BROADCAST_MESSAGE)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_BROADCAST_MESSAGE, in: objContext)!
        let predicate = NSPredicate(format:"id == %@",objmessgae.id)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_BoardcastMessages]
            if(results.count > 0)
            {
                let chatObj = results[0] as CD_BoardcastMessages
                chatObj.id = objmessgae.id
                chatObj.broadcastListID = objmessgae.broadcastListID
                chatObj.senderid = objmessgae.senderid
                chatObj.sendername = objmessgae.sendername
                chatObj.receiverid = objmessgae.receiverid
                chatObj.textmessage = objmessgae.textmessage
                chatObj.isread = objmessgae.isread
                chatObj.platform = objmessgae.platform
                chatObj.isdeleted = objmessgae.isdeleted
                chatObj.createddate = objmessgae.createddate
                chatObj.messagetype = objmessgae.messagetype
                chatObj.mediaurl = objmessgae.mediaurl
            }
            else
            {
                
                let  chatObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_BROADCAST_MESSAGE,into:managedObjectContext) as? CD_BoardcastMessages)!
                chatObj.id = objmessgae.id
                chatObj.broadcastListID = objmessgae.broadcastListID
                chatObj.senderid = objmessgae.senderid
                chatObj.sendername = objmessgae.sendername
                chatObj.receiverid = objmessgae.receiverid
                chatObj.textmessage = objmessgae.textmessage
                chatObj.isread = objmessgae.isread
                chatObj.platform = objmessgae.platform
                chatObj.isdeleted = objmessgae.isdeleted
                chatObj.createddate = objmessgae.createddate
                chatObj.messagetype = objmessgae.messagetype
                chatObj.mediaurl = objmessgae.mediaurl
                
                //UPDATE BROADCASTLIST TABLE'S RECORD FOR broadcastListID
                updateBroadcastListFor(broadcastMessage: objmessgae)
            }
            self.saveContext()
            return true
            
        }
        catch
        {
            return false
        }
    }
    
    func replaceBroadcastMessageInLocalDB(objmessgae:StructBroadcastMessage, with messageId:String) -> Bool{
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_BoardcastMessages>(entityName: ENTITY_BROADCAST_MESSAGE)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_BROADCAST_MESSAGE, in: objContext)!
        let predicate = NSPredicate(format:"id == %@",messageId)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_BoardcastMessages]
            if(results.count > 0)
            {
                let chatObj = results[0] as CD_BoardcastMessages
                chatObj.id = objmessgae.id
                chatObj.broadcastListID = objmessgae.broadcastListID
                chatObj.senderid = objmessgae.senderid
                chatObj.sendername = objmessgae.sendername
                chatObj.receiverid = objmessgae.receiverid
                chatObj.textmessage = objmessgae.textmessage
                chatObj.isread = "0" //objmessgae.isread
                chatObj.platform = objmessgae.platform
                chatObj.isdeleted = objmessgae.isdeleted
                chatObj.createddate = objmessgae.createddate
                chatObj.messagetype = objmessgae.messagetype
                chatObj.mediaurl = objmessgae.mediaurl
            }
            self.saveContext()
            return true
        }
        catch {
            return false
        }
    }
    
    func getMessagesForBroadcastListID(broadcastListID:String) -> [StructBroadcastMessage]{
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_BoardcastMessages>(entityName: ENTITY_BROADCAST_MESSAGE)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_BROADCAST_MESSAGE, in: objContext)!
        fetchRequest.entity = disentity
        let predicate1 = NSPredicate(format:"broadcastListID == %@",broadcastListID)
        let predicate2 = NSPredicate(format:"isdeleted != %@", "1")
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_BoardcastMessages]
            if(results.count > 0)
            {
                var arr = [StructBroadcastMessage]()
                for result  in results {
                    var msgObj = StructBroadcastMessage(dictionary: [:])
                    msgObj.id = result.id ?? ""
                    msgObj.broadcastListID = result.broadcastListID ?? ""
                    msgObj.senderid = result.senderid ?? ""
                    msgObj.sendername = result.sendername ?? ""
                    msgObj.receiverid = result.receiverid ?? ""
                    msgObj.textmessage = result.textmessage ?? ""
                    msgObj.isread = result.isread ?? ""
                    msgObj.platform = result.platform ?? ""
                    msgObj.isdeleted = result.isdeleted ?? ""
                    msgObj.createddate = result.createddate ?? ""
                    msgObj.messagetype = result.messagetype ?? ""
                    msgObj.mediaurl = result.mediaurl ?? ""
                    arr.append(msgObj)
                }
                return arr
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    func deleteAllMessagesOf(broadcastListId:String) {
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_BROADCAST_MESSAGE)
        fetchRequest.propertiesToUpdate = [ "isdeleted" : "1" ]
        
        let predicate = NSPredicate(format:"broadcastListID == %@",broadcastListId)
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        do{
            let result = try self.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //print("result: \(result)")
            self.saveContext()
        }catch{
            print(error.localizedDescription)
        }
        
        let updateRequest = NSBatchUpdateRequest(entityName: ENTITY_BROADCASTLIST)
        updateRequest.propertiesToUpdate = [
            "lastMessageId" : "0",
            "lastMediaURL" : "",
            "lastMessage" : "",
            "lastMessageType" : "0",
            //"lastMessageSenderId" : "0",
            //"lastMessageReceiverIds" : "0",
        ]
        let updatePredicate = NSPredicate(format: "broadcastListID = %@", broadcastListId)
        updateRequest.predicate = updatePredicate
        updateRequest.resultType = .updatedObjectsCountResultType
        do{
            _ = try self.managedObjectContext.execute(updateRequest) as! NSBatchUpdateResult
            //print("result: \(result)")
            self.saveContext()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func getPhotosAndVideosForBroadcastList(broadcastListId:String)->[String]{
        let messages = getMessagesForBroadcastListID(broadcastListID: broadcastListId)
        var msgs = messages.filter({$0.messagetype == "1"})
        msgs = msgs.filter({isPathForVideo(path: $0.mediaurl)||isPathForImage(path: $0.mediaurl)}).sorted(by: { Float($0.id)! < Float($1.id)! })
        return msgs.map({$0.mediaurl})
    }
    
    func getDocumentForBroadcastList(broadcastListId:String, filename: String) -> StructBroadcastMessage {
        /*
        let messages = getMessagesForBroadcastListID(broadcastListID: broadcastListId)
        var msgs = messages.filter({$0.messagetype == "1"})
        msgs = msgs.filter({isPathForVideo(path: $0.mediaurl)||isPathForImage(path: $0.mediaurl)}).sorted(by: { Float($0.id)! < Float($1.id)! })
        return msgs.map({$0.mediaurl})
        */
        
        let messages = getMessagesForBroadcastListID(broadcastListID: broadcastListId)
        var msgs = messages.filter({$0.messagetype == "1"})
        
        msgs = msgs.filter({ (isPathForImage(path: $0.mediaurl) != true)
            || (isPathForVideo(path: $0.mediaurl) != true)
            //|| (isPathForContact(path: $0.kmediaurl) != true)
            //||(isPathForAudio(path: $0.kmediaurl) != true)
        })
        msgs = msgs.filter({$0.mediaurl.lastPathComponent == filename})
        
        return msgs.first ?? StructBroadcastMessage.init(dictionary: [:])
    }
    
    func BroadcastChat_Delete_AllChatMessages_ExceptStarred_with(broadcastListId:String) {
        let arrMsgs : [StructBroadcastMessage] = getMessagesForBroadcastListID(broadcastListID: broadcastListId)
        var arrDeleteMess : [String] = []
        for obj in arrMsgs {
            //if obj.isstarred != "1" { arrDeleteMess.append(obj.id) }
        }
        deleteForMeGroupChatMessage(groupChatIDs: arrDeleteMess)
        //------------->
        
        //Update Broadcast List
        let updateRequest = NSBatchUpdateRequest(entityName: ENTITY_BROADCASTLIST)
        updateRequest.propertiesToUpdate = [
            "lastMessageId" : "0",
            "lastMediaURL" : "",
            "lastMessage" : "",
            "lastMessageType" : "0",
            "lastMessageSenderId" : "0",
            "lastMessageReceiverIds" : "0",
        ]
        let updatePredicate = NSPredicate(format: "broadcastListID = %@", broadcastListId)
        updateRequest.predicate = updatePredicate
        updateRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try self.managedObjectContext.execute(updateRequest) as! NSBatchUpdateResult
            //print("result: \(result)")
            self.saveContext()
        }catch{
            print(error.localizedDescription)
        }
    }
  
    
    //MARK:- STORIES VIEWERS
    
    func saveViewersInLocalDB(ForStoryID storyID:String, viewers:[StructStoryViewers]){
        
        if storyID == "41"{
            //print("CHECK NOW")
        }
        
        for storyViewer in viewers{
            let objContext = self.managedObjectContext
            let fetchRequest = NSFetchRequest<CD_Stories_Viewers>(entityName: ENTITY_STORIES_VIEWERS)
            let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES_VIEWERS, in: objContext)!
            let predicate = NSPredicate(format:"storyID == %@ AND userID == %@", storyID, storyViewer.userID)
            fetchRequest.predicate = predicate
            fetchRequest.entity = disentity
            
            do {
                let results = try managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Stories_Viewers]
                if results.count > 0{
                    //DO NOTHING
                }else{
                    let  structObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_STORIES_VIEWERS,into:managedObjectContext) as? CD_Stories_Viewers)!
                    structObj.storyID = storyID
                    structObj.userID = storyViewer.userID
                    structObj.createdDate = storyViewer.createdDate
                    structObj.profileURL = storyViewer.profileURL
                    structObj.userName = storyViewer.userName
                    structObj.phoneNo = storyViewer.phoneno
                    structObj.countryCode = storyViewer.countrycode
                }
                saveContext()
                postNotification(with: NC_ViewerRefresh)
            }
            catch{
                
            }
        }
    }
    
    func getViewers(ForMyStoryID storyID:String)->[StructStoryViewers]{
        
        if storyID == "41"{
            //print("CHECK NOW")
        }
        
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Stories_Viewers>(entityName: ENTITY_STORIES_VIEWERS)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES_VIEWERS, in: objContext)!
        let predicate = NSPredicate(format:"storyID == %@", storyID)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Stories_Viewers]
            
            var arrViewers = [StructStoryViewers]()
            for result in results{
                let structObj = StructStoryViewers.init(
                    storyID: storyID,
                    userID: result.userID!,
                    createdDate: result.createdDate!,
                    profileURL: result.profileURL!,
                    userName: result.userName!,
                    countrycode: result.countryCode!,
                    phoneno: result.phoneNo!)
                arrViewers.append(structObj)
            }
            return arrViewers
            
        }
        catch{
            return []
        }
    }
    
    //MARK:- STORY
    func saveStoriesInLocalDB(stories: [StructStatusStory]){
        for friendStory in stories{
            
            let objContext = self.managedObjectContext
            let fetchRequest = NSFetchRequest<CD_Stories>(entityName: ENTITY_STORIES)
            let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES, in: objContext)!
            let predicate = NSPredicate(format:"storyID == %@", friendStory.storyID)
            fetchRequest.predicate = predicate
            fetchRequest.entity = disentity
            
            do {
                let results = try managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Stories]
                if results.count > 0{
                    results[0].statusprivacy = friendStory.statusprivacy
                    results[0].statusviewprivacy = friendStory.statusviewprivacy
                    results[0].markedusers = friendStory.markedusers
                    results[0].countrycode = friendStory.countrycode
                    results[0].phoneno = friendStory.phoneno
                    results[0].userName = friendStory.userName
                    //DO NOTHING
                }else{
                    let  structObj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_STORIES,into:managedObjectContext) as? CD_Stories)!
                    structObj.storyID = friendStory.storyID
                    structObj.userID = friendStory.userID
                    structObj.createdDate = friendStory.createdDate
                    structObj.storyType = friendStory.storyType
                    structObj.mediaURL = friendStory.mediaURL
                    structObj.isViewedByMe = friendStory.isViewedByMe
                    structObj.duration = friendStory.duration
                    structObj.profileURL = friendStory.profileURL
                    structObj.userName = friendStory.userName
                    structObj.allowcopy = friendStory.allowCopy
                    structObj.caption = friendStory.caption
                    structObj.statusprivacy = friendStory.statusprivacy
                   structObj.statusviewprivacy = friendStory.statusviewprivacy
                    structObj.markedusers = friendStory.markedusers
                    structObj.countrycode = friendStory.countrycode
                    structObj.phoneno = friendStory.phoneno
                }
                saveContext()
            }
            catch{
                
            }
        }
    }
    
    func getStories(ForFriends forFriends:Bool)->[StructStatusStory]{
        
        let objContext = self.managedObjectContext
        
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES, in: objContext)!
        
        let fetchRequest = NSFetchRequest<CD_Stories_Viewers>(entityName: ENTITY_STORIES)
        fetchRequest.entity = disentity
        
        var predicateOpeator = "=="
        if forFriends{
            predicateOpeator = "!="
        }
        
        let predicate = NSPredicate.init(format: "userID \(predicateOpeator) %@", UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Stories]
            
            var arrViewers = [StructStatusStory]()
            for result in results{
                if forFriends
                {
                    if result.statusviewprivacy! != "0"
                    {
                        let structObj = StructStatusStory.init(
                            storyID: result.storyID!,
                            createdDate: result.createdDate!,
                            storyType: result.storyType!,
                            mediaURL: result.mediaURL!,
                            isViewedByMe: result.isViewedByMe!,
                            userID: result.userID!,
                            duration: result.duration!,
                            profileURL: result.profileURL!,
                            userName: result.userName!,
                            allowCopy:result.allowcopy!,
                            caption:result.caption!,
                            statusprivacy:result.statusprivacy!,
                            countrycode:result.countrycode!,
                            phoneno:result.phoneno!,
                            statusviewprivacy:result.statusviewprivacy!,
                            markedusers:result.markedusers!
                        )
                        let arr = result.markedusers!.components(separatedBy: ",")
                        if result.statusviewprivacy == "3"
                        {
                            if arr.contains(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))
                            {
                                
                            }
                            else
                            {
                                arrViewers.append(structObj)
                            }
                        }
                        else if result.statusviewprivacy == "4"
                        {
                            if arr.contains(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))
                            {
                                arrViewers.append(structObj)
                            }
                        }
                        else
                        {
                            arrViewers.append(structObj)
                        }
                    }
                }
                else
                {
                    let structObj = StructStatusStory.init(
                        storyID: result.storyID!,
                        createdDate: result.createdDate!,
                        storyType: result.storyType!,
                        mediaURL: result.mediaURL!,
                        isViewedByMe: result.isViewedByMe!,
                        userID: result.userID!,
                        duration: result.duration!,
                        profileURL: result.profileURL!,
                        userName: result.userName!,
                        allowCopy:result.allowcopy!,
                        caption:result.caption!,
                        statusprivacy:result.statusprivacy!,
                        countrycode:result.countrycode!,
                        phoneno:result.phoneno!,
                        statusviewprivacy:result.statusviewprivacy!,
                        markedusers:result.markedusers!
                    )
                    arrViewers.append(structObj)
                }
            }
            return arrViewers
            
        }
        catch{
            return []
        }
    }
    
    func setStoryIsViewedByMe(ForStoryID storyID:String){
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Stories>(entityName: ENTITY_STORIES)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES, in: objContext)!
        let predicate = NSPredicate(format:"storyID == %@", storyID)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Stories]
            if results.count > 0{
                let result = results.first!
                result.isViewedByMe = "1"
            }
        }
        catch{
            
        }
    }
    
    func checkCopyStatus(_ storyID:String)->String{
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Stories>(entityName: ENTITY_STORIES)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES, in: objContext)!
        let predicate = NSPredicate(format:"storyID == %@", storyID)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        do {
            let results = try managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Stories]
            for result in results{
                return result.allowcopy!
            }
            return "0"
        }
        catch{
            return "0"
        }
    }
    
    func udpateStoryCopyflag(_ sid:String,_ flag:String)
    {
        let predicate = NSPredicate(format:"storyID = %@", sid)
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_STORIES)
        fetchRequest.propertiesToUpdate = [
            "allowcopy" : flag
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            print(result)
            print(predicate)
            //print("Success")
            let dict = ["status_id" : sid, "allowcopy" : flag]
            APP_DELEGATE.socketIOHandler?.socket?.emit("EditStatusPrivacy",dict)
            self.saveContext()
        }catch{
            print(error.localizedDescription)
        }
    } 
    
    func getStoriesById(ForFriends forFriends:Bool,storyId:String)->[StructStatusStory]{
        
        let objContext = self.managedObjectContext
        
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES, in: objContext)!
        
        let fetchRequest = NSFetchRequest<CD_Stories_Viewers>(entityName: ENTITY_STORIES)
        fetchRequest.entity = disentity
        
        var predicateOpeator = "=="
        if forFriends{
            predicateOpeator = "!="
        }
        
        let predicate = NSPredicate.init(format: "storyID \(predicateOpeator) %@", storyId)
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Stories]
            
            var arrViewers = [StructStatusStory]()
            for result in results{
                let structObj = StructStatusStory.init(
                    storyID: result.storyID!,
                    createdDate: result.createdDate!,
                    storyType: result.storyType!,
                    mediaURL: result.mediaURL!,
                    isViewedByMe: result.isViewedByMe!,
                    userID: result.userID!,
                    duration: result.duration!,
                    profileURL: result.profileURL!,
                    userName: result.userName!,
                    allowCopy: result.allowcopy!,
                    caption:result.caption!,
                    statusprivacy:result.statusprivacy!,
                    countrycode:result.countrycode!,
                    phoneno:result.phoneno!,
                    statusviewprivacy:result.statusviewprivacy!,
                    markedusers:result.markedusers!
                )
                arrViewers.append(structObj)
            }
            return arrViewers
            
        }
        catch{
            return []
        }
    }
    
    //MARK:- STORY
    
    /*func saveStoryInLocalDB(objstory:StructStoryData) -> Bool
    {
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Story>(entityName: ENTITY_STORY)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORY, in: objContext)!
        let predicate = NSPredicate(format:"kstoryid == %@",objstory.kstoryid)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Story]
            if(results.count > 0)
            {
                let strobj = results[0] as CD_Story
                strobj.kuid = objstory.kuid
                strobj.kuprofile = objstory.kuprofile
                strobj.kuname = objstory.kuname
                strobj.kviewtime = objstory.kstorydate
                strobj.kisviewed = objstory.kisviewed
                strobj.kviewerid = (strobj.kviewerid == "" && strobj.kviewerid == objstory.kviewerid) ?  objstory.kviewerid : "\(strobj.kviewerid ?? "0"),\(objstory.kviewerid == "" ? objstory.kviewerid : "0")"
            }
            else
            {
                let  strobj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_STORY,into:managedObjectContext) as? CD_Story)!
                strobj.kstoryid = objstory.kstoryid
                strobj.kstorytype = objstory.kstorytype
                strobj.kstoryurl = objstory.kstoryurl
                strobj.kstoryduration = objstory.kstoryduration
                strobj.kstorydate = objstory.kstorydate
                strobj.kuid = objstory.kuid
                strobj.kuprofile = objstory.kuprofile
                strobj.kuname = objstory.kuname
                strobj.kisviewed = objstory.kisviewed
                strobj.kstoryownername = objstory.kstoryownername
                strobj.kstoryownerprofile = objstory.kstoryownerprofile
            }
            self.saveContext()
            return true
        }
        catch
        {
            return false
        }
    }
    
    func getMyStoryList(StoryLoadComplete:@escaping ([StructStoryData],[StructStoryData])->())
    {
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Story>(entityName: ENTITY_STORY)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORY, in: objContext)!
        let predicate = NSPredicate(format:"kuid == %@",UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Story]
            if(results.count > 0)
            {
                var arr = [StructStoryData]()
                var arrvw = [StructStoryData]()
                for result  in results
                {
                    var friendObj = StructStoryData(dictionary: [:])
                    friendObj.kstoryid = result.kstoryid ?? ""
                    friendObj.kisviewed = result.kisviewed ?? ""
                    friendObj.kuprofile = result.kuprofile ?? ""
                    friendObj.kuid = result.kuid ?? ""
                    friendObj.kuname = result.kuname ?? ""
                    friendObj.kstoryurl = result.kstoryurl ?? ""
                    friendObj.kstorydate = result.kstorydate ?? ""
                    friendObj.kstorytype = result.kstorytype ?? ""
                    friendObj.kstoryduration = result.kstoryduration ?? ""
                    friendObj.kstoryownerprofile = result.kstoryownerprofile ?? ""
                    friendObj.kstoryownername = result.kstoryownername ?? ""
                    friendObj.kviewerid = result.kviewerid ?? ""
                    /*if result.kisviewed == "1"
                    {
                        arrvw.append(friendObj)
                    }
                    else
                    {
                        arr.append(friendObj)
                    }*/
                    arr.append(friendObj)
                }
                StoryLoadComplete(arr,arrvw)
            }
            else
            {
                StoryLoadComplete([],[])
            }
        }
        catch
        {
            StoryLoadComplete([],[])
        }
    }
    
    func getSingleUserStoryList(uid:String,StoryLoadComplete:@escaping ([StructStoryData],[StructStoryData])->())
    {
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Story>(entityName: ENTITY_STORY)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORY, in: objContext)!
        let predicate = NSPredicate(format:"kuid == %@",uid)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Story]
            if(results.count > 0)
            {
                var arr = [StructStoryData]()
                var arrvw = [StructStoryData]()
                for result  in results
                {
                    var friendObj = StructStoryData(dictionary: [:])
                    friendObj.kstoryid = result.kstoryid ?? ""
                    friendObj.kisviewed = result.kisviewed ?? ""
                    friendObj.kuprofile = result.kuprofile ?? ""
                    friendObj.kuid = result.kuid ?? ""
                    friendObj.kuname = result.kuname ?? ""
                    friendObj.kstoryurl = result.kstoryurl ?? ""
                    friendObj.kstorydate = result.kstorydate ?? ""
                    friendObj.kstorytype = result.kstorytype ?? ""
                    friendObj.kstoryduration = result.kstoryduration ?? ""
                    friendObj.kstoryownerprofile = result.kstoryownerprofile ?? ""
                    friendObj.kstoryownername = result.kstoryownername ?? ""
                    friendObj.kviewerid = result.kviewerid ?? ""
                    if result.kisviewed == "1"
                    {
                        arrvw.append(friendObj)
                    }
                    //else
                    //{
                        arr.append(friendObj)
                    //}
                }
                StoryLoadComplete(arr,arrvw)
            }
            else
            {
                StoryLoadComplete([],[])
            }
        }
        catch
        {
            StoryLoadComplete([],[])
        }
    }
    func getFriendStoryList(StoryLoadComplete:@escaping ([StructStoryData],[StructStoryData])->())
    {
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Story>(entityName: ENTITY_STORY)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORY, in: objContext)!
        let predicate = NSPredicate(format:"kuid != %@",UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Story]
            if(results.count > 0)
            {
                var arr = [StructStoryData]()
                var arrvw = [StructStoryData]()
                for result  in results
                {
                    var friendObj = StructStoryData(dictionary: [:])
                    friendObj.kstoryid = result.kstoryid ?? ""
                    friendObj.kisviewed = result.kisviewed ?? ""
                    friendObj.kuprofile = result.kuprofile ?? ""
                    friendObj.kuid = result.kuid ?? ""
                    friendObj.kuname = result.kuname ?? ""
                    friendObj.kstoryurl = result.kstoryurl ?? ""
                    friendObj.kstorydate = result.kstorydate ?? ""
                    friendObj.kstorytype = result.kstorytype ?? ""
                    friendObj.kstoryduration = result.kstoryduration ?? ""
                    friendObj.kviewerid = result.kviewerid ?? ""
                    friendObj.kstoryownerprofile = result.kstoryownerprofile ?? ""
                    friendObj.kstoryownername = result.kstoryownername ?? ""
                    if result.kisviewed == "1"
                    {
                        arrvw.append(friendObj)
                    }
                    //else
                    //{
                        arr.append(friendObj)
                    //}
                }
                StoryLoadComplete(arr,arrvw)
            }
            else
            {
                StoryLoadComplete([],[])
            }
        }
        catch
        {
            StoryLoadComplete([],[])
        }
    }
    
    func saveMyViewer(sid:String,vid:String,prof:String,nm:String,tm:String) -> Bool
    {
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Viewers>(entityName: ENTITY_VIEWER)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_VIEWER, in: objContext)!
        let predicate = NSPredicate(format:"story_id == %@",sid)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Viewers]
            if(results.count > 0) {
                let strobj = results[0] as CD_Viewers
                strobj.viewer_name = nm
                strobj.viewer_profile = prof
                self.saveContext()
            }
            else {
                let  strobj = (NSEntityDescription.insertNewObject(forEntityName:ENTITY_VIEWER,into:managedObjectContext) as? CD_Viewers)!
                strobj.story_id = sid
                strobj.view_date = tm
                strobj.viewer_id = vid
                strobj.viewer_name = nm
                strobj.viewer_profile = prof
                self.saveContext()
                postNotification(with: NC_ViewerRefresh)
            }
            return true
        }
        catch
        {
            return false
        }
    }
    
    
    func udpateViewerList(uid:String, sid:String,vid:String,prof:String,nm:String,tm:String)
    {
        let predicate = NSPredicate(format:"kuid = %@", uid)
        let fetchRequest = NSBatchUpdateRequest(entityName: ENTITY_STORY)
        fetchRequest.propertiesToUpdate = [
            "kviewerid" : vid,
            "kuprofile":prof,
            "kuname":nm,
            "kisviewed":"1",
            "kviewtime":tm,
            "kuid":uid
        ]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        do{
            let result = try managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            print(result)
            print(predicate)
            //print("Success")
            self.saveContext()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func getMyViewer() -> [StructViewers]
    {
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Viewers>(entityName: ENTITY_VIEWER)
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_VIEWER, in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Viewers]
            if(results.count > 0)
            {
                var arr = [StructViewers]()
                for result  in results
                {
                    var friendObj = StructViewers(dictionary: [:])
                    friendObj.ksid = result.story_id!
                    friendObj.kvid = result.viewer_id!
                    friendObj.kvdate = result.view_date!
                    friendObj.kvname = result.viewer_name!
                    friendObj.kvpofile = result.viewer_profile!
                    arr.append(friendObj)
                }
                return arr
            }
        }
        catch
        {
            return []
        }
        return []
    }*/
    
    //MARK:- Delete Story
    func deleteExpiredStory(DeleteDone:@escaping (Bool)->())
    {
        let endDate = Date()
        
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Stories>(entityName: ENTITY_STORIES)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES, in: objContext)!
        fetchRequest.entity = disentity
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Stories]
            
            if(results.count > 0)
            {
                for result in results
                {
                    let resulval:CD_Stories = result
                    var catID : String!
                    catID = resulval.value(forKey: "createdDate") as! String!
                    var strDate = catID
                    //print(strDate)
                    strDate = strDate?.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
                    let thenDate = DateFormater.getDateFromString(givenDate:strDate! ) as Date
                    let hr = thenDate.hours(from: endDate)
                    
                    if hr < 0 {
                        if (hr < -24) {
                            self.managedObjectContext.delete(resulval)
                        }
                    }
                }
                self.saveContext()
            }
            DeleteDone(true)
        }
        catch
        {
            DeleteDone(true)
        }
    }
    func deleteStories(byStoryIDs arrStoryIDs:[String]){
        let predicate = NSPredicate(format: "storyID IN %@", arrStoryIDs)
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Stories>(entityName: ENTITY_STORIES)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES, in: objContext)!
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest)
            if(results.count > 0) {
                results.forEach( { self.managedObjectContext.delete($0) } )
                self.deleteViewersStories(byStoryIDs: arrStoryIDs)
                self.saveContext()
            }
        }
        catch{
            
        }
    }
    
    func deleteViewersStories(byStoryIDs arrStoryIDs:[String]){
        let predicate = NSPredicate(format: "storyID IN %@", arrStoryIDs)
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Stories_Viewers>(entityName: ENTITY_STORIES_VIEWERS)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_STORIES_VIEWERS, in: objContext)!
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest)
            if(results.count > 0) {
                results.forEach( { self.managedObjectContext.delete($0) } )
                self.saveContext()
            }
        }
        catch{
            
        }
    }
    
    //MARK:- CLEAR DB
    
    func deleteAllMessageFromLocalDB()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_CHAT)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try self.managedObjectContext.execute(deleteRequest)
            try self.managedObjectContext.save()
        } catch {
            print (error)
        }
    }
    func deleteFriend(byFriendIds fuid:[String]){
        let predicate = NSPredicate(format: "user_id IN %@", fuid)
        
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Friends>(entityName: ENTITY_FRIENDS)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_FRIENDS, in: objContext)!
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest)
            if(results.count > 0) {
                results.forEach( { self.managedObjectContext.delete($0) } )
                self.saveContext()
                let dict = [ "senderid" : fuid.first!, "receiverid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) ] as [String : Any]
                APP_DELEGATE.socketIOHandler?.socket?.emit("Update_ReadStatus", dict)
            }
        }
        catch{
            
        }
    }
    func deleteAllFriendsFromLocalDB()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_FRIENDS)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.managedObjectContext.execute(deleteRequest)
            try self.managedObjectContext.save()
            let dict = [ "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)] as [String : Any]
            APP_DELEGATE.socketIOHandler?.socket?.emit("UpdateIsRead_All", dict)
        } catch {
            print (error)
        }
    }
    
    func deleteAllGroupsFromLocalDB()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_GROUPS)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.managedObjectContext.execute(deleteRequest)
            try self.managedObjectContext.save()
        } catch {
            print (error)
        }
    }
    
    //PV
    func deleteAllGroupMessageFromLocalDB() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_GROUP_CHAT)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.managedObjectContext.execute(deleteRequest)
            try self.managedObjectContext.save()
        } catch {
            print (error)
        }
    }
}
