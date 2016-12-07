//
//  ContactsViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 02/07/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit
import SwiftAddressBook
import SwiftDDP

protocol UpdateGuestList : class {
    func addGuestUser(arrlsit : [Contacts])
}

class ContactsViewController: RootViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    let collection:MeteorCollection<Contacts> = (UIApplication.sharedApplication().delegate as! AppDelegate).contacts

    @IBOutlet weak var tblContacts: UITableView!
    @IBOutlet weak var layoutBarX: NSLayoutConstraint!
    @IBOutlet weak var searchContactsBar: UISearchBar!
    
    @IBOutlet weak var inviteBar: UIView!
    
    @IBOutlet weak var viteziteBar: UIView!
    
    var isInvite:Bool = false
    var arrInviteList:[Contacts] = []
    var arrGuestList:[Contacts] = []
    var arrFinalList:[Contacts] = []
    var arrSelectedGuestUser : [Contacts] = []
    weak var  delegate : UpdateGuestList?
    override func viewDidLoad() {
        super.viewDidLoad()
        callGuestList()
       
               // Do any additional setup after loading the view.
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionForBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func actionForDone(sender: AnyObject) {
        delegate?.addGuestUser(arrSelectedGuestUser)
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func actionForOption(sender: AnyObject) {
        let btn = sender as! UIButton
        if btn.tag == 111{
            //vitezite enable
            inviteBar.hidden = true;
            viteziteBar.hidden = false;
            isInvite = false;
            callGuestList()
        }else{
            inviteBar.hidden = false;
            viteziteBar.hidden = true;
            isInvite = true;
            callInviteList()
        }
        
    }
    
    func callInviteList()  {
        SwiftAddressBook.requestAccessWithCompletion({ (success, error) -> Void in
            if success {
                self.arrGuestList.removeAll()
                 let addressBook : SwiftAddressBook! = swiftAddressBook
                if let people = addressBook?.allPeople {
                    for person in people {
                        //print("%@", person.phoneNumbers?.map( {$0.value} ))
                        let guest = GuestListModal()
                        let dict:NSMutableDictionary = NSMutableDictionary()
                        guest.name = ""
                        if let fName = person.firstName{
                            guest.name = fName
                            
                        }
                        if let lName = person.lastName{
                            guest.name = guest.name+lName
                        }
                        dict.setValue(guest.name, forKey: "title")
                        
                        var arrPersonval:[String] = []
                        
                        if((person.emails) != nil){
                            arrPersonval  =
                                (person.emails?.map({$0.value}))!
                        }
                        
                        if  arrPersonval.count>0{
                            guest.email = arrPersonval[0]
                            dict.setValue(guest.email, forKey: "email")
                        }
                     //   let arrPhone:Array<MultivalueEntry<String>> = person.phoneNumbers!
                        if let  arrPhone:Array<MultivalueEntry<String>> = person.phoneNumbers{
                            if !arrPhone.isEmpty
                            {
                                arrPersonval = (person.phoneNumbers?.map({$0.value}))!
                                guest.phone = arrPersonval[0]
                                dict.setValue(guest.phone, forKey: "phone")
                            }
                            
                        }
                        
                        
//                        if !arrPhone.isEmpty
//                        {
//                            arrPersonval = (person.phoneNumbers?.map({$0.value}))!
//                            guest.phone = arrPersonval[0]
//                        }
                      
                        if(person.hasImageData()){
                            guest.imageData = person.image;
                            dict.setValue(guest.imageData, forKey: "imageData")
                        }
                        let c = Contacts(id: "0", fields: dict)
                        if (c.title != "") {
                        self.arrGuestList.append(c)
                        }
                    }
                    self.arrGuestList.sortInPlace({
                        
                        $0.title?.compare($1.title!) ==  NSComparisonResult.OrderedAscending
//                        dateFormat.dateFromString($0)!.compare(dateFormat.dateFromString($1)!) == NSComparisonResult.OrderedAscending
                    })
                   // self.arrGuestList = self.arrGuestList.sort(){ $0 < $1 }
                    self.arrFinalList = self.arrGuestList
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.tblContacts.reloadData();
                    })
                    
                }
            }
            else {
                //no success. Optionally evaluate error
            }
        })

    }
    
    func callGuestList(){
        self.arrFinalList = self.arrInviteList;
         self.tblContacts.reloadData();
        
        Meteor.call("contacts.retrieve", params: nil) { (result, error) in
            if ((error ) == nil) {
                self.showActivityIndicator("")
                
                Meteor.subscribe("contacts.owner") {
                    self.hideActivityIndicator()
                    //self.hideActivityIndicator()
                    if let _:[Contacts] = self.collection.sorted  {
                        self.arrInviteList.removeAll()
                        print(self.collection.sorted)
                        for (_,calList) in self.collection.sorted.enumerate(){
                            let contact:Contacts = calList;
                            print(contact);
                            self.arrInviteList.append(contact)
                            // self.arrEvents.append(event);
                        }
                        self.arrFinalList = self.arrInviteList;
                        self.tblContacts.reloadData();
                    }
                    
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactsCell") as! GuestListCell
        let guestModal = arrFinalList[indexPath.row]
        cell.accessoryType = .None
        cell.guestEmailLabel.text = guestModal.email
        cell.guestNameLabel.text = guestModal.title
        cell.lblContacts.text = guestModal.phone
        if isInvite{
             cell.guestImageView.image = guestModal.imageData
        }else{
            cell.guestImageView.imageFromUrl(guestModal.photo!)
        }
        for contact1:Contacts in arrSelectedGuestUser {
            if contact1.title == arrFinalList[indexPath.row].title{
                cell.accessoryType = .Checkmark
                break;
            }
        }
        
       
        CommonFunction.setLayerForView(cell.guestImageView, borderColor: UIColor.clearColor(), boderWidth: 0.0, cornerRadius: cell.guestImageView.frame.size.width/2)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFinalList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        var isFound:Bool = false;
        var index:NSInteger = 0;
        for contact1:Contacts in arrSelectedGuestUser {
            if contact1.title == arrFinalList[indexPath.row].title{
                isFound = true;
                arrSelectedGuestUser.removeAtIndex(index)
                cell!.accessoryType = .None
                break
            }
            index += 1
        }
        if !isFound{
            arrSelectedGuestUser.append(arrFinalList[indexPath.row])
            cell!.accessoryType = .Checkmark
        }
//        if arrSelectedGuestUser.contains(arrFinalList[indexPath.row]){
//            arrSelectedGuestUser.removeAtIndex(arrSelectedGuestUser.indexOf(arrFinalList[indexPath.row])!)
//            cell!.accessoryType = .None
//        }else{
//            arrSelectedGuestUser.append(arrFinalList[indexPath.row])
//            cell!.accessoryType = .Checkmark
//        }
        
    }
    
    // delegate 
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        filterContentForSearchText(searchBar.text!)
    }
    
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    

    func filterContentForSearchText(searchText: String) {
        if isInvite {
            if searchText.characters.count != 0{
                print(arrFinalList)
                arrFinalList = arrGuestList.filter { lst in
                    return lst.title!.lowercaseString.containsString(searchText.lowercaseString)
                }
                print(arrFinalList)
            }else{
                arrFinalList = arrGuestList
            }
           
        }
        else{
            if searchText.characters.count != 0{
                arrFinalList = arrInviteList.filter { lst in
                    return lst.title!.lowercaseString.containsString(searchText.lowercaseString)
                }
            }else{
                arrFinalList = arrInviteList
            }
        
    }
    tblContacts.reloadData()
}
}
