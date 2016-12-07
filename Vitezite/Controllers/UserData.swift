//
//  UserData.swift
//  Vitezite
//
//  Created by Padam on 6/30/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import Foundation

class UserData:NSObject{
    var name:String = ""
    var email:String = ""
    var location:String = ""
    var schollName:String = "";
    var usercalenderList:[CalendarListModel] = []
    var isRepeated:Bool = false;
    
    static let sharedInstance = UserData()
    
     func getCurrentUserData()-> UserData{
        let user :UserData = UserData.sharedInstance
        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (userDefault.boolForKey(ISREPEATED)) {
             user.name = userDefault.valueForKey(USERNAME) as! String;
            user.location = userDefault.valueForKey(USERLOCATION) as! String;
            user.email = userDefault.valueForKey(USEREMAIL) as! String;
            user.isRepeated = userDefault.boolForKey(ISREPEATED)
        }
        
        return user;
    }
    
     func setCurrentUser(user:UserData){
        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(user.name, forKey: USERNAME)
         userDefault.setValue(user.email, forKey: USEREMAIL)
         userDefault.setValue(user.location, forKey: USERLOCATION)
         userDefault.setBool(user.isRepeated, forKey: ISREPEATED)
    }
    
    func removeCurrentUser() {
        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefault.removeObjectForKey(USERNAME)
        userDefault.removeObjectForKey(USEREMAIL)
        userDefault.removeObjectForKey(USERLOCATION)
        userDefault.removeObjectForKey(ISREPEATED)

    }
}