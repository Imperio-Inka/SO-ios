//
//  ValidationClass.swift
//  ValidationInSwift
//
//  Created by akshuma on 04/11/15.
//  Copyright © 2015 New Admin. All rights reserved.
//

import UIKit
import AVFoundation

class Validation: NSObject{
    class func emailValidation(txtFieledEmail: String)-> Bool{
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(txtFieledEmail)
    }
    
    class func phoneNoValidation(txtFieldPhone:String)-> Bool{
        //let phoneNumber = "(800) 555-1111"
        let PhoneNo = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneNoTest = NSPredicate(format:"SELF MATCHES %@", PhoneNo)
        return phoneNoTest.evaluateWithObject(txtFieldPhone);
    }
    
    class func stringDoesNotExceed(pNumber : String,length : String )-> Bool{
        if pNumber.characters.count > (length as NSString).integerValue{
            return true
        }
        return false
    }
    
    class func specialCharacterNotEnter(txtField:String)->Bool{
        let characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = txtField.componentsSeparatedByCharactersInSet(characterSet)
        filtered = inputString.componentsJoinedByString("")
        return txtField == filtered;
        
    }
 
    class func PasswordAndConfirmPasswordMatch(txtfieldone:String ,secondValue txtfieldTwo:String)->Bool{
        if txtfieldone != txtfieldTwo{
            return true;
        }
        return false;
    }
    
    class func emptyTextFeild(txtfieldone:String )->Bool {
        return txtfieldone.isEmpty
    }
    
    class func postCodeValidation(txtfieldone:String )->Bool {
        if txtfieldone.characters.count > 8{
            return true
        }
        return false
    }
    
    func checkSpaceInPassword(txtField: String) -> Bool{
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        let range = txtField.rangeOfCharacterFromSet(whitespace)
        // range will be nil if no whitespace is found
        if let test = range {
           return true
        }
        return false
    }
    
    
    func   validationContaingSpecialCharacterDigitCharacher(txtField: String) ->Bool{
        // let Validl = "^[\w\s*\W]{8}$"
        let ValidlRegEx = "^[[a-z]\\d\\s@!#$%^&*_|-]{6}$"
        let Test = NSPredicate(format:"SELF MATCHES %@", ValidlRegEx)
        return Test.evaluateWithObject(txtField)
    }
    
    
    func validateStringDigit(txtField: String, length : String) ->Bool
    {
        return txtField.characters.count == (length as NSString).integerValue ? true : false
    }
    
    func validationWhiteSpace(txtField: String)->Bool{
        let characterSet:NSCharacterSet = NSCharacterSet .whitespaceAndNewlineCharacterSet()
        let filtered:NSString = txtField .stringByTrimmingCharactersInSet(characterSet)
        return txtField == filtered;
        
    }
}
