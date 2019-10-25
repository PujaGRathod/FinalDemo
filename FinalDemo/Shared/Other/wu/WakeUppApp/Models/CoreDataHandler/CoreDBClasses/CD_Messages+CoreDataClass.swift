//
//  CD_Messages+CoreDataClass.swift
//  
//
//  Created by Admin on 31/03/18.
//
//

import Foundation
import CoreData

public class CD_Messages: NSManagedObject {

    func modelObject(withMessage message: StructChat) -> CD_Messages
    {
        var objContact:CD_Messages? = nil
        let predicate = NSPredicate(format:"chatid = %@", "\(message.kchatid)")
        let objContext = CoreDBManager.sharedDatabase.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Messages>(entityName: ENTITY_CHAT)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_CHAT, in: objContext)!
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        do
        {
            let results = try  CoreDBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [CD_Messages]
            if(results.count > 0)
            {
                objContact =  results[0]
                objContact?.createddate  =  "\(message.kcreateddate)"
                objContact?.isread  =  "\(message.kisread)"
                return objContact!
            }
            else
            {
                objContact = NSEntityDescription.insertNewObject(forEntityName:ENTITY_CHAT,into: CoreDBManager.sharedDatabase.managedObjectContext) as? CD_Messages
                objContact?.id = "\(message.kid)"
                objContact?.createddate = "\(message.kcreateddate)"
                objContact?.platform = "\(message.kdevicetype)"
                objContact?.textmessage =   "\(message.kchatmessage)"
                objContact?.receiverid  =  "\(message.kreceiverid)"
                objContact?.senderid  =  "\(message.ksenderid)"
                objContact?.isdeleted  =  "\(message.kisdeleted)"
                objContact?.isread  =  "\(message.kisread)"
                objContact?.mediaurl  =  "\(message.kmediaurl)"
                objContact?.messagetype  =  "\(message.kmessagetype)"
                objContact?.chatid  =  "\(message.kchatid)"
                objContact?.image  =  "\(message.kuserprofile)"
                objContact?.is_online  =  "\(message.kuseronline)"
                objContact?.last_login  =  "\(message.kuserlastlogin)"
                objContact?.username  =  "\(message.kusername)"
                objContact?.user_id  =  "\(message.kuserid)"                
                   objContact?.readtime  =  "\(message.readtime)"
                   objContact?.receivetime  =  "\(message.receivetime)"
                /*if( objContact?.user_id  == UserDefaultManager.getStringFromUserDefaults(key: UD_UserId))
                {
                    var userdata:AppUser!
                    userdata = UserDefaultManager.getCustomObjFromUserDefaults(key: UD_UserData) as! AppUser
                    
                    objContact?.first_name  =  "\(userdata.firstName!)"
                    objContact?.last_name  =  "\(userdata.lastName!)"
                    objContact?.profile_pic  =  "\(userdata.profilePic!)"
                }
                else
                {
                    objContact?.first_name  =  "\(wsstory.firstName!)"
                    objContact?.last_name  =  "\(wsstory.lastName!)"
                    objContact?.profile_pic  =  "\(wsstory.profilePic!)"
                }*/
            }
        }
        catch
        {
        }
        return objContact!;
    }
    
}
