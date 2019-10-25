//
//  CoreDbManager.swift
//  FinalDemo
//
//  Created by POOJA on 25/10/19.
//  Copyright © 2019 POOJA. All rights reserved.
//

import UIKit
import CoreData

class CoreDbManager: NSObject {
    
    static let sharedDatabase = CoreDbManager()
       var persistentContainerQueue = OperationQueue.init()
       
       // MARK: - Core Data stack
       
       lazy var applicationDocumentsDirectory: URL = {
           
           persistentContainerQueue.maxConcurrentOperationCount = 1
           
           let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           return urls[urls.count-1]
       }()
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "FinalDemo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    

    // MARK: - Core Data stack

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("FinalDemo.sqlite")
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

//
//       lazy var persistentContainer: NSPersistentContainer = {
//
//        /*
//            The persistent container for the application. This implementation
//            creates and returns a container, having loaded the store for the
//            application to it. This property is optional since there are legitimate
//            error conditions that could cause the creation of the store to fail.
//           */
//           let container = NSPersistentContainer(name: "FinalDemo")
//           container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//               if let error = error as NSError? {
//                   // Replace this implementation with code to handle the error appropriately.
//                   // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                   /*
//                    Typical reasons for an error here include:
//                    * The parent directory does not exist, cannot be created, or disallows writing.
//                    * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                    * The device is out of space.
//                    * The store could not be migrated to the current model version.
//                    Check the error message to determine what the actual problem was.
//                    */
//                   fatalError("Unresolved error \(error), \(error.userInfo)")
//               }
//           })
//           return container
//       }()

    
    lazy var managedObjectContext: NSManagedObjectContext = {
           let coordinator = self.persistentStoreCoordinator
           var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
           managedObjectContext.persistentStoreCoordinator = coordinator
           
           //TO RESOLVE ERROR : NSMergeConflict for NSManagedObject
           managedObjectContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType);
           
           return managedObjectContext
       }()
       
       // MARK: - Core Data Saving support
    
       // MARK: - Core Data Saving support

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


extension CoreDbManager {
    //MARK:- FRIEND LIST
    func saveUserInLocalDB(objFriend:UserModel) -> Bool{
        let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "User", in: objContext)!
        let predicate = NSPredicate(format:"userId == %@",objFriend.userId)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        
        do{
            let results = try  managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [User]
            if(results.count > 0)
            {
                let friendObj = results[0] as User
                                //--> PV
                friendObj.userName = objFriend.userName
                            
                self.saveContext()
                return true
                
            } else {
                let  friendObj = (NSEntityDescription.insertNewObject(forEntityName:"User",into:managedObjectContext) as? User)
                friendObj!.userId = objFriend.userId
                friendObj!.userName = objFriend.userName
                self.saveContext()
                return true
            }
        }
        catch
        {
            return false
        }
    }
    
    func getUserList(includeHiddens:Bool) -> NSMutableArray{
        
        let objContext = CoreDbManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "User", in: objContext)!
        fetchRequest.entity = disentity
        
        do{
            let results = try  CoreDbManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [User]
            if(results.count > 0)
            {
                var arr = NSMutableArray()
                for result  in results
                {
                    var friendObj = UserModel(dictionary: [:])
                    friendObj.userId = result.userId ?? ""
                    friendObj.userName = result.userName ?? ""
                    arr.add(friendObj)
                    
                }
                
                var arrFriends = arr as! [UserModel]
                arrFriends = arrFriends.sorted(by: {Float($0.userId)! > Float($1.userId)! })
                
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
    
}
