//
//  constant.swift

import Foundation
import UIKit
import CoreLocation
import SystemConfiguration
import AVFoundation
import SwiftMessages

let loadercolor = [themeWakeUppColor, themeGreenColor] /*[Color_Hex(hex: "#eb1f20"),
                   Color_Hex(hex: "#ffae00")]*/
var spinner = RPLoadingAnimationView.init(frame: CGRect.zero)
var overlayView = UIView()
var hudLabel = UILabel.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: SCREENWIDTH(), height: 50)))
var hudText: String = ""{
    didSet{
        hudLabel.text = hudText
    }
}

var topbar : CGFloat{
    return UIApplication.shared.statusBarFrame.size.height + 50
}

var isDNDActive:Bool {
    return UserDefaultManager.getBooleanFromUserDefaults(key: kIsDNDActive)
}

let linearBar: LinearProgressBar = LinearProgressBar.init(frame: CGRect.init(x: 0, y: topbar, width: UIScreen.main.bounds.width, height: 3))

public func showHUD()
{
    DispatchQueue.main.async {
        overlayView.frame = (mostTopViewController?.view)!.frame
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        spinner = RPLoadingAnimationView(
            frame: CGRect(origin: CGPoint.zero, size: (mostTopViewController?.view)!.bounds.size),
            type: .rotatingCircle,
            colors: loadercolor,
            size: CGSize.init(width: 200.0, height: 200.0)
        )
        overlayView.addSubview(spinner)
        
        hudLabel.frame = overlayView.frame
        hudLabel.center = overlayView.center
        hudLabel.frame.origin.y = overlayView.frame.height - 50
        hudLabel.frame.size.height = 50
        
        hudLabel.textAlignment = .center
        hudLabel.font = UIFont.init(name: FT_Medium, size: 15)
        hudLabel.textColor = themeWakeUppColor
        hudLabel.text = hudText
        //hudLabel.backgroundColor = themeGreenColor
        
        overlayView.addSubview(hudLabel)
        
        //(mostTopViewController?.view)!.addSubview(overlayView)
        APP_DELEGATE.window?.addSubview(overlayView)
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        spinner.setupAnimation()
    }
}

public func hideHUD()
{
    DispatchQueue.main.async {
        spinner.removeFromSuperview()
        overlayView.removeFromSuperview()
        
        UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
    }
}

struct DIRECTORY_NAME
{
    public static let IMAGES = "Images"
    public static let VIDEOS = "Videos"
    public static let DOWNLOAD_VIDEOS = "Download_videos"
}

public let isSimulator: Bool = {
    var isSim = false
    #if arch(i386) || arch(x86_64)
        isSim = true
    #endif
    return isSim
}()

//MARK:- iOS Versions and screens

public var appDisplayName: String? {
    return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
}
public var appBundleID: String? {
    return Bundle.main.bundleIdentifier
}
public func IOS_VERSION() -> String {
    return UIDevice.current.systemVersion
}
public var statusBarHeight: CGFloat {
    return UIApplication.shared.statusBarFrame.height
}
public var applicationIconBadgeNumber: Int {
    get {
        return UIApplication.shared.applicationIconBadgeNumber
    }
    set {
        UIApplication.shared.applicationIconBadgeNumber = newValue
    }
}
public var appVersion: String? {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
}
public func SCREENWIDTH() -> CGFloat
{
    let screenSize = UIScreen.main.bounds
    return screenSize.width
}

public func SCREENHEIGHT() -> CGFloat
{
    let screenSize = UIScreen.main.bounds
    return screenSize.height
}
//MARK:-  Get VC
public func getStoryboard(storyboardName: String) -> UIStoryboard {
    return UIStoryboard(name: storyboardName, bundle: nil)
}

public func loadVC(strStoryboardId: String, strVCId: String) -> UIViewController {
    
    let vc = getStoryboard(storyboardName: strStoryboardId).instantiateViewController(withIdentifier: strVCId)
    return vc
}


//MARK:- SwiftMessage
//public func showLoaderHUD(strMessage:String)
//{
//    createGradientLayer(view: (mostTopViewController?.view)!, colorset: [UIColor.init(red: 13/255, green: 162/255, blue: 244/255, alpha: 1),
//                                                 UIColor.init(red: 21/255, green: 226/255, blue: 167/255, alpha: 1)], framerect: (mostTopViewController?.view)!.bounds)
//    LoadingHud.showHUD(view: (mostTopViewController?.view)!, withText: strMessage)
//}
//
//public func hideLoaderHUD()
//{
//    LoadingHud.dismissHUD()
//}
public func showLoaderHUD(strMessage:String)
{
    if strMessage.count > 0{
        showStatusBarMessage(strMessage)
    }
//    linearBar.backgroundProgressBarColor = themeBgColor
//    linearBar.progressBarColor = themeWakeUppColor
//    linearBar.heightForLinearBar = 2
//    linearBar.startAnimation()
}

public func hideLoaderHUD()
{
     SwiftMessages.hide()
//     linearBar.removeFromSuperview()
//     linearBar.heightForLinearBar = 0
//     linearBar.progressBarColor = UIColor.clear
//     linearBar.stopAnimation()
}
public func showBanner(message:String)
{
    
}

public func hideBanner()
{
    
}


//MARK:- Network indicator
public func ShowNetworkIndicator(xx :Bool)
{
    runOnMainThreadWithoutDeadlock {
        UIApplication.shared.isNetworkActivityIndicatorVisible = xx
    }
}

//MARK:- Share
public func share(shareContent:[Any]) -> Void  {
    
    // get curret visibleVC
    let objVisibleVC = APP_DELEGATE.appNavigation?.visibleViewController
    
    // set up activity view controller
    let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = objVisibleVC?.view // so that iPads won't crash
    
    activityViewController.excludedActivityTypes = [ .airDrop, .postToFacebook, .postToTwitter, .message, .mail, .postToFlickr, .copyToPasteboard]
    
    // present the view controller
    //self.present(activityViewController, animated: true, completion: nil)
    objVisibleVC?.present(activityViewController, animated: true, completion: nil)
}

//MARK:- Number
public func suffixNumber(number:NSNumber) -> NSString  {
    
    /*var num:Double = number.doubleValue;
     let sign = ((num < 0) ? "-" : "" );
     
     num = fabs(num);
     if (num < 1000.0){
     return "\(sign)\(num)" as NSString;
     }
     let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));
     let units:[String] = ["K","M","G","T","P","E"];
     let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;
     return "\(sign)\(roundedNum)\(units[exp-1])" as NSString;*/
    
    let number = number.doubleValue
    let thousand = number / 1000
    let million = number / 1000000
    if million >= 1.0 {
        return "\(round(million*10)/10)M" as NSString
    }
    else if thousand >= 1.0 {
        return "\(round(thousand*10)/10)K" as NSString
    }
    else {
        return "\(Int(number))" as NSString
    }
}

