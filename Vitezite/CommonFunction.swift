//
//  CommonFunction.swift
//  LocumDay
//
//  Created by Bhuvan Sharma on 11/30/15.
//  Copyright © 2015 Bhuvan Sharma. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

let charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

let heightRatio = UIScreen.mainScreen().bounds.height / 736
let widthRatio = UIScreen.mainScreen().bounds.width / 736

let kDeviceToken            =  "ViteziteDeviceToken"
let kProjectName            = "Vitezite"
let kUserId                      = "ViteziteUserId"
let kRegisterUserInfo      = "RegisterUserInfo"

public enum Message: String
{
    case kUserTitleBlank                                        =        "Please select Title."
    case kClassNameBlank                                    =        "Please enter your school name."
    case kUserLastNameBlank                                 =        "Please enter last name."
    case kUserFirstNameBlank                                =        "Please enter first name."
    case kUserEmailPasswordBlank                        =        "Please enter Email and password."
    case kTermsCondition                                        =        "Please accept terms and condition before continue"
    case kUserPasswordBlank                                  =        "Please enter password."
    case kUserOldPasswordBlank                            =        "Please enter old password."
    case kUserNewPasswordBlank                          =        "Please enter new password."
    case kUserPasswordSpaceError                         =        "Space Not Allowed in password"
    case kUserCPasswordBlank                               =        "Please enter confirm password."
    case kUserPasswordValidation                           =        "Password must be 8-16 characters."
    case kUserPasswordAlphaNumaricValidation    =        "Password must be contain alphanumeric."
    case kUserPasswordMatchError                         =        "Confirm password doesn't match."
    case kNoInterNet                                                =        "No internet available"
    case kUserEmailBlank                                          =        "Please enter email."
    case kUserEmailValid                                           =        "Please enter valid email."
    case kUserAgreeMentError                                 =        "Please accept terms and conditions."
    case kUserGenderBlank                                       =        "Please select Gender."
    case kUserAddressBlankError                                 =        "Please enter address."
    case kUserCityBlankError                                        =        "Please enter city."
    case kUserStateBlankError                                       =        "Please enter county or state"
    case kUserPostcodeBlankError                                =        "Please enter post code"
    case kUserPostcodeValidError                                =        "Postcode must be less then 8 charaters"
    case kUserPhoneBlankError                                       =        "Please enter phone number."
    case kUserPhoneValidError                                       =        "Phone Number's length should be maximum 11 digits."
    case kUserMobileBlankError                                      =        "Please enter mobile number."
    case kUserMObileValidError                                      =        "Mobile Number's length should be maximum 11 digits."
    case kUserAgeError                                                  =        "Age should be greater then 21."
}

public enum NotificationName: String
{
    case kNotificationProgressBar                                   =       "NotificationProgressBar"
    case kNotificationBackProgressBar                           =   "NotificationBackProgressBar"
    case kNotificationCompleteApplication                   =   "NotificationCompleteEventTag"
    case kNotificationUpdateViewController                  =   "NotificationUpdateViewController"
    
}

class CommonFunction : NSObject
{
    static let sharedInstance = CommonFunction()
    
    class func setLayerForView(vsType : UIView, borderColor bColor : UIColor, boderWidth width : CGFloat, cornerRadius radius : CGFloat){
        vsType.layer.borderColor = bColor.CGColor
        vsType.layer.borderWidth = width
        vsType.layer.cornerRadius = radius
        vsType.layer.masksToBounds = true
    }
    
    
    class  func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func changeDateFormat(changeDate : NSDate, format : String) ->String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format //Set date style
        dateFormatter.timeZone = NSTimeZone()
        let localDate = dateFormatter.stringFromDate(changeDate)
        return localDate
    }
    
    class func getBookingDateformate(changeDate : String) -> String {
        let dt = changeDate
        let dtFrmt = NSDateFormatter()
        dtFrmt.dateFormat = "yyyy-MM-dd"
        let bDate = dtFrmt.dateFromString(dt)
        let bDateComponent = NSCalendar.currentCalendar().components([.Year, .Month,.Day,.Weekday], fromDate: bDate!)
        let arrmonth = dtFrmt.shortMonthSymbols
        let strMoth = arrmonth[bDateComponent.month - 1]
        let bookingDay = "\(bDateComponent.day) \(strMoth), \(bDateComponent.year))"
        return bookingDay
    }
    
    class func getdateFromstring(date : String) -> NSDate {
        let dtFrmt = NSDateFormatter()
        dtFrmt.dateFormat = "yyyy-MM-dd"
        let bDate = dtFrmt.dateFromString(date)
        return bDate!
    }
    
   class  func  getNeededDateFormate(strMainDate : String, presentFrmt : String, wantedFrmt : String) -> String {
        let frmt =  NSDateFormatter()
        frmt.dateFormat = presentFrmt;
        let dt = frmt.dateFromString(strMainDate)
        frmt.dateFormat = wantedFrmt
        let strResult = frmt.stringFromDate(dt!)
        return strResult
    }
    

    
