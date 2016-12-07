//
//  CreateEventViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 29/06/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit
import SwiftDDP
import DigitsKit



class CreateEventViewController: RootViewController,UITextViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UpdateGuestList,UpdateLocationDelegate,UpdateTagsDelegate {
    
    @IBOutlet weak var btnEndTime: UIButton!
    @IBOutlet weak var btnStartTime: UIButton!
    @IBOutlet weak var vwUser: UIView!
    @IBOutlet weak var lblUserName: ExpandableFontLabel!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var txtEndTime: UITextField!
    
    @IBOutlet weak var txtStartTime: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var lblDesriptionHeader: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtEventTags: UITextField!
    @IBOutlet weak var txtEvevtTitle: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var btnTogglePublic: UIButton!
    @IBOutlet weak var btnToggleInvite: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    
    @IBOutlet weak var btnBigPublic: UIButton!
   
    @IBOutlet weak var btnBigInviteOther: UIButton!
    
    @IBOutlet weak var layoutScrollW: NSLayoutConstraint!
    @IBOutlet weak var layoutHiddenInfoH: NSLayoutConstraint!
    @IBOutlet weak var lblSchoolName: UILabel!
    @IBOutlet weak var imgUser: RoundImage!
    
    
    var isDetail : Bool = false
    var isEdit : Bool = false
    var isPublic : Bool = false
    var isInviteAllow : Bool = false
    var startTme : String?
    var startDate : String?
    var endTme : String?
    var endDate : String?
    
    var objTextField : UITextField!
    var datePicker : UIDatePicker!
    var event:Event!;
    var verifyPopup:PhoneVerficationPopup!
    var arrEventTags : [String] = []
    
    var arrSeletedContacts : [Contacts] = []
   
    @IBOutlet weak var vwUserHiddenInfo: UIView!
    @IBOutlet weak var scrl: UIScrollView!
    @IBOutlet weak var scrlContentview: UIView!
    
    @IBOutlet weak var imgEvent: UIImageView!
    @IBOutlet weak var hView: UIView!
    
    @IBOutlet weak var btnTags: UIButton!
    