//MARK:- Validation
public func TRIM(string: Any) -> String
{
    return (string as AnyObject).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
}

public func validateTxtLength(_ txtVal: String, withMessage msg: String) -> Bool {
    if TRIM(string: txtVal).count == 0
    {
        showMessage(msg);
        return false
    }
    return true
}

public func validateTxtFieldLength(_ txtVal: UITextField, withMessage msg: String) -> Bool
{
    if TRIM(string: txtVal.text ?? "").count == 0
    {
        txtVal.shake()
         showMessage(msg);
        return false
    }
    return true
}

public func validateMinTxtFieldLength(_ txtVal: UITextField, lenght:Int, msg: String) -> Bool
{
    if TRIM(string: txtVal.text ?? "").count < lenght
    {
        txtVal.shake()
        showMessage(msg);
        return false
    }
    return true
}

public func validateMaxTxtFieldLength(_ txtVal: UITextField, lenght:Int,msg: String) -> Bool
{
    if TRIM(string: txtVal.text ?? "").count > lenght
    {
        txtVal.shake()
        showMessage(msg);
        return false
    }
    return true
}

public func passwordMismatch(_ txtVal: UITextField, _ txtVal1: UITextField, withMessage msg: String) -> Bool
{
    if TRIM(string: txtVal.text ?? "") != TRIM(string: txtVal1.text ?? "")
    {
        txtVal.shake()
        showMessage(msg);
        return false
    }
    return true
}

public func validateEmailAddress(_ txtVal: UITextField ,withMessage msg: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    if(emailTest.evaluate(with: txtVal.text) != true)
    {
        txtVal.shake()
        showMessage(msg);
        return false
    }
    return true
}

public func isBase64(stringBase64:String) -> Bool
{
    let regex = "([A-Za-z0-9+/]{4})*" + "([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)"
    let test = NSPredicate(format:"SELF MATCHES %@", regex)
    if(test.evaluate(with: stringBase64) != true)
    {
        return false
    }
    return true
}

/*public func isValidURL(stringURL:String) -> Bool {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    if let match = detector.firstMatch(in: stringURL, options: [], range: NSRange(location: 0, length: self.endIndex.encodedOffset)) {
        // it is a link, if the match covers the whole string
        return match.range.length == stringURL.endIndex.encodedOffset
    }
    return false
}*/

//MARK:- Check Internet connection
func isConnectedToNetwork() -> Bool
{
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    })
        else
    {
        return false
    }
    
    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    let available =  (isReachable && !needsConnection)
    if(available)
    {
        return true
    }
    else
    {
        showMessage(InternetNotAvailable)
        return false
    }
}

//MARK:- Helper
public func TableEmptyMessage(modulename:String, tbl:UITableView)
{
    let uiview = UIView(frame: Frame_XYWH(0, 0, tbl.frame.size.width, tbl.frame.size.height))
    let messageLabel = UILabel(frame: Frame_XYWH(0, 0, tbl.frame.size.width, 50))
    messageLabel.font = UIFont.init(name: FT_Light, size: 15)
    messageLabel.text = "\("No " + modulename + " Available.")"
    messageLabel.textColor = UIColor.lightGray
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = .center;
    if(modulename.count > 0)
    {
        messageLabel.setViewBottomBorder(borderColor: UIColor.lightGray)
    }
    uiview.addSubview(messageLabel)
    tbl.backgroundView = uiview;
    //tbl.separatorStyle = .singleLine;
}
func checkSearchBarActive(searchFriends:UISearchBar) -> Bool
{
    if searchFriends.isFirstResponder && searchFriends.text != "" {
        return true
    }
    else if(searchFriends.text != "")
    {
        return true
    }
    else {
        return false
    }
}
//MARK:-  Check Device is iPad or not

public  var isPad: Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

public var isPhone: Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}

public var isStatusBarHidden: Bool
{
    get {
        return UIApplication.shared.isStatusBarHidden
    }
    set {
        UIApplication.shared.isStatusBarHidden = newValue
    }
}

public var mostTopViewController: UIViewController? {
    get {
        let mostTop = UIApplication.shared.keyWindow?.rootViewController
        if let mostTopPresented = mostTop?.presentedViewController{
            return mostTopPresented
        }
        return mostTop
    }
    set {
        UIApplication.shared.keyWindow?.rootViewController = newValue
    }
}

