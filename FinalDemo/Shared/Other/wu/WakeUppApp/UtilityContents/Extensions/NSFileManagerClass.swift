//
//  NSFileManagerClass.swift
//  SwiftDemo
//


import Foundation
public extension FileManager {
    // MARK: - Enums -
    
    /**
    Directory type enum
    */
    public enum DirectoryType : Int {
        case MainBundle
        case Library
        case Documents
        case Cache
    }
    
    // MARK: - Class functions -
    
    /**
    Read a file an returns the content as String
    */
    public static func readTextFile(file: String, ofType: String) throws -> String? {
        return try String(contentsOfFile: Bundle.main.path(forResource: file, ofType: ofType)!, encoding: String.Encoding.utf8)
    }
    
    /**
     Save a given array into a PLIST with the given filename
     */
    public static func saveArrayToPath(directory: DirectoryType, filename: String, array: Array<AnyObject>) -> Bool {
        var finalPath: String
        
        switch directory {
        case .MainBundle:
            finalPath = self.getBundlePathForFile(file: "\(filename).plist")
        case .Library:
            finalPath = self.getLibraryDirectoryForFile(file: "\(filename).plist")
        case .Documents:
            finalPath = self.getDocumentsDirectoryForFile(file: "\(filename).plist")
        case .Cache:
            finalPath = self.getCacheDirectoryForFile(file: "\(filename).plist")
        }
        
        return NSKeyedArchiver.archiveRootObject(array, toFile: finalPath)
    }
    
