//
//  ProfileViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 08/07/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit
import SwiftDDP

class ProfileViewController: RootViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{

    @IBOutlet weak var lblUserName: ExpandableFontLabel!
    @IBOutlet weak var imgUser: RoundImage!
    @IBOutlet weak var txtSchoolName: ExpandableFontUITextField!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var layoutMargin1: NSLayoutConstraint!
    
    @IBOutlet weak var layoutMargin2: NSLayoutConstraint!
    
    @IBOutlet weak var layoutMargin3: NSLayoutConstraint!
    
    
    @IBOutlet weak var hView: UIView!
    @IBOutlet weak var layoutTblH: NSLayoutConstraint!
     @IBOutlet weak var tblScl: UITableView!
    
       var arrDropDown : [String]  = ["Santa Clara University"]
    var selectedSclName : String = "Santa Clara University"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //layoutMargin1.constant = 50 * heightRatio;
       // layoutMargin2.constant = 50 * heightRatio;
        //layoutMargin3.constant = 34 * heightRatio;
       // layoutMargin4.constant = 36 * heightRatio;
        
        headerView = getHeaderInstance()
        headerView.lblHeader.text = "Profile"
        hView.updateConstraints()
        hView.layoutIfNeeded()
        hView.addSubview(headerView)
        
         headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.checkSideMenuOpen(_:)), name: "SideMenuChange", object: nil)
//        headerView.btnSide.addTarget(self, action: #selector(ProfileViewController.actionGoBack), forControlEvents: .TouchUpInside)
//        headerView.imgSide.image = UIImage(named: "back_arrow")

        
        lblUserName.text = UserData.sharedInstance.name;
        txtSchoolName.text = UserData.sharedInstance.schollName;
        txtSchoolName.enabled = false
        
        if let img:UIImage = CommonFunction.getProfileImage() {
            imgUser.image = img;
        }
      
        // Do any additional setup after loading the view.
    }
    
    
    
    func checkSideMenuOpen(notificaiton : NSNotification) {
        
        print("side value to check : \(self.DSViewController()?._frontViewPosition)")
        if self.DSViewController()?._frontViewPosition == 4 || self.DSViewController()?._frontViewPosition == 5{
            if topView != nil{
                topView.removeFromSuperview()
            }
            
        }else{
            if self.DSViewController()?._rearViewPosition == 3{
                addviewOnTop(self)
            }
        }
        
    }
    
    func  actionGoBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       addSideNavigationGesture()
        
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
       removeSildeNavigationGesture()
        
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
        let image:UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        imgUser.image = CommonFunction.resizeImage(image, newWidth: 200.0)
        CommonFunction.setProfilePic(CommonFunction.resizeImage(image, newWidth: image.size.width))
    
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
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
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateProfileAction(sender: AnyObject) {
        
        if txtSchoolName.text?.characters.count == 0{
            showNormalAlert(kProjectName, msg: "Please select school name")
            return
        }
        UserData.sharedInstance.schollName = txtSchoolName.text!
        Meteor.call("users.setSchool", params: [UserData.sharedInstance.schollName]) { (result, error) in
             if ((error ) == nil) {
            UserData.sharedInstance.schollName = self.txtSchoolName.text!
                self.showNormalAlert(kProjectName, msg: "Profile update successfully")
            }
            print(result)
        }
       

    }


}