//MARK:- Random str
func randomString(length: Int) -> String
{
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    var randomString = ""
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

func randomString() -> String
{
    var text = ""
    text = text.appending(CurrentTimeStamp)
    text = text.replacingOccurrences(of: ".", with: "")
    return text
}
//MARK:- Font
public func FontWithSize(_ fname: String,_ fsize: Int) -> UIFont
{
    return UIFont(name: fname, size: CGFloat(fsize))!
}

//MARK:- Color
public func Color_RGBA(_ R: Int,_ G: Int,_ B: Int,_ A: Int) -> UIColor
{
    return UIColor(red: CGFloat(R)/255.0, green: CGFloat(G)/255.0, blue: CGFloat(B)/255.0, alpha :CGFloat(A))
}
public func RGBA(_ R: Int,_ G: Int,_ B: Int,_ A: CGFloat) -> UIColor
{
    return UIColor(red: CGFloat(R)/255.0, green: CGFloat(G)/255.0, blue: CGFloat(B)/255.0, alpha :A)
}
public func Color_Hex(hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
public func createGradientLayer(view:UIView,colorset:[UIColor],framerect:CGRect)
{
    let layer = CAGradientLayer()
    layer.frame = framerect
    layer.colors = colorset
    view.layer.addSublayer(layer)
}

public func hideMessage()
{
    SwiftMessages.hide()
}

public func showMessageWithRetry(_ bodymsg:String ,_ msgtype:Int,buttonTapHandler: ((_ button: UIButton) -> Void)?)
{
    hideBanner()
    let view: MessageView  = try! SwiftMessages.viewFromNib()
    view.configureContent(title: "", body: bodymsg, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "Retry", buttonTapHandler: buttonTapHandler)
    view.configureDropShadow()
    var config = SwiftMessages.defaultConfig
    config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
    config.duration = .seconds(seconds: 7)
    view.configureTheme(.warning, iconStyle:  .light)
    view.titleLabel?.isHidden = true
    view.button?.isHidden = false
    view.button?.setTitleColor(.white, for: .normal)
    view.button?.backgroundColor = .clear
    view.button?.borderColor = .white
    view.button?.borderWidth = 1
    view.iconImageView?.isHidden = false
    view.iconLabel?.isHidden = false
    view.backgroundView.backgroundColor = themeWakeUppColor
    SwiftMessages.show(config: config, view: view)
}

public func showMessage(_ bodymsg:String)
{
    let view: MessageView  = try! SwiftMessages.viewFromNib()
    view.configureContent(title: "", body: bodymsg, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "Hide", buttonTapHandler: { _ in SwiftMessages.hide( ) })
    view.tapHandler = { _ in SwiftMessages.hide() }
    view.configureDropShadow()
    var config = SwiftMessages.defaultConfig
    config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
    config.duration = .seconds(seconds: 2)
    view.configureTheme(.warning, iconStyle:  .light)
    view.titleLabel?.isHidden = true
    view.button?.isHidden = true
    view.iconImageView?.isHidden = true
    view.iconLabel?.isHidden = true
    view.backgroundView.backgroundColor = themeWakeUppColor
    SwiftMessages.show(config: config, view: view)
}

public func showStatusBarMessage(_ bodymsg:String)
{
    guard bodymsg.count != 0 else{
        return
    }
    
    let view: MessageView  = MessageView.viewFromNib(layout: .statusLine)
    view.configureContent(title: "", body: bodymsg, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "Hide", buttonTapHandler: { _ in SwiftMessages.hide() })
    view.configureDropShadow()
    var config = SwiftMessages.defaultConfig
    config.presentationContext =  .window(windowLevel: UIWindowLevelStatusBar)
    config.duration = .seconds(seconds: 3)
    view.configureTheme(.success, iconStyle:  .light)
    view.titleLabel?.isHidden = true
    view.titleLabel?.textAlignment = .center
    view.button?.isHidden = true
    view.iconImageView?.isHidden = true
    view.iconLabel?.isHidden = true
    view.backgroundView.backgroundColor = themeWakeUppColor
    SwiftMessages.show(config: config, view: view)
}

//MARK:- Frames
public func Frame_XYWH(_ originx: CGFloat,_ originy: CGFloat,_ fwidth: CGFloat,_ fheight: CGFloat) -> CGRect
{
    return CGRect(x: originx, y:originy, width: fwidth, height: fheight)
}

public func randomColor() -> UIColor
{
    let r: UInt32 = arc4random_uniform(255)
    let g: UInt32 = arc4random_uniform(255)
    let b: UInt32 = arc4random_uniform(255)
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
}

//MARK:- Platform
struct Platform
{
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

//MARK:- Time Processing
func covertTimeToLocalZone(time:String) -> NSDate
{
    let dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    let inputTimeZone = NSTimeZone(abbreviation: "UTC")
    let inputDateFormatter = DateFormatter()
    inputDateFormatter.timeZone = inputTimeZone as TimeZone!
    inputDateFormatter.dateFormat = dateFormat
    let date = inputDateFormatter.date(from: time)
    let outputTimeZone = NSTimeZone.local
    let outputDateFormatter = DateFormatter()
    outputDateFormatter.timeZone = outputTimeZone
    outputDateFormatter.dateFormat = dateFormat
    let outputString = outputDateFormatter.string(from: date!)
    return outputDateFormatter.date(from: outputString)! as NSDate
}

public var CurrentTimeStamp: String
{
    return "\(NSDate().timeIntervalSince1970 * 1000)"
}

//MARK:- Time Ago Function

func timeAgoSinceStrDate(strDate:String, numericDates:Bool) -> String{
    
    /*let formato = DateFormatter()
     formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
     formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
     formato.formatterBehavior = .default
     let date = formato.date(from: strDate)!*/
    
    let date = convertDateAccordingDeviceTime(dategiven: strDate)
    
    //PV
    return timeAgoSinceDate(date: date as Date, numericDates: numericDates)
    //return DateFormater.generateTimeForGivenDate(strDate: date)
}

func timeAgoSinceDate(date:Date, numericDates:Bool) -> String
{
    let calendar = NSCalendar.current
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let now = NSDate()
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now as Date, options: [])
    if (components.year! >= 2)
    {
        return "\(components.year!)" + " years"
    }
    else if (components.year! >= 1)
    {
        if (numericDates){
            return "1 year"
        } else {
            return "Last year"
        }
    }
    else if (components.month! >= 2) {
        return "\(components.month!)" + " months"
    }
    else if (components.month! >= 1){
        if (numericDates){
            return "1 month"
        } else {
            return "Last month"
        }
    }
    else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!)" + " weeks"
    }
    else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week"
        } else {
            return "Last week"
        }
    }
    else if (components.day! >= 2) {
        return "\(components.day!)" + " days"
    }
    else if (components.day! >= 1){
        if (numericDates){
            return "1 day"
        } else {
            return "Yesterday"
        }
    }
    else if (components.hour! >= 2) {
        return "\(components.hour!)" + " hours"
    }
    else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour"
        } else {
            return "An hour"
        }
    }
    else if (components.minute! >= 2)
    {
        return "\(components.minute!)" + " min"
    } else if (components.minute! > 1){
        if (numericDates){
            return "1 min"
        } else {
            return "A min"
        }
    }
    else if (components.second! >= 3) {
        return "\(components.second!)" + " sec"
    } else {
        return "now"
    }
}

func convertDateAccordingDeviceTime(dategiven:String) -> NSDate
{
    if dategiven.contains("null") == false
    {
        var strDate = dategiven.replacingOccurrences(of: " ", with: "T")
        if strDate.components(separatedBy: ".").count < 2{
            strDate = "\(strDate).000Z"
        }
        
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        /*if dategiven.contains("'") == false{
         dateFormat = "yyyy-MM-ddTHH:mm:ss.SSSZ"
         }*/
        let inputTimeZone = NSTimeZone(abbreviation: "UTC")
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = inputTimeZone as TimeZone!
        inputDateFormatter.dateFormat = dateFormat
        let date = inputDateFormatter.date(from: strDate)
        let outputTimeZone = NSTimeZone.local
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.timeZone = outputTimeZone
        outputDateFormatter.dateFormat = dateFormat
        
        let outputString = outputDateFormatter.string(from: date!)
        
        return outputDateFormatter.date(from: outputString)! as NSDate
    }
    else
    {
        return Date() as NSDate
    }
}