    @IBOutlet weak var btnImgEdit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        btnLocation.hidden = false
        txtEndTime.inputView = datePicker
        txtStartTime.inputView = datePicker
        txtEndDate.inputView = datePicker
        txtStartDate.inputView = datePicker
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateEventViewController.handleTap))
        self.view.addGestureRecognizer(tap)
        
        //txtEndDate.addDoneOnKeyboardWithTarget(self, action:#selector(validateDate(_:)))
        //txtStartDate.addDoneOnKeyboardWithTarget(self, action:#selector(validateDate(_:)))
        txtEvevtTitle.addDoneOnKeyboardWithTarget(self, action:#selector(titleNext(_:)))
        datePicker.addTarget(self, action: #selector(CreateEventViewController.handleDatePicker(_:)), forControlEvents: .ValueChanged)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateEventViewController.checkSideMenuOpen(_:)), name: "SideMenuChange", object: nil)
        
        let swipeButtonDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CreateEventViewController.actionForToggelPublic(_:)))
        btnTogglePublic.addGestureRecognizer(swipeButtonDown)

        
        /// creating header
        headerView = getHeaderInstance()
        headerView.lblHeader.text = "Create Event"
        hView.updateConstraints()
        hView.layoutIfNeeded()
        hView.addSubview(headerView)
        
        //self.view.addGestureRecognizer(self.DSViewController()!.panGestureRecognizer())
        // Do any additional setup after loading the view.
        
        if isDetail || isEdit{
            
            headerView.btnSide.addTarget(self, action: #selector(CreateEventViewController.actionGoBack), forControlEvents: .TouchUpInside)
            headerView.imgSide.image = UIImage(named: "back_arrow")
            lblDesriptionHeader.hidden = true
            
            self.showActivityIndicator("Loading")
            Meteor.call("attendees.get", params:[event.id!]) { (result, error) in
                self.hideActivityIndicator()
                if (error == nil && result != nil){
                    let arr:[AnyObject] = result as! [AnyObject]
                    for dict in arr{
                        
                        let contactDict:NSMutableDictionary = NSMutableDictionary()
                        contactDict.setValue(dict.valueForKey("email"), forKey:"email" )
                        contactDict.setValue(dict.valueForKey("displayName"), forKey:"title" )
//                        contactDict.setValue("title", forKey: dict["displayName"])
                       let c = Contacts(id: "0", fields: contactDict)
                        self.arrSeletedContacts.append(c)
                        
                    }
                    self.addGuestUser(self.arrSeletedContacts)
                }
            }
            
            
            if (event != nil) {
                
                txtEvevtTitle.text = event.summary
                var tag:String = ""
                if event.tags != nil {
                    arrEventTags = event.tags!
                for a in event.tags! {
                    tag = tag+a+","
                }
                 tag = tag.substringToIndex(tag.endIndex.predecessor())
                }
                txtEventTags.text = tag
                txtDescription.text = event.description1;
                txtLocation.text = event.location;
                if (event.start != nil) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEE-MMM,dd yyyy"
                    txtStartDate.text = dateFormatter.stringFromDate(event.start!);
                    dateFormatter.dateFormat = "hh:mm a"
                    txtStartTime.text = dateFormatter.stringFromDate(event.start!);
                }
                if (event.end != nil) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEE-MMM,dd yyyy"
                    txtEndDate.text = dateFormatter.stringFromDate(event.end!);
                    dateFormatter.dateFormat = "hh:mm a"
                    txtEndTime.text = dateFormatter.stringFromDate(event.end!);
                }
                if (event.visibility != nil && event.visibility == "public"){
                    isPublic = !isPublic
                    btnTogglePublic.setImage(isPublic ? UIImage(named: "togle_big_on") : UIImage(named: "togle_big_off") , forState: .Normal)
                }
            }
            if isDetail{
                lblDesriptionHeader.hidden = true
                lblUserName.text = event.calendarId;
                lblSchoolName.text = event.school;
                headerView.lblHeader.text = "Event Details"
                self.setEventdetail()
            }
            else{
                headerView.lblHeader.text = "Edit Event"
                btnCreate.setTitle("Update", forState: UIControlState.Normal)
            }
        }else{
            
            let dateFormater = NSDateFormatter()
            dateFormater.dateFormat = "EEE-MMM,dd yyyy"
            txtStartDate.text = dateFormater.stringFromDate(NSDate())
            txtEndDate.text = dateFormater.stringFromDate(NSDate())
            dateFormater.dateFormat = "hh:mm a"
            txtStartTime.text = dateFormater.stringFromDate(NSDate())
            txtEndTime.text = dateFormater.stringFromDate(NSDate())
            vwUser.hidden = true
            vwUserHiddenInfo.hidden = true
            //  btnLocation.hidden = true
            headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        layoutScrollW.constant = 50
        
        //get currentLocation
        (UIApplication.sharedApplication().delegate as! AppDelegate).findMyLocation()
        
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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addSideNavigationGesture()
        
    }
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        removeSildeNavigationGesture()
        if verifyPopup != nil {
            verifyPopup.removeFromSuperview()
        }
        
        
    }
    
    
    @IBAction func openTagListPage(sender: AnyObject) {
        let vc = UIStoryboard.tagsController()
        vc?.isfromCreateEventScreen = true
        vc?.arrSelectedTags = arrEventTags
        vc?.delegate = self
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func actionForOpenProfile(sender: AnyObject) {
        if layoutHiddenInfoH.constant == 0.0{
            layoutHiddenInfoH.constant = 200.0
        }else{
            layoutHiddenInfoH.constant = 0.0
        }
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func actionForLocationMap(sender: AnyObject) {
        
        
        if isDetail{
            let query = "?address=\(txtLocation)"
            let path = "http://maps.apple.com/" + query
            
            if let url = NSURL(string: path) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                //UIApplication.sharedApplication().openURL(url)
                // Could not construct url. Handle error.
            }
        }else{
            let vc = UIStoryboard.locationController()
            vc?.delegete =  self
            let navigation:UINavigationController = UIStoryboard.getLocationNavigationController()!
            navigation.setViewControllers([vc!], animated: true)
            self.navigationController?.presentViewController(navigation, animated: true, completion: {
                
            })
            
        }
    }
    //Delegate methods
    
    func setTagsFromTagList(selectedTags : [String]) {
        arrEventTags = selectedTags
        if  selectedTags.count == 0{
        return
        }
        var strTg :  String = ""
        for itm in selectedTags {
            strTg = strTg == "" ? itm : "\(strTg), \(itm)"
        }
        txtEventTags.text = strTg
    }
    
    
    func setAddressfromMap(location: String) {
        txtLocation.text = location
    }
    
    func addGuestUser(arrlsit: [Contacts]) {
        
        arrSeletedContacts = arrlsit
        for itm in scrlContentview.subviews {
            if itm == btnAdd {
                continue;
            }
            itm.removeFromSuperview()
        }
        layoutScrollW.constant = 60;
        for i in 0..<arrlsit.count {
            let img = UIImageView(frame: CGRectMake(layoutScrollW.constant-50,2, 40, 40))
            scrlContentview.addSubview(img)
            let lbl = UILabel(frame: CGRectMake(layoutScrollW.constant-50,42, 44, 15))
            lbl.text = arrlsit[i].title
            //lbl.font = lbl.font.fontWithSize(8)
            lbl.textAlignment = NSTextAlignment.Center
            lbl.adjustsFontSizeToFitWidth = true
            
            //lbl.minimumScaleFactor = 0.2;
            //lbl.sizeToFit();
            scrlContentview.addSubview(lbl)

            //img.backgroundColor = UIColor.redColor()
            
            layoutScrollW.constant = layoutScrollW.constant+45;
              // img.addConstraint(H)
            // img.addConstraint(W)
            
            CommonFunction.setLayerForView(img, borderColor: UIColor.grayColor(), boderWidth: 1.0, cornerRadius: 20)
            img.translatesAutoresizingMaskIntoConstraints = false
            if arrlsit[i].imageData != nil{
                img.image = arrlsit[i].imageData
            }else if arrlsit[i].photo != nil{
                img.imageFromUrl(arrlsit[i].photo!)
            }
            
        }
        
    }
    
    @IBAction func createEventAction(sender: AnyObject) {
        
        if txtEvevtTitle.text?.characters.count == 0{
            showNormalAlert(kProjectName, msg: "Please enter event Title")
            return
        }
        
        if txtDescription.text.characters.count == 0{
            showNormalAlert(kProjectName, msg: "Please enter event description")
            return
        }
        
        if txtStartDate.text!.characters.count == 0{
            showNormalAlert(kProjectName, msg: "Please choose event start date")
            return
        }
        
        if txtStartTime.text!.characters.count == 0{
            showNormalAlert(kProjectName, msg: "Please choose event start time")
            return
        }
        
        if txtEndDate.text!.characters.count == 0{
            showNormalAlert(kProjectName, msg: "Please choose event end date")
            return
        }
        
        if txtEndTime.text!.characters.count == 0{
            showNormalAlert(kProjectName, msg: "Please choose event end time")
            return
        }
        if !isValidateDate() {
            return;
        }
        
        
        let tagsArr:[String] = txtEventTags.text!.componentsSeparatedByString(",")
        let location = txtLocation.text
        var  visiblity = "private"
        if isPublic{
            visiblity = "public"
        }
        
        
        //
        //        trimmedjsonString = trimmedjsonString.stringByReplacingOccurrencesOfString("\n",
        //                                                                                   withString: "", options: .RegularExpressionSearch)
        let jsonObject: [String: AnyObject] = [
            "summary": txtEvevtTitle.text!,
            "description": txtDescription.text!,
            "start": [
                "dateTime": self.getRightFormatOfDate(txtStartDate.text!, ob2: txtStartTime.text!).stringFormattedAsRFC3339
            ],
            "end": [
                "dateTime": self.getRightFormatOfDate(txtEndDate.text!, ob2: txtEndTime.text!).stringFormattedAsRFC3339
            ],
            "location": location!,
            "visibility": visiblity
            
        ]
        let calendarId = UserData.sharedInstance.email;
       
        
        
              if isEdit {
                 self.showActivityIndicator("Loading")
            Meteor.call("events.update", params:[event.id!,jsonObject] ) { (result, error) in
                self.hideActivityIndicator()
                if ((error ) == nil) {
                    print(result)
                    
//                    let vc = UIStoryboard.homeController()
//                    self.DSViewController()?.setFrontViewController(vc!);
                    self.navigationController?.popViewControllerAnimated(true)
                     NSNotificationCenter.defaultCenter().postNotificationName("EventListUpdate", object: nil)
                    
                    self.callApiAfterEvent(tagsArr, id: self.event.id!)

                    
                }
            }

        }
        
        else {
                
               
                
                let block = { ()->() in
                        self.showActivityIndicator("Loading")
                        Meteor.call("events.insert", params:[calendarId,jsonObject] ) { (result, error) in
                            self.hideActivityIndicator()
                            if ((error ) == nil) {
                                print(result)
                                let dict =  result as! NSDictionary;
                                let id = dict.valueForKey("id") as! String;
                                self.showActivityIndicator("Loading")
                                let vc = UIStoryboard.homeController()
                                self.DSViewController()?.setFrontViewController(vc!);
                                self.callApiAfterEvent(tagsArr, id: id)
                                //                            self.navigationController?.pushViewController(vc!, animated: true)
                                
                            }
                        }}
                    
                
                authenticateNumber(block)
        }
        

        
    }
    
    func isValidateDate()->Bool{
        
        
        let dateFormater = NSDateFormatter()
        
        dateFormater.dateFormat = "EEE-MMM,dd yyyy"
        
        let dt = txtStartDate.text!.getDatefromStringWithFormat("EEE-MMM,dd yyyy")
        let dt1 = txtEndDate.text!.getDatefromStringWithFormat("EEE-MMM,dd yyyy")
        
        if dt.isGreaterThanDate(dt1){
            showNormalAlert(kProjectName, msg: "Please choose end date greater from start date.")
            return false
        }
        else if dt.isEqualToDate(dt1){
            let t = txtStartTime.text!.getDatefromStringWithFormat("hh:mm a")
            let t1 = txtEndTime.text!.getDatefromStringWithFormat("hh:mm a")
            
            if(t.isGreaterThanDate(t1)){
                showNormalAlert(kProjectName, msg: "Please choose end date greater from start date.")
                return false
            }
        }
        return true;
    }

    
    func callApiAfterEvent(tagsArr:[String],id:String){
        if tagsArr.count > 0{
            Meteor.call("events.setTags", params:[id,tagsArr] ) { (result, error) in
                self.hideActivityIndicator()
                if ((error ) == nil) {
                    NSNotificationCenter.defaultCenter().postNotificationName("EventListUpdate", object: nil)
                }
            }
        }
        
        if arrSeletedContacts.count>0{
            Meteor.call("attendees.add", params:[id,self.changeContactToJson()] ) { (result, error) in
                if ((error ) == nil) {
                    NSNotificationCenter.defaultCenter().postNotificationName("EventListUpdate", object: nil)
                }
            }
        }
        
    }



    func getRightFormatOfDate(ob1 : String,ob2 : String) -> NSDate {
        let str = "\(ob1) \(ob2)"
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "EEE-MMM,dd yyyy hh:mm a"
        let date = dateFormater.dateFromString(str)
        if(date == nil){
            
        }
        return date!
    }
    
    
    
    
    func  actionGoBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setEventdetail() {
      
        btnEndTime.hidden  = true
        btnStartTime.hidden  = true
        btnImgEdit.hidden  = true
        vwUser.hidden = false
        vwUserHiddenInfo.hidden = false
        btnTags.enabled = false
        btnTags.hidden = true
        txtStartDate.enabled = false
        txtEndDate.enabled = false
        txtStartTime.enabled = false
        txtEndTime.enabled = false
        txtDescription.userInteractionEnabled = false
        txtLocation.enabled = false
        txtEventTags.enabled = false
        txtEvevtTitle.enabled = false
        btnAdd.hidden = true
        btnCreate.hidden = true
        btnToggleInvite.enabled = false
        btnTogglePublic.enabled = false
        btnBigPublic.enabled = false
        btnBigInviteOther.enabled = false
        
    }
    
    
    func handleDatePicker(sender : AnyObject)  {
        
        //YYYY-MM-DDTHH:mm:ssZ
        let dateFormater = NSDateFormatter()
        let resltDate = sender as! UIDatePicker
        
        dateFormater.dateFormat = "EEE-MMM,dd yyyy"
        
        if objTextField == txtStartDate{
            objTextField.text = dateFormater.stringFromDate(resltDate.date)
            
            dateFormater.dateFormat = "hh:mm a"
            
            txtStartTime.text = dateFormater.stringFromDate(resltDate.date)
        }else if objTextField == txtEndDate{

            objTextField.text = dateFormater.stringFromDate(resltDate.date)

            
            dateFormater.dateFormat = "hh:mm a"
            txtEndTime.text = dateFormater.stringFromDate(resltDate.date)
        }
        
    }
    
    func validateDate(sender: UIButton!){
        
      
        let dateFormater = NSDateFormatter()
        
        dateFormater.dateFormat = "EEE-MMM,dd yyyy"
        
            let dt = txtStartDate.text!.getDatefromStringWithFormat("EEE-MMM,dd yyyy")
            let dt1 = txtEndDate.text!.getDatefromStringWithFormat("EEE-MMM,dd yyyy")
            
            if dt.isGreaterThanDate(dt1){
                showNormalAlert(kProjectName, msg: "Please choose end date greater from start date.")
                datePicker.becomeFirstResponder();
                return
            }
        else if dt.isEqualToDate(dt1){
                let t = txtStartTime.text!.getDatefromStringWithFormat("hh:mm a")
                let t1 = txtEndTime.text!.getDatefromStringWithFormat("hh:mm a")
                
                if(t.isGreaterThanDate(t1)){
                    showNormalAlert(kProjectName, msg: "Please choose end date greater from start date.")
                    datePicker.becomeFirstResponder();
                    return
                }
    }
      self.view.endEditing(true)
    }
    
    func titleNext(sender: UIButton!){
        txtDescription.becomeFirstResponder()
    }

    //MARK: Action methods
    @IBAction func actionForAddGuest(sender: AnyObject) {
        func block1(){
//            let vc = UIStoryboard.contactscontroller()
//            vc?.delegate = self
//            self.navigationController?.pushViewController(vc!, animated: true)
        }
        let block = { ()->() in
            
            let vc = UIStoryboard.contactscontroller()
            vc?.delegate = self
            vc?.arrSelectedGuestUser = self.arrSeletedContacts
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
        authenticateNumber(block)
    }
    
    func authenticateNumber(block:()->()){
        if UserData.sharedInstance.phoneNo != "" {
            block()
            return;
        }
        
        let arrViews = NSBundle.mainBundle().loadNibNamed("PhoneVerficationView", owner: nil, options: nil)
        for vs in arrViews
        {
            if vs.isKindOfClass(PhoneVerficationPopup){
                verifyPopup = vs as! PhoneVerficationPopup
                break
            }
        }
        verifyPopup.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        verifyPopup.updateConstraints()
        verifyPopup.verifyPhoneView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width-40, UIScreen.mainScreen().bounds.size.height)
        verifyPopup.verifyPhoneView.updateConstraints()

        
        let authButton = DGTAuthenticateButton(authenticationCompletion: { (session: DGTSession?, error: NSError?) in
            if (session != nil) {
                // TODO: associate the session userID with your user model
                let message = "Phone number: \(session!.phoneNumber)"
                UserData.sharedInstance.phoneNo  = session!.phoneNumber
                Meteor.call("users.setPhoneNumber", params:[session!.phoneNumber] ) { (result, error) in
                    if error == nil{
                        }
                }
                NSLog(message )
                block()
            } else {
                NSLog("Authentication error: %@", error!.localizedDescription)
                self.showNormalAlert(kProjectName, msg: "Authentication error:")
            }
        })
       // authButton.sendActionsForControlEvents(.TouchUpInside)
       // authButton.center = verifyPopup.verifyPhoneView.center
        //authButton.frame = verifyPopup.verifyPhoneView.frame
        authButton.frame = CGRectMake(0, 0, authButton.frame.size.width, authButton.frame.size.height)
        // authButton.center = verifyPopup.verifyPhoneView.center
        verifyPopup.verifyPhoneView.addSubview(authButton)
        authButton.backgroundColor = UIColor.clearColor()
        let KeyWindow = (UIApplication.sharedApplication().delegate as! AppDelegate).window
        
          KeyWindow!.addSubview(self.verifyPopup)
            
       
        
        
    }
    
    @IBAction func actionForCreateEvent(sender: AnyObject) {
    }
    
    //MARK: UItextfield delegate methods
    
    func textViewDidChange(textView: UITextView) {
        if textView == txtDescription{
            if txtDescription.text.characters.count == 0{
                lblDesriptionHeader.hidden = false
                
            }else{
                lblDesriptionHeader.hidden = true
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == txtStartDate || textField == txtEndDate{
            if textField == txtStartDate{
                objTextField = txtStartDate;
            }
            else {
                if txtStartDate.text == "" || txtStartTime.text == ""{
                    txtEndDate.resignFirstResponder()
                }else{
                    txtEndDate.userInteractionEnabled  = true
                    objTextField = txtEndDate;
                }
                
            }
            datePicker.datePickerMode = .DateAndTime
            
        }else if textField == txtStartTime || textField ==  txtEndTime{
            txtEndTime.resignFirstResponder()
            txtStartTime.resignFirstResponder()
            //            if textField == txtStartTime{
            //                objTextField = txtStartTime;
            //            }
            //            else {
            //                if txtStartDate.text == "" || txtStartTime.text == ""{
            //                    txtEndTime.resignFirstResponder()
            //                }else{
            //                    txtEndTime.userInteractionEnabled  = true
            //                    objTextField = txtEndTime;
            //                }
            //            }
            //            datePicker.datePickerMode = .Time
        }
    }
    
    
    @IBAction func actionForToggelPublic(sender: AnyObject) {
        isPublic = !isPublic
        btnTogglePublic.setImage(isPublic ? UIImage(named: "togle_big_on") : UIImage(named: "togle_big_off") , forState: .Normal)
    }
    
    @IBAction func actionForInviteGuest(sender: AnyObject) {
        isInviteAllow = !isInviteAllow
        btnToggleInvite.setImage(isInviteAllow ? UIImage(named: "togle_big_on") : UIImage(named: "togle_big_off") , forState: .Normal)
    }
    @IBAction func actionForEndTime(sender: AnyObject) {
        txtEndDate.becomeFirstResponder()
    }
    
    @IBAction func actionForStartTime(sender: AnyObject) {
        txtStartDate.becomeFirstResponder()
    }
    
    @IBAction func btnPublicEventAction(sender: AnyObject) {
        actionForToggelPublic(btnTogglePublic)
    }
    
    @IBAction func invitesOtherAction(sender: AnyObject) {
        actionForInviteGuest(btnToggleInvite)
    }
    
    /// change create event
    
    @IBAction func actionForEventImage(sender: AnyObject) {
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
        imgEvent.image = CommonFunction.resizeImage(image, newWidth: 200.0)
        CommonFunction.setProfilePic(CommonFunction.resizeImage(image, newWidth: image.size.width))
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func changeStringToRPSFor(date:NSDate)->String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter.stringFromDate(date)
    }
    
    func changeContactToJson()->[[String: AnyObject]]{
        var jsonObject: [[String: AnyObject]] = []
        for contact in arrSeletedContacts {
            if contact.title == nil{
                contact.title = ""
            }
            if contact.email == nil{
                contact.email = ""
            }

            let json:[String: AnyObject] = ["email":contact.email!,
                "displayName":contact.title!]
            jsonObject.append(json)
            
        }
      return jsonObject
    }
    
    func handleTap() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        layoutHiddenInfoH.constant = 0.0
      UIView.animateWithDuration(0.5) {
      self.view.layoutIfNeeded()
         }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
