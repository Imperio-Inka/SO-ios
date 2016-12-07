//
//  HomeViewController.swift
//  Vitezite
//
//  Created by Padam on 6/24/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import Foundation
import UIKit
import SwiftDDP

class HomeViewController: RootViewController,UITableViewDelegate,UITableViewDataSource,NWCalendarViewDelegate {
    
    let collection:MeteorCollection<Event> = (UIApplication.sharedApplication().delegate as! AppDelegate).events
     @IBOutlet weak var hView: UIView!
    @IBOutlet weak var tblHome: UITableView!
     @IBOutlet weak var calendarView: NWCalendarView!
    var refreshControl: UIRefreshControl!
    
    var arrEventTags : [String] = []
    
    var arrEvents : [Event] = []
    var arrKeys:[String] = [];
    var dictEvent = [String:[Event] ]()
    var isfrom : String! = ""
    override func viewDidLoad() {
         let date = NSDate()
        headerView = getHeaderInstance()
        headerView.lblHeader.text = "Home"
        hView.updateConstraints()
        hView.layoutIfNeeded()
        hView.addSubview(headerView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.checkSideMenuOpen(_:)), name: "SideMenuChange", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.updateResult(_:)), name: "EventListUpdate", object: nil)
        
//        if isfrom == "Tags"{
//            headerView.imgSide.image = UIImage(named: "back_arrow")
//            headerView.btnSide.addTarget(self, action: #selector(HomeViewController.actionGoBack), forControlEvents: .TouchUpInside)
//        }
//        else{
//            headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        }
        
        headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        tblHome.estimatedRowHeight = 115
        tblHome.rowHeight = UITableViewAutomaticDimension
        
        calendarView.selectedDates = [date]
        calendarView.selectionRangeLength = 1
        calendarView.maxMonths = 0
        calendarView.delegate = self
        calendarView.createCalendar()
        calendarView.scrollTocurrentDate()
        (UIApplication.sharedApplication().delegate as! AppDelegate).registerForPushNotifications(UIApplication.sharedApplication())
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "refreshing Events")
        refreshControl.addTarget(self, action: #selector(HomeViewController.refreshList), forControlEvents: UIControlEvents.ValueChanged)
        tblHome.addSubview(refreshControl)
        tblHome.bringSubviewToFront(refreshControl)
        
        if AppPreference.sharedInstance.getUserPreferencePopupStatus() == false{
            self.performSelector(#selector(HomeViewController.showInterestPopup(_:)), withObject: nil, afterDelay: 2)
        }
        
    }
    
    func showInterestPopup(sender : AnyObject)  {
        AppPreference.sharedInstance.setUserPreferencePopup(true)
        let action1 = UIAlertAction(title: "Not Now", style: .Default) { (UIAlertAction) in
            
        }
        let action2 = UIAlertAction(title: "Let's Do It!", style: .Default) { (UIAlertAction) in
            let vc = UIStoryboard.tagsController()
            self.DSViewController()?.setFrontViewController(vc!)
        }
        
        self.showAlertMsg(kProjectName, msg: "Let's personalize your event feed. Click here to tell us your interests.", arrAction: [action1,action2])
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addSideNavigationGesture()
       // self.showActivityIndicator("Loading")
       refreshList()

        
    }
  
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        removeSildeNavigationGesture()
        
    }
    
    func refreshList(){
        refreshControl.endRefreshing()

        Meteor.subscribe("events.feeds") {
            self.hideActivityIndicator()
            
            if let _:[Event] = self.collection.sorted  {
                self.arrEvents.removeAll()
                print(self.collection.sorted)
                for (_,calList) in self.collection.sorted.enumerate(){
                    let event:Event = calList;
                    print(event);
                    self.arrEvents.append(event);
                    
                    
                }
                self.converEventInGroup()
                print(self.dictEvent)
                self.tblHome .reloadData();
            }
            
        }

    }

    
    func checkSideMenuOpen(notificaiton : NSNotification) {
        
        print("side value to check : \(self.DSViewController()?._frontViewPosition)")
        print("side value to check rear : \(self.DSViewController()?._rearViewPosition)")
        
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
    
    func updateResult(notificaiton : NSNotification){
        refreshList()
    }

    func  actionGoBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // table view delegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
          return dictEvent.keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictEvent[arrKeys[section]]!.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeHeaderEventCell") as! HomeHeaderEventCell
        cell.lblHeader.text = arrKeys[section]
        return cell.contentView;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell") as! HomeEventTableViewCell
        cell.eventaImageView.image = UIImage(named: "images.jpeg")
        var date:String = "";
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let event:Event = dictEvent[arrKeys[indexPath.section]]![indexPath.row]//arrEvents[indexPath.section]
       
        if (event.start != nil) {
            date = dateFormatter.stringFromDate(event.start!)
        }
        if (arrEvents[indexPath.row].end != nil) {
            date = date+"-"+dateFormatter.stringFromDate(event.end!)
        }
        cell.eventLocationButton.addTarget(self, action:#selector(HomeViewController.actionForLocationMap(_:)), forControlEvents: .TouchUpInside)
        
        cell.eventTimeLabel.text = date
        cell.eventHeadingLabel.text = event.summary
        cell.eventDescriptionLabel.text = event.location
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event:Event = dictEvent[arrKeys[indexPath.section]]![indexPath.row]//arrEvents[indexPath.section];
        
        let vc = UIStoryboard.createEventController()
        vc?.event = event;
        if UserData.sharedInstance.getCurrentUserData()._id == vc?.event.createdBy
        {
            vc?.isEdit = true
        }
        else{
        vc?.isDetail = true
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
     func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if tblHome.indexPathsForVisibleRows?.count == 0{
            return;
        }
        let indexs:[NSIndexPath] = tblHome.indexPathsForVisibleRows!
        let index:NSIndexPath = indexs[0]
        let event:Event = dictEvent[arrKeys[index.section]]![0]
        
        //
        calendarView.setDefault(event.start!)
        calendarView.selectedDates = [event.start!]
        calendarView.selectionRangeLength = 1
        calendarView.maxMonths = 0
     

//        calendarView.monthContentView.presentMonth = NSCalendar.usLocaleCurrentCalendar().components(unitFlags, fromDate: event.start!)
//
       calendarView.createCalendar()

        calendarView.scrollTocurrentDate()
        
        
    }
    
     func actionForLocationMap(sender : AnyObject) {
        
        let btn = sender as! IndexingButton
            let query = "?address=\(btn.valueItem)"
            let path = "http://maps.apple.com/" + query
            
            if let url = NSURL(string: path) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                //UIApplication.sharedApplication().openURL(url)
                // Could not construct url. Handle error.
            }
    }
    
    //calender delegate
    
    func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents) {
        if(self.arrKeys.count == 0){
        return
        }
        let cal = NSCalendar.currentCalendar()
        var date = cal.dateFromComponents(toDate)
        date = cal.startOfDayForDate(date!)
        
        let  dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormat.dateFormat = "MM-dd-yyyy"
    
       let dateString = dateFormat.stringFromDate(date!)
        let date1 = dateFormat.dateFromString(dateString)
        var event = dictEvent[self.arrKeys[0]]![0]
        var min: Double = abs(date1!.timeIntervalSinceDate(event.start!))
        var minIndex: Int = 0
        for i in 1 ..< arrKeys.count {
            event = dictEvent[self.arrKeys[i]]![0]
            let currentmin: Double = abs( date1!.timeIntervalSinceDate(event.start!))
            if currentmin < min {
                min = currentmin
                minIndex = i
            }
            
            
        }
        let sectionRect: CGRect = tblHome.rectForSection(minIndex)
        //sectionRect.size.height = tblHome.frame.size.height
        tblHome.scrollRectToVisible(sectionRect, animated: true)
    }
    
        
        //to do scroll to date

    
    
    //group the event list with date 
    func converEventInGroup() {
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "MM-dd-yyyy"
        let now: NSDate = NSDate()
        var theDate: String = dateFormat.stringFromDate(now)
        var arrKeysDays:[String] = [];
        arrKeys.removeAll()
       // var arr1: [AnyObject] = NSMutableArray() as [AnyObject]
        let arrDate: NSMutableArray = NSMutableArray()
        let arrTempEvent:NSMutableArray = (arrEvents as NSArray).mutableCopy() as! NSMutableArray;
       
        var predicate: NSPredicate = NSPredicate(block: {( evaluatedObject, bindings) -> Bool in
            
            let event = evaluatedObject as! Event;
            let eventString = dateFormat.stringFromDate(event.start!);
            let Str:String = "\(theDate)"
            return (eventString == Str)
           
        })

        var oldEvent:NSArray = arrTempEvent.filteredArrayUsingPredicate(predicate)
        if  oldEvent.count > 0 {
            //arrKeys.append("Today")
            arrKeysDays.append("Today")
            dictEvent["Today"] = oldEvent as? [Event]
            
        }
        arrTempEvent.removeObjectsInArray(oldEvent as [AnyObject])
        
        let yesterday: NSDate = now.dateByAddingTimeInterval(-86400.0)
        theDate = dateFormat.stringFromDate(yesterday)
        
        predicate = NSPredicate(block: {( evaluatedObject, bindings) -> Bool in
            
            let event = evaluatedObject as! Event;
            let eventString = dateFormat.stringFromDate(event.start!);
            return (eventString == theDate)
           
        })
        // assumes allPeople is an NSArray of Person objects to be filtered
        // and assumes Person has an NSString date_of_birth property
        oldEvent = arrTempEvent.filteredArrayUsingPredicate(predicate)
        if  oldEvent.count > 0 {
            arrKeysDays.append("Yesterday")
             dictEvent["Yesterday"] = oldEvent as? [Event]
        }
        arrTempEvent.removeObjectsInArray(oldEvent as [AnyObject])
        for i in 0 ..< arrTempEvent.count {
            let firstEvent: Event = arrTempEvent[i] as! Event
            let gmtDate: String = dateFormat.stringFromDate(firstEvent.start!)
            if !arrDate.containsObject(gmtDate) {
                arrDate.addObject(gmtDate)
                arrKeys.append(gmtDate)
                dictEvent[gmtDate] = [firstEvent]
            }
            else {
                var er = dictEvent[gmtDate]
                er?.append(firstEvent)
                dictEvent[gmtDate] = er;
             
            }
        }
        
     
        if arrKeys.count>2 {
             arrKeys.sortInPlace({
                dateFormat.dateFromString($0)!.compare(dateFormat.dateFromString($1)!) == NSComparisonResult.OrderedAscending
             })
        }
        
        //for s in arrKeysDays {
            arrKeys.insertContentsOf(arrKeysDays, at: 0)
       // }
       
        //arrKeys = arrKeys.sort(){$0 > $1}

    }
    
    
    
   
    
}