func convertDateAccordingDeviceTimeString(dategiven:String) -> String
{
    let inputDateFormatter = DateFormatter()
    let outputDateFormatter = DateFormatter()
    
    let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    let inputTimeZone = NSTimeZone(abbreviation: "UTC")
    
    inputDateFormatter.timeZone = inputTimeZone as TimeZone!
    inputDateFormatter.dateFormat = dateFormat
    let date = inputDateFormatter.date(from: dategiven)
    let outputTimeZone = NSTimeZone.local
    
    outputDateFormatter.timeZone = outputTimeZone
    outputDateFormatter.dateFormat = dateFormat
    let outputString = outputDateFormatter.string(from: date!)
    return outputString
}

//MARK:- Animation
func addActivityIndicatior(activityview:UIActivityIndicatorView,button:UIButton)
{
    activityview.isHidden = false
    activityview.startAnimating()
     button.isEnabled = false
    button.backgroundColor = RGBA(181, 131, 0, 0.4)
}
func hideActivityIndicatior(activityview:UIActivityIndicatorView,button:UIButton)
{
    activityview.isHidden = true
    activityview.stopAnimating()
    button.isEnabled = true
    button.backgroundColor = RGBA(181, 131, 0, 1.0)
}
func animateview(vw1 : UIView,vw2:UIView)
{
    UIView.animate(withDuration: 0.1,
                   delay: 0.1,
                   options: UIViewAnimationOptions.curveEaseIn,
                   animations: { () -> Void in
                    vw1.alpha = 0;
                    vw2.alpha = 1;
    }, completion: { (finished) -> Void in
        vw1.isHidden = true;
    })
}
func viewSlideInFromBottom(toTop views: UIView)
{
    let transition = CATransition()
    transition.duration = 0.8
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    transition.type = kCATransitionPush
    transition.subtype = kCATransitionFromTop
    views.layer.add(transition, forKey: nil)
}
func viewSlideInFromTop(toBottom views: UIView)
{
    let transition = CATransition()
    transition.duration = 0.5
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    transition.type = kCATransitionPush
    transition.subtype = kCATransitionFromBottom
    views.layer.add(transition, forKey: nil)
}

//MARK:- Country code
func setDefaultCountryCode() -> String
{
    let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
    return "+" + getCountryPhonceCode(countryCode!)
}

//MARK:- Image/Video Processing
public func Set_Local_Image(imageName :String) -> UIImage
{
    return UIImage(named:imageName)!
}
func getVideoThumbnail(videoURL:URL,withSeconds:Bool = false) -> UIImage?
{
    let timeSeconds = 2
    let asset = AVAsset(url: videoURL)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    var time = asset.duration
    
    if(withSeconds) {
        time.value = min(time.value, CMTimeValue(timeSeconds))
    }
    else {
        time = CMTimeMultiplyByFloat64(time, 0.5)
    }
    
    do {
        //let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        let imageRef = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
        return UIImage(cgImage: imageRef)
    }
    catch _ as NSError {
        return nil
    }
}

func fixOrientationOfImage(image: UIImage) -> UIImage?
{
    if image.imageOrientation == .up
    {return image}
    var transform = CGAffineTransform.identity
    switch image.imageOrientation
    {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by:  CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by:  -CGFloat(Double.pi / 2))
        default:
            break
    }
    switch image.imageOrientation
    {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
    }
    guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
        return nil
    }
    context.concatenate(transform)
    switch image.imageOrientation
    {
    case .left, .leftMirrored, .right, .rightMirrored:
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
    default:
        context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
    }
    guard let CGImage = context.makeImage() else {
        return nil
    }
    return UIImage(cgImage: CGImage)
}

func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ session: AVAssetExportSession)-> Void)
{
    let urlAsset = AVURLAsset(url: inputURL, options: nil)
    let exportSession = AVAssetExportSession(asset: urlAsset, presetName:AVAssetExportPreset640x480)//AVAssetExportPresetMediumQuality
    exportSession!.outputURL = outputURL
    exportSession!.outputFileType = AVFileType.mp4
    exportSession!.shouldOptimizeForNetworkUse = true
    exportSession!.exportAsynchronously { () -> Void in
        handler(exportSession!)
    }
}

