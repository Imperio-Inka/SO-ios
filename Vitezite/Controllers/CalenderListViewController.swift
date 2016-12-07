//
//  CalenderListViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 05/07/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit
import SwiftDDP


class CalenderListViewController: RootViewController,UpdateTagsDelegate {

    
    @IBOutlet weak var tblCalenderlist: UITableView!
     @IBOutlet weak var hView: UIView!
    var currentTextField:UITextField = UITextField();
    
    var arrCalendarItems :[CalendarListModel] = []
    var arrEventTags :[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        headerView = getHeaderInstance()
        headerView.lblHeader.text = "Calendar List"
        hView.updateConstraints()
        hView.layoutIfNeeded()
       // headerView.btnRight.hidden = false
       // headerView.btnRight.setTitle("Next", forState: .Normal)
       // headerView.btnRight.addTarget(self, action: #selector(CalenderListViewController.gotoNextPage(_:)), forControlEvents: .TouchUpInside)
        //headerView.btnSkip.hidden = false
        
       // headerView.btnSkip.addTarget(self, action: #selector(CalenderListViewController.Skip(_:)), forControlEvents: .TouchUpInside)
        headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        hView.addSubview(headerView)
        // Do any additional setup after loading the view.
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalenderListViewController.checkSideMenuOpen(_:)), name: "SideMenuChange", object: nil)
        
        tblCalenderlist.estimatedRowHeight = 51
        tblCalenderlist.rowHeight = UITableViewAutomaticDimension
        
        if AppPreference.sharedInstance.getUserPreferencePopupStatus() == nil{
            AppPreference.sharedInstance.setUserPreferencePopup(false)
        }
        
        showActivityIndicator("Loading")
        Meteor.call("calendars.list", params: nil) { (result, error) in
            
            self.hideActivityIndicator()
            if ((error ) == nil) {
                
                print("helkhjaslkjlkasjfl \(result)")
                if let arr = result as? [NSDictionary]{
                var calList:CalendarListModel = CalendarListModel();
                
                for dict in arr{
                    calList = CalendarListModel()
                    
                    let id:String = dict.valueForKey("id") as! String
                    calList.id = id;
                    let summary:String = dict.valueForKey("summary") as! String
                    calList.summary = summary;
                    if (dict.valueForKey("description") != nil){
                    let title:String = dict.valueForKey("description") as! String
                    calList.title = title
                    }
                    calList.isMarked = false
                    self.arrCalendarItems.append(calList)
                    
                }
                    UserData.sharedInstance.usercalenderList = self.arrCalendarItems
                    self.tblCalenderlist .reloadData()
                
            }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Skip(sender : AnyObject){
        let vc = UIStoryboard.homeController()
        self.DSViewController()?.setFrontViewController(vc!)
        
    }
    
    @IBAction func gotoNextPage(sender : AnyObject)  {
        var indexPath :NSIndexPath;
        var indexs:[NSInteger] = []
        
        for (index,calList) in self.arrCalendarItems.enumerate(){
            if calList.isMarked==true {
                indexs.append(index)
                
                
    }
        }
        if indexs.count == 0 {
            self.showNormalAlert(kProjectName, msg: "Please select atleast One calender")
            return
        }
        var i:NSInteger = 0;
       
        for index in indexs {
            let calList = self.arrCalendarItems[index]
                indexPath = NSIndexPath(forRow: index, inSection: 0);
                let cell = tblCalenderlist.cellForRowAtIndexPath(indexPath) as! CalenderListCell
            let tags:String = (cell.txtTagName.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
            if tags.characters.count == 0{
                 self.hideActivityIndicator()
                self.showNormalAlert(kProjectName, msg: "Please select atleast One Tag For calender "+calList.summary)
                return;
            }
             self.showActivityIndicator("loading")
                let tagsArr:[String] = cell.txtTagName.text!.componentsSeparatedByString(",")
                Meteor.call("calendars.init", params: [calList.id,tagsArr]) { (result, error) in
                    self.hideActivityIndicator()
                    if ((error ) == nil) {
                        Meteor.call("calendars.sync", params:[calList.id]) { (result, error) in
                            print(result)
                            
                        }
                    }
                }
            
            if i == indexs.count - 1{
                self.callAllTagApi()
                
                //self.navigationController?.pushViewController(vc!, animated: true)
                
            }
            i += 1;
        }
        
    }
    
    func callAllTagApi(){
        Meteor.call("tags.school", params:[UserData.sharedInstance.schollName]) { (result, error) in
            if (error == nil && result != nil){
                let dict:NSDictionary = result as! NSDictionary
                let arrTags = dict.objectForKey("tags") as! [NSDictionary]
                var arrSelectedTag:[String] = []
                
                for dict in arrTags{
                    let t1 = TagsModels()
                    t1.title = dict["category"] as? String;
                    t1.arrTags = dict["tags"] as! [String];
                    t1.isSelected = false;
                    arrSelectedTag.appendContentsOf(t1.arrTags)
                }
                self.showActivityIndicator("Loading")
                Meteor.call("users.setTags", params:  [arrSelectedTag]) { (result, error) in
                    self.hideActivityIndicator()
                    UserData.sharedInstance.userTags = arrSelectedTag;
                    print(result)
                    let vc = UIStoryboard.homeController()
                    self.DSViewController()?.setFrontViewController(vc!)
                    if ((error ) == nil) {
                    }
            }
            
        }

    }
    }
    
    
    // table view delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCalendarItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CalendarItemCell") as! CalenderListCell
        cell.updateCellInfo(arrCalendarItems[indexPath.row] )
        cell.btnTickMark.addTarget(self, action: #selector(CalenderListViewController.actionForClickTagsCell(_:)), forControlEvents: .TouchUpInside)
        cell.btnEnterTagButton.addTarget(self, action: #selector(CalenderListViewController.actionForEnterTagTextCell(_:)), forControlEvents: .TouchUpInside)
        cell.btnTickMark.index = indexPath.row
        cell.btnTickMark.section = indexPath.section;
        cell.btnEnterTagButton.index = indexPath.row
        cell.btnEnterTagButton.section = indexPath.section;
        cell.txtTagName.text = arrCalendarItems[indexPath.row].tags
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let vc = UIStoryboard.createEventController()
//        vc?.isDetail = true
//        self.navigationController?.pushViewController(vc!, animated: true)
        setCurrentTagCell(indexPath)
            }

    func actionForClickTagsCell(sender : AnyObject)  {
        let btn = sender as! IndexingButton
        setCurrentTagCell(NSIndexPath(forRow: btn.index!, inSection: btn.section!))
    }
    
    func actionForEnterTagTextCell(sender : AnyObject)  {
        let btn = sender as! IndexingButton
        let cell1 = tblCalenderlist.cellForRowAtIndexPath(NSIndexPath(forRow: btn.index!, inSection: btn.section!)) as! CalenderListCell
        currentTextField = cell1.txtTagName
        arrEventTags = currentTextField.text!.componentsSeparatedByString(",")
        var index:NSInteger = 0;
        for str in arrEventTags {
            if str == ""{
                arrEventTags.removeAtIndex(index)
            }
            index += 1
        }
        let vc = UIStoryboard.tagsController()
        vc?.isfromCreateEventScreen = true
        vc?.arrSelectedTags = arrEventTags
        vc?.delegate = self
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func setCurrentTagCell(indexPath:NSIndexPath){
        arrCalendarItems[indexPath.row] .isMarked = !arrCalendarItems[indexPath.row].isMarked!
       
        let rowCount = tblCalenderlist.numberOfRowsInSection(0)
               for row in 0 ..< rowCount {
            let cell1 = tblCalenderlist.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as! CalenderListCell
            arrCalendarItems[row].tags =  cell1.txtTagName.text
        }
//        if !arrCalendarItems[indexPath.row] .isMarked!{
//            let textField = cell.viewWithTag(100) as! UITextField
//            arrCalendarItems[indexPath.row].tags =  textField.text
//        }
        tblCalenderlist.reloadData()
    }
    
//    func setTagsFromTagList(tag: String) {
//        currentTextField.text = tag
//    }
    func setTagsFromTagList(selectedTags : [String]) {
        arrEventTags = selectedTags
        if  selectedTags.count == 0{
            return
        }
        var strTg :  String = ""
        for itm in selectedTags {
            strTg = strTg == "" ? itm : "\(strTg),\(itm)"
        }
        currentTextField.text = strTg
    }



}