    /**
     Load array from a PLIST with the given filename
     */
    public static func loadArrayFromPath(directory: DirectoryType, filename: String) -> AnyObject? {
        var finalPath: String
        
        switch directory {
        case .MainBundle:
            finalPath = self.getBundlePathForFile(file: filename)
        case .Library:
            finalPath = self.getLibraryDirectoryForFile(file: filename)
        case .Documents:
            finalPath = self.getDocumentsDirectoryForFile(file: filename)
        case .Cache:
            finalPath = self.getCacheDirectoryForFile(file: filename)
        }
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: finalPath) as AnyObject?
    }
    
    /**
     Get the Bundle path for a filename
     */
    public static func getBundlePathForFile(file: String) -> String {
        let fileExtension = URL(string: file)!.pathExtension//file.pathExtension
        return Bundle.main.path(forResource: (file.replacingOccurrences(of: String(format: ".%@", file), with: "")), ofType: fileExtension)!
    }
    
    /**
     Get the Documents directory for a filename
     */
    public static func getDocumentsDirectoryForFile(file: String) -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsDirectory.appending(String(format: "%@/", file))
    }
    
    /**
     Get the Library directory for a filename
     */
    public static func getLibraryDirectoryForFile(file: String) -> String {
        let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        return libraryDirectory.appending(String(format: "%@/", file))
    }
    
    /**
     Get the Cache directory for a filename
     */
    public static func getCacheDirectoryForFile(file: String) -> String {
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return cacheDirectory.appending(String(format: "%@/", file))
    }
    
    /**
     Returns the size of the file
     */
    public static func fileSize(file: String, fromDirectory directory: DirectoryType) throws -> NSNumber? {
        if file.count != 0 {
            var path: String
            
            switch directory {
            case .MainBundle:
                path = self.getBundlePathForFile(file: file)
            case .Library:
                path = self.getLibraryDirectoryForFile(file: file)
            case .Documents:
                path = self.getDocumentsDirectoryForFile(file: file)
            case .Cache:
                path = self.getCacheDirectoryForFile(file: file)
            }
            
            if FileManager.default.fileExists(atPath: path) {
                let fileAttributes: NSDictionary? = try FileManager.default.attributesOfItem(atPath: file) as NSDictionary?
                if let _fileAttributes = fileAttributes {
                    return NSNumber(value: _fileAttributes.fileSize())
                }
            }
        }
        
        return nil
    }
    
    /**
     Delete a file with the given filename
     */
    public static func deleteFile(file: String, fromDirectory directory: DirectoryType) throws -> Bool {
        if file.count != 0 {
            var path: String
            
            switch directory {
            case .MainBundle:
                path = self.getBundlePathForFile(file: file)
            case .Library:
                path = self.getLibraryDirectoryForFile(file: file)
            case .Documents:
                path = self.getDocumentsDirectoryForFile(file: file)
            case .Cache:
                path = self.getCacheDirectoryForFile(file: file)
            }
            
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                    return true
                } catch {
                    return false
                }
            }
        }
        
        return false
    }
    
    /**
     Move a file from a directory to another
     */
    public static func moveLocalFile(file: String, fromDirectory origin: DirectoryType, toDirectory destination: DirectoryType, withFolderName folderName: String? = nil) throws -> Bool {
        var originPath: String
        
        switch origin {
        case .MainBundle:
            originPath = self.getBundlePathForFile(file: file)
        case .Library:
            originPath = self.getLibraryDirectoryForFile(file: file)
        case .Documents:
            originPath = self.getDocumentsDirectoryForFile(file: file)
        case .Cache:
            originPath = self.getCacheDirectoryForFile(file: file)
        }
        
        var destinationPath: String = ""
        if folderName != nil {
            destinationPath = String(format: "%@/%@", destinationPath, folderName!)
        } else {
            destinationPath = file
        }
        
        switch destination {
        case .MainBundle:
            destinationPath = self.getBundlePathForFile(file: destinationPath)
        case .Library:
            destinationPath = self.getLibraryDirectoryForFile(file: destinationPath)
        case .Documents:
            destinationPath = self.getDocumentsDirectoryForFile(file: destinationPath)
        case .Cache:
            destinationPath = self.getCacheDirectoryForFile(file: destinationPath)
        }
        
        if folderName != nil {
            let folderPath: String = String(format: "%@/%@", destinationPath, folderName!)
            if !FileManager.default.fileExists(atPath: originPath) {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
            }
        }
        
        var copied: Bool = false, deleted: Bool = false
        if FileManager.default.fileExists(atPath: originPath) {
            do {
                try FileManager.default.copyItem(atPath: originPath, toPath: destinationPath)
                copied = true
            } catch {
                copied = false
            }
        }
        
        if destination != .MainBundle {
            if FileManager.default.fileExists(atPath: originPath) {
                do {
                    try FileManager.default.removeItem(atPath: originPath)
                    deleted = true
                } catch {
                    deleted = false
                }
            }
        }
        
        if copied && deleted {
            return true
        }
        return false
    }
    
    
    /**
     Move a file from a directory to another
     - returns: Returns true if the operation was successful, otherwise false
     */
    @available(*, obsoleted: 1.2.0, message: "Use moveLocalFile(_, fromDirectory:, toDirectory:, withFolderName:)")
    public static func moveLocalFile(file: String, fromDirectory origin: DirectoryType, toDirectory destination: DirectoryType) throws -> Bool {
        return try self.moveLocalFile(file: file, fromDirectory: origin, toDirectory: destination, withFolderName: nil)
    }
    
    /**
     Duplicate a file into another directory
    */
    public static func duplicateFileAtPath(origin: String, toNewPath destination: String) -> Bool {
        if FileManager.default.fileExists(atPath: origin) {
            do {
                try FileManager.default.copyItem(atPath: origin, toPath: destination)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    /**
     Rename a file with another filename
     - returns: Returns true if the operation was successful, otherwise false
     */
    public static func renameFileFromDirectory(origin: DirectoryType, atPath path: String, withOldName oldName: String, andNewName newName: String) -> Bool {
        var originPath: String
        
        switch origin {
        case .MainBundle:
            originPath = self.getBundlePathForFile(file: path)
        case .Library:
            originPath = self.getLibraryDirectoryForFile(file: path)
        case .Documents:
            originPath = self.getDocumentsDirectoryForFile(file: path)
        case .Cache:
            originPath = self.getCacheDirectoryForFile(file: path)
        }
        
        if FileManager.default.fileExists(atPath: originPath) {
            let newNamePath: String = originPath.replacingOccurrences(of: oldName, with: newName)
            do {
                try FileManager.default.copyItem(atPath: originPath, toPath: newNamePath)
                do {
                    try FileManager.default.removeItem(atPath: originPath)
                    return true
                } catch {
                    return false
                }
            } catch {
                return false
            }
        }
        return false
    }
    
    /**
     Get the given settings for a given key
     - returns: Returns the object for the given key
     */
    public static func getSettings(settings: String, objectForKey: String) -> AnyObject? {
        var path: String = self.getLibraryDirectoryForFile(file: "")
        path = path.appending("/Preferences/")
        path = path.appending("\(settings)-Settings.plist")
        
        var loadedPlist: NSMutableDictionary
        if FileManager.default.fileExists(atPath: path)
        {
            loadedPlist = NSMutableDictionary(contentsOfFile: path)!
        } else {
            return nil
        }
        return loadedPlist.object(forKey: objectForKey) as AnyObject?
    }
    
    /**
     Set the given settings for a given object and key. The file will be saved in the Library directory
        
     - returns: Returns true if the operation was successful, otherwise false
     */
    public static func setSettings(settings: String, object: AnyObject, forKey objKey: String) -> Bool {
        var path: String = self.getLibraryDirectoryForFile(file: "")
        path = path.appending("/Preferences/")
        path = path.appending("\(settings)-Settings.plist")
        
        var loadedPlist: NSMutableDictionary
        if FileManager.default.fileExists(atPath: path) {
            loadedPlist = NSMutableDictionary(contentsOfFile: path)!
        } else {
            loadedPlist = NSMutableDictionary()
        }
        
        loadedPlist[objKey] = object
        
        return loadedPlist.write(toFile: path, atomically: true)
    }
    
    /**
     Set the App settings for a given object and key. The file will be saved in the Library directory

     - returns: Returns true if the operation was successful, otherwise false
     */
    public static func setAppSettingsForObject(object: AnyObject, forKey objKey: String) -> Bool
    {
        let infoDictionary: NSDictionary = Bundle.main.infoDictionary as NSDictionary!
        let appName: NSString = infoDictionary.object(forKey: "CFBundleName") as! NSString
        return self.setSettings(settings: appName as String, object: object, forKey: objKey)
    }
    
    /**
     Get the App settings for a given key
     
     - returns: Returns the object for the given key
     */
    public static func getAppSettingsForObjectWithKey(objKey: String) -> AnyObject?
    {
        let infoDictionary: NSDictionary = Bundle.main.infoDictionary as NSDictionary!
        let appName: String = infoDictionary.object(forKey: "CFBundleName") as! String
        return self.getSettings(settings: appName, objectForKey: objKey)
    }
    
    /**
     Create Directory in document folder
     returns: Returns string path of document directory
     */
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    
    func createDirectoryAtDocumentDirectoryName(directoryName:String) -> Bool{
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let dataPath = paths[0].appendingPathComponent(directoryName)
        
        if !fileExists(atPath: dataPath)
        {
            do {
                try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
                return true
            } catch let error as NSError {
                print(error.localizedDescription);
                return false
            }

        }
        else
        {
            return true
        }
    }
    
    func saveImageLocally(image:UIImage, atPath path:String){
        let fileManager = FileManager.default
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        fileManager.createFile(atPath: path, contents: imageData, attributes: nil)
    }
}