func getCountryPhonceCode (_ country : String) -> String
{
    var countryDictionary  = ["AF":"93",
                              "AL":"355",
                              "DZ":"213",
                              "AS":"1",
                              "AD":"376",
                              "AO":"244",
                              "AI":"1",
                              "AG":"1",
                              "AR":"54",
                              "AM":"374",
                              "AW":"297",
                              "AU":"61",
                              "AT":"43",
                              "AZ":"994",
                              "BS":"1",
                              "BH":"973",
                              "BD":"880",
                              "BB":"1",
                              "BY":"375",
                              "BE":"32",
                              "BZ":"501",
                              "BJ":"229",
                              "BM":"1",
                              "BT":"975",
                              "BA":"387",
                              "BW":"267",
                              "BR":"55",
                              "IO":"246",
                              "BG":"359",
                              "BF":"226",
                              "BI":"257",
                              "KH":"855",
                              "CM":"237",
                              "CA":"1",
                              "CV":"238",
                              "KY":"345",
                              "CF":"236",
                              "TD":"235",
                              "CL":"56",
                              "CN":"86",
                              "CX":"61",
                              "CO":"57",
                              "KM":"269",
                              "CG":"242",
                              "CK":"682",
                              "CR":"506",
                              "HR":"385",
                              "CU":"53",
                              "CY":"537",
                              "CZ":"420",
                              "DK":"45",
                              "DJ":"253",
                              "DM":"1",
                              "DO":"1",
                              "EC":"593",
                              "EG":"20",
                              "SV":"503",
                              "GQ":"240",
                              "ER":"291",
                              "EE":"372",
                              "ET":"251",
                              "FO":"298",
                              "FJ":"679",
                              "FI":"358",
                              "FR":"33",
                              "GF":"594",
                              "PF":"689",
                              "GA":"241",
                              "GM":"220",
                              "GE":"995",
                              "DE":"49",
                              "GH":"233",
                              "GI":"350",
                              "GR":"30",
                              "GL":"299",
                              "GD":"1",
                              "GP":"590",
                              "GU":"1",
                              "GT":"502",
                              "GN":"224",
                              "GW":"245",
                              "GY":"595",
                              "HT":"509",
                              "HN":"504",
                              "HU":"36",
                              "IS":"354",
                              "IN":"91",
                              "ID":"62",
                              "IQ":"964",
                              "IE":"353",
                              "IL":"972",
                              "IT":"39",
                              "JM":"1",
                              "JP":"81",
                              "JO":"962",
                              "KZ":"77",
                              "KE":"254",
                              "KI":"686",
                              "KW":"965",
                              "KG":"996",
                              "LV":"371",
                              "LB":"961",
                              "LS":"266",
                              "LR":"231",
                              "LI":"423",
                              "LT":"370",
                              "LU":"352",
                              "MG":"261",
                              "MW":"265",
                              "MY":"60",
                              "MV":"960",
                              "ML":"223",
                              "MT":"356",
                              "MH":"692",
                              "MQ":"596",
                              "MR":"222",
                              "MU":"230",
                              "YT":"262",
                              "MX":"52",
                              "MC":"377",
                              "MN":"976",
                              "ME":"382",
                              "MS":"1",
                              "MA":"212",
                              "MM":"95",
                              "NA":"264",
                              "NR":"674",
                              "NP":"977",
                              "NL":"31",
                              "AN":"599",
                              "NC":"687",
                              "NZ":"64",
                              "NI":"505",
                              "NE":"227",
                              "NG":"234",
                              "NU":"683",
                              "NF":"672",
                              "MP":"1",
                              "NO":"47",
                              "OM":"968",
                              "PK":"92",
                              "PW":"680",
                              "PA":"507",
                              "PG":"675",
                              "PY":"595",
                              "PE":"51",
                              "PH":"63",
                              "PL":"48",
                              "PT":"351",
                              "PR":"1",
                              "QA":"974",
                              "RO":"40",
                              "RW":"250",
                              "WS":"685",
                              "SM":"378",
                              "SA":"966",
                              "SN":"221",
                              "RS":"381",
                              "SC":"248",
                              "SL":"232",
                              "SG":"65",
                              "SK":"421",
                              "SI":"386",
                              "SB":"677",
                              "ZA":"27",
                              "GS":"500",
                              "ES":"34",
                              "LK":"94",
                              "SD":"249",
                              "SR":"597",
                              "SZ":"268",
                              "SE":"46",
                              "CH":"41",
                              "TJ":"992",
                              "TH":"66",
                              "TG":"228",
                              "TK":"690",
                              "TO":"676",
                              "TT":"1",
                              "TN":"216",
                              "TR":"90",
                              "TM":"993",
                              "TC":"1",
                              "TV":"688",
                              "UG":"256",
                              "UA":"380",
                              "AE":"971",
                              "GB":"44",
                              "US":"1",
                              "UY":"598",
                              "UZ":"998",
                              "VU":"678",
                              "WF":"681",
                              "YE":"967",
                              "ZM":"260",
                              "ZW":"263",
                              "BO":"591",
                              "BN":"673",
                              "CC":"61",
                              "CD":"243",
                              "CI":"225",
                              "FK":"500",
                              "GG":"44",
                              "VA":"379",
                              "HK":"852",
                              "IR":"98",
                              "IM":"44",
                              "JE":"44",
                              "KP":"850",
                              "KR":"82",
                              "LA":"856",
                              "LY":"218",
                              "MO":"853",
                              "MK":"389",
                              "FM":"691",
                              "MD":"373",
                              "MZ":"258",
                              "PS":"970",
                              "PN":"872",
                              "RE":"262",
                              "RU":"7",
                              "BL":"590",
                              "SH":"290",
                              "KN":"1",
                              "LC":"1",
                              "MF":"590",
                              "PM":"508",
                              "VC":"1",
                              "ST":"239",
                              "SO":"252",
                              "SJ":"47",
                              "SY":"963",
                              "TW":"886",
                              "TZ":"255",
                              "TL":"670",
                              "VE":"58",
                              "VN":"84",
                              "VG":"284",
                              "VI":"340"]
    let cname = country.uppercased()
    if countryDictionary[cname] != nil
    {
        return countryDictionary[cname]!
    }
    else
    {
        return cname
    }
}
//MARK:- Check string is available or not
public func isLike(source: String , compare: String) ->Bool
{
    var exists = true
    ((source).lowercased().range(of: compare) != nil) ? (exists = true) :  (exists = false)
    return exists
}