//    class func saveRegisterInfo(info : userReg_1_Response) {
//        let ud = NSUserDefaults.standardUserDefaults()
//        ud.setObject(NSKeyedArchiver.archivedDataWithRootObject(info), forKey: kRegisterUserInfo)
//    }
//    
//    class func removeRegisterInfo() {
//        let ud = NSUserDefaults.standardUserDefaults()
//        ud.removeObjectForKey(kRegisterUserInfo)
//    }
//    
//    class func getRegisterUserInfo() -> userReg_1_Response?
//    {
//        let ud = NSUserDefaults.standardUserDefaults()
//        if let data = ud.objectForKey(kRegisterUserInfo) as? NSData{
//            let info = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! userReg_1_Response
//            return info
//        }
//        else{
//            return nil
//        }
//    }
    
   class func getMaxDateForPicker() -> NSDate{
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        let comps: NSDateComponents = NSDateComponents()
        comps.year = -21
        
        let maxDate : NSDate = calendar.dateByAddingComponents(comps, toDate: NSDate(), options: NSCalendarOptions.MatchStrictly)!
        return maxDate
    }
    
    class func getYearsBetweenTwoDate(startDate: NSDate, lastDate : NSDate) -> Int {
        let cal = NSCalendar.currentCalendar()
        let unit:NSCalendarUnit = .Year
        
        let components = cal.components(unit, fromDate: startDate, toDate: lastDate, options: [])
        print(components.year)
        return components.year
    }
    
    class func getDayBetweenTwoDate(startDate: NSDate, lastDate : NSDate) -> Int {
        let cal = NSCalendar.currentCalendar()
        let unit:NSCalendarUnit = .Day
        
        let components = cal.components(unit, fromDate: startDate, toDate: lastDate, options: [])
        print(components.day)
        return components.day
    }

    class func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
   class func convertStringToDictionary(text: String) -> [String:AnyObject]? {
    if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
    }
    return nil
}
    
   class func downloadImage(path: String){
    let url:NSURL = NSURL(string: path)!;
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    let fileURL = documentsURL.URLByAppendingPathComponent("profile.png")
    if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!){
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        let data = NSData(contentsOfURL: url) //make sure your image in this url does exist, otherwise unwrap in a if let check
        dispatch_async(dispatch_get_main_queue(), {
           
            data?.writeToURL(fileURL, atomically: true)

        });
    }
    }
    
    class func setProfilePic(img:UIImage){
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fileURL = documentsURL.URLByAppendingPathComponent("profile.png")
        let data = UIImagePNGRepresentation(img) //make sure your image in this url does exist, otherwise unwrap in a if let check
        dispatch_async(dispatch_get_main_queue(), {
            
            data?.writeToURL(fileURL, atomically: true)
            
        });

    }
    
    class func getProfileImage()->UIImage?{
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fileURL:NSURL = documentsURL.URLByAppendingPathComponent("profile.png")
        let fileMngr = NSFileManager.defaultManager()
       if fileMngr.fileExistsAtPath(fileURL.path!) {
            let image    = UIImage(contentsOfFile: fileURL.path!)
        return image!
        }
        return nil
           }

    
}


