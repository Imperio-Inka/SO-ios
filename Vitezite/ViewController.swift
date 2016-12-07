//
//  ViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 23/06/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit
import SwiftDDP


class ViewController: RootViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    ///Bhuvan edit today
    
    @IBOutlet weak var layoutTblH: NSLayoutConstraint!
    @IBOutlet weak var tblScl: UITableView!
    @IBOutlet weak var txtSchoolName: ExpandableFontUITextField!
    @IBOutlet weak var imgUser: RoundImage!
    @IBOutlet weak var layoutMargin1: NSLayoutConstraint!
    
    @IBOutlet weak var layoutMargin2: NSLayoutConstraint!
    
    @IBOutlet weak var layoutMargin3: NSLayoutConstraint!
    
    @IBOutlet weak var layoutMargin4: NSLayoutConstraint!
    //
    var arrDropDown : [String]  = ["scu"]
    var selectedSclName : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutMargin1.constant = 50 * heightRatio;
        layoutMargin2.constant = 50 * heightRatio;
        layoutMargin3.constant = 34 * heightRatio;
        layoutMargin4.constant = 36 * heightRatio;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.userDidLogin), name: DDP_USER_DID_LOGIN, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: DDP_USER_DID_LOGOUT, object: nil)
        
        let user  = UserData.sharedInstance.getCurrentUserData()
        if user.name != ""{
            showActivityIndicator("Loading")
        }

    }
    
    @IBAction func actionForDropDown(sender: AnyObject) {
        if layoutTblH.constant == 0.0{
            layoutTblH.constant = CGFloat((40.0 * CGFloat(arrDropDown.count)) * heightRatio)
        }else{
            layoutTblH.constant = 0.0
        }
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    func userDidLogin()  {
        Meteor.call("users.currentUser", params: nil) { result, error in
            self.hideActivityIndicator()
            print(result)
            if (error == nil && result != nil){
                let dict:NSDictionary = result as! NSDictionary;
                
                let serviceDict:NSDictionary = dict.valueForKey("services") as! NSDictionary
                let googleDict:NSDictionary = serviceDict.valueForKey("google") as! NSDictionary
                let path :String = googleDict.valueForKey("picture") as! String
                let user:UserData = UserData()
                user.name = googleDict.valueForKey("name") as! String
                user.email = googleDict.valueForKey("email") as! String
                UserData.sharedInstance.setCurrentUser(user)
                CommonFunction.downloadImage(path)
                
                let vcRear = UIStoryboard.sideMenuController()
                let vcFront = UIStoryboard.calenderListController()
                let ds = DSSideViewController(rearViewController: vcRear!, frontViewController: vcFront!)
                self.navigationController?.pushViewController(ds, animated: true)
                
            }
        }
        if let img:UIImage = CommonFunction.getProfileImage() {
            imgUser.image = img;
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Bhuvan change
    @IBAction func actionForProfileImage(sender: AnyObject) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            alert.addAction(cameraAction)
        }
        
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Image Capturing Methods
    func openCamera(){
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.delegate = self
        self .presentViewController(picker, animated: true, completion: nil)
    }
    
    func openGallary(){
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    //MARK: PickerView Delegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        imgUser.image = CommonFunction.resizeImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!, newWidth: 200.0)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func actionForGoogle(sender: AnyObject) {
        Meteor.loginWithGoogle("22026107675-jfeoijhr5qlpvds0v0dtlvpsv8njsioq.apps.googleusercontent.com", viewController: self)
    }
    
    @IBAction func actionForStartNow(sender: AnyObject) {
        
//        Meteor.logout() { result, error in
//            if error != nil{
//                UserData.sharedInstance.removeCurrentUser()
//            }
//            
//        }
        //users.setSchool
        Meteor.call("users.setSchool", params: ["\(txtSchoolName.text)"]) { (result, error) in
            print(result)
        }
        UserData.sharedInstance.schollName = txtSchoolName.text!;
        let vcRear = UIStoryboard.sideMenuController()
        let vcFront = UIStoryboard.tagsController()
        let ds = DSSideViewController(rearViewController: vcRear!, frontViewController: vcFront!)
        self.navigationController?.pushViewController(ds, animated: true)
        
    }
    /////////////////Finish
    
    //    func handleTap(sender: UITapGestureRecognizer? = nil) {
    //        self.view.endEditing(true)
    //        // handling code
    //    }
    //
    
    //MARK: UITableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDropDown.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DropCell");
        let lbl = cell?.viewWithTag(101) as! UILabel
        lbl.text = arrDropDown[indexPath.row]
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        txtSchoolName.text = arrDropDown[indexPath.row]
        layoutTblH.constant = 0
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40 * heightRatio
    }
    
    
    
}