//Mark : string to dictionary
public func convertStringToDictionary(str:String) -> [String: Any]? {
    //let strDecodeMess : String = str.base64Decoded!
    //if let data = strDecodeMess.data(using: .utf8) {
    if let data = str.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
//Mark : dictionary to string
public func convertDictionaryToJSONString(dic:NSDictionary) -> String? {
    do{
        let jsonData: Data? = try JSONSerialization.data(withJSONObject: dic, options: [])
        var myString: String? = nil
        if let aData = jsonData {
            myString = String(data: aData, encoding: .utf8)
        }
        return myString
    }catch{
        print(error)
    }
    return ""
}

//MARK:- Calculate heght of label
public func calculatedHeight(string :String,withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat
{
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
    return boundingBox.height
}

public func calculatedWidth(string :String,withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat
{
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
    return boundingBox.width
}

//MARK:- Mile to Km

public func mileToKilometer(myDistance : Int) -> Float
{
    return Float(myDistance) * 1.60934
}

//MARK:- Kilometer to Mile
public func KilometerToMile(myDistance : Double) -> Double {
    return (myDistance) * 0.621371192
}

public func DegreesToRadians(degrees: Float) -> Float {
    return Float(Double(degrees) * .pi / 180)
}

//MARK:- NULL to NIL
public func NULL_TO_NIL(value : AnyObject?) -> AnyObject? {
    
    if value is NSNull {
        return "" as AnyObject?
    } else {
        return value
    }
}
//MARK:- Log trace
public func DLog<T>(message:T,  file: String = #file, function: String = #function, lineNumber: Int = #line ) {
    #if DEBUG
        if message is String {
            
            //print("\((file as NSString).lastPathComponent) -> \(function) line: \(lineNumber): \(text)")
        }
    #endif
}

//MARK:- File Manager

func getDocumentsDirectoryURL() -> URL? {
    let fileManager = FileManager.default
    do {
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        return documentDirectory
    }
    catch{
        print(error)
    }
    return nil
}

func saveFileDataLocally(data:Data, with FileName:String)->Bool{
    let filepath = getDocumentsDirectoryURL()?.appendingPathComponent(FileName)
    do{
        try data.write(to: filepath!, options: .atomic)
        return true
    }catch{
        print(error.localizedDescription)
        return false
    }
}

func getLocallySavedFileData(With FileName:String) -> Data?{
    let filepath = (getDocumentsDirectoryURL()?.appendingPathComponent(FileName))!
    if isFileLocallySaved(fileUrl: filepath){
        return try? Data.init(contentsOf: filepath)
    }else{
        return nil
    }
}

func removeFileFromLocal(_ filename: String) {
    let fileManager = FileManager.default
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let filePath = URL(fileURLWithPath: documentsPath).appendingPathComponent(filename).absoluteString
    
    do{
        try fileManager.removeItem(atPath: filePath)
    }
    catch{
        //print("Could not delete file -:\(error.localizedDescription) ")
    }
}

func isFileLocallySaved(fileUrl:URL) -> Bool{
    let fileName = fileUrl.lastPathComponent
    let filePath = getDocumentsDirectoryURL()?.appendingPathComponent(fileName)
    let fileManager = FileManager.default
    // Check if file exists
    if fileManager.fileExists(atPath: filePath!.path) {
        return true
    } else {
        return false
    }
}

func getLocallySavedFileURL(with fileUrl:URL) -> URL? {
    if(isFileLocallySaved(fileUrl: fileUrl)){
        let fileName = fileUrl.lastPathComponent
        let filePath = getDocumentsDirectoryURL()?.appendingPathComponent(fileName)
        return filePath
    }
    return nil
}

func timeFormatted(_ totalSeconds: Int) -> String? {
    let seconds: Int = totalSeconds % 60
    let minutes: Int = (totalSeconds / 60) % 60
    let hours: Int = totalSeconds / 3600
    var timeString = ""
    var formatString = ""
    if hours > 0 {
        formatString = hours == 1 ? "%d hour" : "%d hours"
        timeString = timeString + (String(format: formatString, hours))
    }
    if minutes > 0 || hours > 0 {
        formatString = minutes == 1 ? " %d minute" : " %d minutes"
        timeString = timeString + (String(format: formatString, minutes))
    }
    if seconds > 0 || hours > 0 || minutes > 0 {
        formatString = seconds == 1 ? " %d second" : " %d seconds"
        timeString = timeString + (String(format: formatString, seconds))
    }
    
    timeString = "\(hours):\(minutes):\(seconds)"
    timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    
    return timeString
}

func postNotification(with Name:String, andUserInfo userInfo:[AnyHashable : Any]? = nil){
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Name), object: nil, userInfo: userInfo)
}

//MARK:-
func isPathForImage(path:String) -> Bool{
    let fileExt = (path.lastPathComponent.components(separatedBy: ".").last!).lowercased()
    
    switch fileExt {
    case "png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp":
        return true
    default:
        return false
    }
}

func isPathForVideo(path:String) -> Bool{
    let fileExt = (path.lastPathComponent.components(separatedBy: ".").last!).lowercased()
    
    switch fileExt {
    case "avi", "flv", "mov", "wmv", "mp4", "m4v", "3gp":
        return true
    default:
        return false
    }
}

func isPathForContact(path:String) -> Bool{
    let fileExt = (path.lastPathComponent.components(separatedBy: ".").last!).lowercased()
    
    switch fileExt {
    case "vcf", "vcard":
        return true
    default:
        return false
    }
}

func isPathForAudio(path:String) -> Bool{
    let fileExt = (path.lastPathComponent.components(separatedBy: ".").last!).lowercased()
    
    switch fileExt {
    case "m4a", "aac", "wav", "mp3":
        return true
    default:
        return false
    }
}

func getFileType(for Path: String) -> String{
    var fileType = ""
    let fileExtension = Path.lastPathComponent.components(separatedBy: ".").last!
    
    switch fileExtension {
    case FILE_DOC, FILE_DOCX:
        fileType = "Word Document"
    case FILE_XLS, FILE_XLSX:
        fileType = "Excel Sheet"
    case FILE_TXT:
        fileType = "Plain Text"
    case FILE_RTF:
        fileType = "Rich Text"
    case FILE_PDF:
        fileType = "Portable Document"
    case FILE_WAV, FILE_MP3, FILE_M4A:
        fileType = "Audio File"
    default:
        if isPathForImage(path: Path) {
            fileType = "Image File"//📷
        }else {
            fileType = "Other"
        }
    }
    
    return fileType
}

func getFileIcon(for Path: String) -> UIImage{
    var img = UIImage.init()
    let fileExtension = Path.lastPathComponent.components(separatedBy: ".").last!
    
    switch fileExtension {
    case FILE_DOC, FILE_DOCX:
        img = #imageLiteral(resourceName: "ic_attach_doc")
    case FILE_XLS, FILE_XLSX:
        img = #imageLiteral(resourceName: "ic_attach_xls")
    case FILE_TXT:
        img = #imageLiteral(resourceName: "ic_attach_txt")
    case FILE_RTF:
        img = #imageLiteral(resourceName: "ic_attach_rtf")
    case FILE_PDF:
        img = #imageLiteral(resourceName: "ic_attach_pdf")
    case FILE_WAV, FILE_MP3, FILE_M4A:
        img = #imageLiteral(resourceName: "ic_attach_audio")
    default:
        img = #imageLiteral(resourceName: "ic_attach_other")
    }
    
    return img
}



//MARK: - UserDfaults Related Function
func isMutedChat(userId:String) -> Bool{
    let mutedByMe = UserDefaultManager.getStringFromUserDefaults(key: kMutedByMe)
    
    if userId == "" || mutedByMe == ""
    {
         return false
    }
    else
    {
      let arrMutedUserIds = mutedByMe.components(separatedBy: ",")
        if arrMutedUserIds.contains(userId){
            return true
        }
        return false
    }
  
}

func isMutedGroupChat(groupId:String) -> Bool{
    if let group = CoreDBManager.sharedDatabase.getGroupById(groupId: groupId) {
        let arrMutedUsers = group.muted_by.components(separatedBy: ",")
        if arrMutedUsers.contains(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)){
            return true
        }
    }
    return false
}

func getAuthForService() -> [String:Any]{
    return [
        "token": UserDefaultManager.getStringFromUserDefaults(key:kToken),
        "id": UserDefaultManager.getStringFromUserDefaults(key:kAppUserId),
    ]
}

