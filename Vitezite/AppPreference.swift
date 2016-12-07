//
//  AppPrefrences.swift
//  Vitezite
//
//  Created by Padam on 6/24/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import Foundation

let SECRETKEY = "secret_key"
let USERPREFERENCE = "userPreference"
let TOKENKEY = "token_key"
let PROFILEIMAGE = "profile_image"
let USERNAME   = "USER_NAME"
let USEREMAIL = "EMAIL"
let USERLOCATION = "location"
let ISREPEATED = "repeated"
let USERID    =     "_id"
let SCHOLLNAME = "scholl_name"
let PHONENOKEY = "phone_no"

public class  AppPreference: NSObject {
    public static let sharedInstance = AppPreference()
    var  pref = NSUserDefaults.standardUserDefaults();
    //set get functin for SECRET KEY
    func setSecretKey(value:String){
        pref.setValue(value, forKey: SECRETKEY)
    }
    
    func setUserPreferencePopup(isShow : Bool)  {
        pref.setBool(isShow, forKey: USERPREFERENCE)
    }
    
    func getUserPreferencePopupStatus() -> Bool? {
        if (pref.valueForKey(USERPREFERENCE) == nil) {
            return false;
        }
        return pref.boolForKey(USERPREFERENCE)
    }
    
    func getSecretKey() -> String? {
        if (pref.valueForKey(SECRETKEY) == nil) {
            return nil;
        }
        return pref.stringForKey(SECRETKEY)!
    }
    
    func setTokenKey(value:String){
        pref.setValue(value, forKey: TOKENKEY)
    }
    
    func getTokenKey() -> String? {
        if (pref.valueForKey(TOKENKEY) == nil) {
            return nil;
        }
        return pref.valueForKey(TOKENKEY)! as? String
    }

}