func openDropDown(From sender: UIButton, with Items:[String], completion: @escaping (_ selectedMenuIndex: Int) -> Void){
    let arrMenus = Items
    let width = 180
    let height = arrMenus.count * 40
   
    let aView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height + 10))
    aView.backgroundColor = .clear
    
    let myViewObject = UIView.loadFromNib(named: "DropdownView") as! DropdownView
    myViewObject.arrMenus = arrMenus
    myViewObject.frame = CGRect.init(x: 0, y: 10, width:width, height: height)
    aView.addSubview(myViewObject)
    
    let popover = Popover(
        options: [
            .type(PopoverType.down),
            PopoverOption.blackOverlayColor(UIColor.black.withAlphaComponent(0.3)),
            PopoverOption.sideEdge(8),
            PopoverOption.arrowSize(CGSize(width: 12, height: 6))], //here
        showHandler: nil, dismissHandler: nil)
    
    
    myViewObject.selectionHandler = ({ selectedMenuIndex in
        popover.didDismissHandler = {
            completion(selectedMenuIndex)
        }
        popover.dismiss()
    })
    
   
    let position = CGPoint.init(x: sender.center.x, y: sender.center.y + 30)
    popover.show(aView, point: position)
}

func checkSearchBarActive(searchbar:UISearchBar) -> Bool {
    if searchbar.isFirstResponder && searchbar.text != "" {
        return true
    }
    else if(searchbar.text != "")
    {
        return true
    }
    else {
        return false
    }
}

/*func call_updateStoryview(_ uid1:String, _ sid1:String)
{
    let msgDictionary = ["user_id":uid1,
                         "statusids":sid1,
                         "viewer_id":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),"viewer_name":UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),"view_date":DateFormater.getFullDateStringFromDate(givenDate: Date() as NSDate),"viewer_pic":UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile)]
    APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyUpdateReadStatusStory,msgDictionary).timingOut(after: 60)
    {data in
        print(data)
        CoreDBManager.sharedDatabase.udpateViewerList(uid: uid1, sid: sid1, vid: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId), prof: UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile), nm: UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName), tm: DateFormater.getStringFromDate(givenDate: Date() as NSDate))
    }
}*/

func inviteFriend(){
    let strMess : String = "Check out \(APPNAME), I use it to message and call the people I care about. Get it for free at \(liveAppUrl)"
    share(shareContent: [#imageLiteral(resourceName: "wakeupp_logo"),strMess])
}

func openVideoCallScreen(roomname:String, callerId:String, callerName:String, callerPhoto:String){
    let vcs = APP_DELEGATE.appNavigation!.viewControllers
    if vcs.contains(where: {$0 is VideoCallVC}){
        //VideoCallVC (Screen) is already open
        //print("Push received for Video Call")
    }else{
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idVideoCallVC) as! VideoCallVC
        vc.userID = callerId
        vc.userName = callerName
        vc.roomName = roomname
        vc.isReceivedCall = true
        vc.userPhoto = callerPhoto
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
}

func addBlurAboveImage(_ img:UIImageView,_ alphavalue:Float)
{
    img.blurView.setup(style: UIBlurEffectStyle.light, alpha: CGFloat(alphavalue)).enable()
}

func removeBlurAboveImage(_ img:UIImageView)
{
    img.blurView.removeBlur()
}

//Payal mem
func fileSize(url: URL?) -> String {
    
    guard let filePath = url?.path else {
        return "0"
    }
    do {
        let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
        if let size = attribute[FileAttributeKey.size] as? NSNumber
        {
            return "\((size).uint64Value)"
        }
    } catch {
        //print("Error: \(error)")
    }
    return "0"
}

func fileSizeInMB(_ bts:String) -> String
{
    if (bts == "0") { return "\(0) MB" }
    /*guard let filePath = url?.path else {
        return "\(0) MB"
    }
    do {
        let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
        if let size = attribute[FileAttributeKey.size] as? NSNumber {
            return String(format: "%.2f MB", size.doubleValue / 1000000.0)
        }
    } catch {
        //print("Error: \(error)")
    }
    return "\(0) MB"*/
    
    //print("bts: \(bts)")
    //let value = String(format: "%.2f MB", Int(bts).aDoubleOrEmpty() / 1000000.0)
    let bytes : Int64 = Int64(bts)!
    let value = ByteCountFormatter.string(fromByteCount: bytes, countStyle: ByteCountFormatter.CountStyle.binary)
    //print("value: \(value)")
    return value
}

func fileSizedetail(url: URL?) -> String {
    guard let filePath = url?.path else {
        return "\(0) MB"
    }
    
    do {
        let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
        if let size = attribute[FileAttributeKey.size] as? NSNumber {
            //return String(format: "%.2f MB", size.doubleValue / 1000000.0)
            
            let value = ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: ByteCountFormatter.CountStyle.binary)
            return value
        }
    } catch {
        //print("Error: \(error)")
    }
    return "\(0) MB"
}

func getfileCreatedDate(url: URL?) -> String {
    
    guard let filePath = url?.path else {
        return ""
    }
    
    do {
        //let aFileAttributes = try FileManager.default.attributesOfItem(atPath: theFile) as [FileAttributeKey:Any]
        //theCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date
        
        let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
        if let date = attribute[FileAttributeKey.creationDate] {
            //print("date: \(date)")
            
            //return date as! String
            var strDate : String = "\(date)"
            let date = covertTimeToLocalZone(time: strDate)
            //strDate = timeAgoSinceDate(date: date as Date, numericDates: true)
            strDate = DateFormater.generateDateForGivenDateToServerTimeZone(givenDate: date)
            return strDate.count == 0 ? "" : strDate
        }
        
    } catch let theError as Error {
        //print("file not found \(theError)")
        return ""
    }
    return ""
}

/*
func create_folder(folderName:String, inFolder:URL) -> URL? {
    if (inFolder.absoluteString.count == 0) { return URL(fileURLWithPath: "") }
    
    let fileManager = FileManager.default
    let filePath =  inFolder.appendingPathComponent("\(folderName)")
    if !fileManager.fileExists(atPath: filePath.path) {
        do {
            try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            NSLog("Couldn't create directory")
            return nil
        }
    }
    NSLog("create folder path : \(filePath)")
    return filePath as URL
}

func CreateFolder_inDirectory() {
    let fileManager = FileManager.default
    if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        let url_WakeUpp : URL = create_folder(folderName: Folder_WakeUpp, inFolder: tDocumentDirectory)!
        UserDefaultManager.setStringToUserDefaults(value: "\(url_WakeUpp)", key: kFolderURL_WakeUpp)
        //print("url_WakeUpp : \(getURL_WakeUpp_Directory())")
        
        //Group
        runAfterTime(time: 0.10) {
            let url_Group : URL = create_folder(folderName: Folder_Group, inFolder: url_WakeUpp)!
            UserDefaultManager.setStringToUserDefaults(value: "\(url_Group)", key: kFolderURL_Group)
            //print("url_Group : \(getURL_Group_Directory())")
        }
        
        //Chat
        runAfterTime(time: 0.10) {
            let url_Chat : URL = create_folder(folderName: Folder_Chat, inFolder: url_WakeUpp)!
            UserDefaultManager.setStringToUserDefaults(value: "\(url_Chat)", key: kFolderURL_Chat)
            //print("url_Chat : \(getURL_Chat_Directory())")
        }
    }
    else {
        showMessage("Something was wrong.")
        //exit(1) //Exit the App OR re-install the app show mess.
    }
}

func getURL_WakeUpp_Directory() -> URL {
    //let dirURL : URL = URL(fileURLWithPath: UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_WakeUpp))
    let dirURL : URL = UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_WakeUpp).url!
    //print("getURL_WakeUpp_Directory : \(dirURL)")
    return dirURL
}


func getURL_Group_Directory() -> URL {
    let dirURL : URL = UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_Group).url!
    //print("getURL_Group_Directory : \(dirURL)")
    return dirURL
}

func getURL_Chat_Directory() -> URL {
    //let dirURL : URL = URL(fileURLWithPath: UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_Chat))
    let dirURL : URL = UserDefaultManager.getStringFromUserDefaults(key: kFolderURL_Chat).url!
    //print("getURL_Chat_Directory : \(dirURL)")
    return dirURL
}

func getURL_ChatWithUser_Directory(countryCode:String, PhoneNo : String) -> URL {
    let strFullContactNo : String = "\(countryCode)\(PhoneNo)"
    if (strFullContactNo.count == 0) { return NSURL.init().baseURL! }
    
    var strFolderName : String = "\(Folder_Chat)_\(strFullContactNo)"
    strFolderName = strFolderName.replacingOccurrences(of: " ", with: "")
    
    let chatBackupFolderURL : URL = create_folder(folderName: strFolderName, inFolder:getURL_Chat_Directory())!
    
    return chatBackupFolderURL
}


func getURL_GroupChat_Directory(groupID:String) -> URL {
    let strGroupName : String = "\(groupID)"
    if (strGroupName.count == 0) { return NSURL.init().baseURL! }
    
    var strFolderName : String = "\(Folder_Group)_\(strGroupName)"
    strFolderName = strFolderName.replacingOccurrences(of: " ", with: "")
    
    let groupChatBackupFolderURL : URL = create_folder(folderName: strFolderName, inFolder:getURL_Group_Directory())!
    return groupChatBackupFolderURL
}

//MARK:
func isFileLocallyExist(fileName:String, inDirectory:URL) -> Bool {
    let filePath = inDirectory.appendingPathComponent(fileName)
    let fileManager = FileManager.default
    
    // Check if file exists
    if fileManager.fileExists(atPath: filePath.path) { return true }
    else { return false }
}

func getURL_LocallyExistFileURL(fileName:String, inDirectory:URL) -> URL {
    if isFileLocallyExist(fileName: fileName, inDirectory: inDirectory) == true {
        let filePath = inDirectory.appendingPathComponent(fileName)
        return filePath
    }
    return NSURL.init() as URL
}

func removeFile_onURL(fileURL:URL) {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fileURL.path) {
        do {
            //try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
            try fileManager.removeItem(at: fileURL)
            NSLog("SUCCESS : Remove file")
        } catch {
            NSLog("Error : Remove file.")
        }
    }
    //NSLog("SUCCESS : Remove file")
}

func getAllContent_inDir(dirURL:URL) -> Array<URL> {
    var arrData : [URL] = []
    
    do {
        let directoryContents = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options: [])
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


func get_fileName_asCurretDateTime() -> String {
    var strName : String = ""
    
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmmss"
    strName = formatter.string(from: date)
    
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
*/

func timeAgoSinceStrDate1(strDate:String, numericDates:Bool,isFutur:Bool = false) -> String{
    
    /*let formato = DateFormatter()
     formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
     formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
     formato.formatterBehavior = .default
     let date = formato.date(from: strDate)!*/
    
    let date = convertDateAccordingDeviceTime(dategiven: strDate)
    
    if(isFutur == true)
    {
        return timeAgoSinceDateFuture(date: date as Date, numericDates: numericDates)
    }
    else
    {
        return timeAgoSinceDate(date: date as Date, numericDates: numericDates)
    }
    //PV
    
    //return DateFormater.generateTimeForGivenDate(strDate: date)
}

func timeAgoSinceDateFuture(date:Date, numericDates:Bool) -> String
{
    let calendar = NSCalendar.current
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let now = NSDate()
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now as Date, options: [])
    if (abs(components.year!) >= 2)
    {
        return "\(abs(components.year!))" + " years from now"
    }
    else if (abs(components.year!) >= 1)
    {
        if (numericDates){
            return "\(abs(components.year!)) year from now"
        } else {
            return "Next year"
        }
    }
    else if (abs(components.month!) >= 2) {
        return "\(abs(components.month!))" + " months from now"
    }
    else if (abs(components.month!) >= 1){
        if (numericDates){
            return "\(abs(components.month!)) month from now"
        } else {
            return "Next month"
        }
    }
    else if (abs(components.weekOfYear!) >= 2) {
        return "\(abs(components.weekOfYear!))" + " weeks from now"
    }
    else if (abs(components.weekOfYear!) >= 1){
        if (numericDates){
            return "\(abs(components.weekOfYear!)) week from now"
        } else {
            return "Next week"
        }
    }
    else if (abs(components.day!) >= 2) {
        return "\(abs(components.day!))" + " days from now"
    }
    else if (abs(components.day!) >= 1){
        if (numericDates){
            return "\(abs(components.day!)) day from now"
        } else {
            return "Tomorrow"
        }
    }
    else if (abs(components.hour!) >= 2) {
        return "\(abs(components.hour!))" + " hours from now"
    }
    else if (abs(components.hour!) >= 1){
        if (numericDates){
            return "\(abs(components.hour!)) hour from now"
        } else {
            return "An hour from now"
        }
    }
    else if (abs(components.minute!) >= 2)
    {
        return "\(abs(components.minute!))" + " min from now"
    } else if (abs(components.minute!) > 1){
        if (numericDates){
            return "\(abs(components.minute!)) min from now"
        } else {
            return "A min from now"
        }
    }
    else if (abs(components.second!) >= 3) {
        return "\(abs(components.second!))" + " sec from now"
    } else {
        return "Just now"
    }
}


