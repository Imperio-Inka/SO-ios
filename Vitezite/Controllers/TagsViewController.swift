 //
//  TagsViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 28/06/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit
import SwiftDDP 
 
 protocol UpdateTagsDelegate : class {
    func setTagsFromTagList(selectedTag : [String])
 }
 
 
class TagsViewController: RootViewController,UITableViewDelegate,UITableViewDataSource {
    
    weak var delegate : UpdateTagsDelegate!
    @IBOutlet weak var hView: UIView!
    @IBOutlet weak var lblTagName: ExpandableFontLabel!
    @IBOutlet weak var tblCustomTags: UITableView!
    var  tagHeader : String!
    var isDetail : Bool = false
    var selectdSection : Int = -1
    
    var arrSelectedTags : [String] = []
    var arrTagViews : [UIView] = []
    var arrTagsSection:[NSDictionary] = [];
    var arrTags : [TagsModels] = []
    var arrSubTags :[String] = []
    var isfromCreateEventScreen:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTagName.text = tagHeader
        headerView = getHeaderInstance()
        headerView.lblHeader.text = "Manage Tags"
        headerView.btnRight.hidden = false
        headerView.btnRight.setTitle("Done", forState: .Normal)
        headerView.btnRight.addTarget(self, action: #selector(TagsViewController.gotoNextPage(_:)), forControlEvents: .TouchUpInside)
        hView.updateConstraints()
        hView.layoutIfNeeded()
        hView.addSubview(headerView)
        
        if isfromCreateEventScreen{
            headerView.imgSide.image = UIImage(named: "back_arrow")
            headerView.btnSide.addTarget(self, action: #selector(TagsViewController.actionGoBack), forControlEvents: .TouchUpInside)
        }
        else{
            headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TagsViewController.checkSideMenuOpen(_:)), name: "SideMenuChange", object: nil)
        tblCustomTags.tableFooterView = UIView()
        
        
        self.showActivityIndicator("Loading")
        Meteor.call("tags.school", params:[UserData.sharedInstance.schollName]) { (result, error) in
            self.hideActivityIndicator()
            if (error == nil && result != nil){
                let dict:NSDictionary = result as! NSDictionary
                self.arrTagsSection = dict.objectForKey("tags") as! [NSDictionary]
                for dict in self.arrTagsSection{
                    let t1 = TagsModels()
                    t1.title = dict["category"] as? String;
                    t1.arrTags = dict["tags"] as! [String];
                    t1.arrTags = t1.arrTags.sort(){ $0 < $1 }
                    t1.isSelected = false;
                    self.arrTags.append(t1)
                }
                self.tblCustomTags .reloadData();
                if(self.isfromCreateEventScreen){
                    return;
                }
                self.arrSelectedTags = UserData.sharedInstance.userTags
                self.tblCustomTags.reloadData()
//                Meteor.call("tags.user", params:nil) { (result, error) in
//                    if (error == nil && result != nil){
//                        let dict1:NSDictionary = result as! NSDictionary
//                        let arrSelectedCatTags:[NSDictionary] = dict1["tags"] as! [NSDictionary]
//                        for dict in arrSelectedCatTags{
//                            let arrSelected:[String] = dict["tags"] as! [String]
//                         self.arrSelectedTags.appendContentsOf(arrSelected)
//                        }
//                        self.tblCustomTags .reloadData();
//                    }
//                    }
            }
            
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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addSideNavigationGesture()
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        removeSildeNavigationGesture()
        
    }

    func  actionGoBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func gotoNextPage(sender : AnyObject)  {
        
        
        if isfromCreateEventScreen{
            delegate?.setTagsFromTagList(arrSelectedTags)
            self.navigationController?.popViewControllerAnimated(true)
            
        }else{
            self.showActivityIndicator("Loading")
            Meteor.call("users.setTags", params:  [arrSelectedTags]) { (result, error) in
                self.hideActivityIndicator()
                UserData.sharedInstance.userTags = self.arrSelectedTags;
                print(result)
                if ((error ) == nil) {
                }
                //vc!.isfrom = "Tags"
               // let rvc : DSSideViewController  = self.DSViewController()!
               // let dvc: HomeViewController  = UIStoryboard.homeController()!
                let vc = UIStoryboard.homeController()
                self.DSViewController()?.setFrontViewController(vc!)
               
            }
        }
        
    }
    
    
    @IBAction func actionForBack(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if selectdSection == section{
//            return 1
//        }else{
//            return 0
//        }
        if arrTags[section].isSelected! {
            return 1;
        }
        return 0;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return arrTags.count;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let arrViews = NSBundle.mainBundle().loadNibNamed("SectionView", owner: nil, options: nil)
        var sectV : TagSectionView!
        for vs in arrViews
        {
            if vs.isKindOfClass(TagSectionView){
                sectV = vs as! TagSectionView
                break
            }
        }
        sectV.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 55 * heightRatio)
        sectV.updateConstraints()
        sectV.lblSecHeader.text = arrTags[section].title
        sectV.btnSection.addTarget(self, action: #selector(TagsViewController.expandSelectedSection(_:)), forControlEvents: .TouchUpInside)
        sectV.btnSection.section = section
        return sectV
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55*heightRatio
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var xV : CGFloat  = 10.0
        var yV : CGFloat = 10.0
        for (index,itm) in arrTags[indexPath.section].arrTags.enumerate() {
            let vs = self.customTagCellFormation(index, vlue: itm, section: indexPath.section)
            vs.frame = CGRectMake(xV, yV, vs.frame.size.width, vs.frame.size.height)
            xV = xV + vs.frame.size.width + 30;
            if xV > UIScreen.mainScreen().bounds.size.width - 100 {
                xV = 10
                yV = yV + 46;
            }
        }
        return yV + 46;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomTagCell")
        var xV : CGFloat  = 10.0
        var yV : CGFloat = 10.0
        for vs in (cell?.contentView.subviews)! {
            vs.removeFromSuperview()
        }
        for (index,itm) in arrTags[indexPath.section].arrTags.enumerate() {
            let vs = self.customTagCellFormation(index, vlue: itm, section: indexPath.section)
            vs.frame = CGRectMake(xV, yV, vs.frame.size.width, vs.frame.size.height)
            cell?.contentView.addSubview(vs)
            xV = xV + vs.frame.size.width + 30;
            if xV > UIScreen.mainScreen().bounds.size.width - vs.frame.size.width {
                xV = 10
                yV = yV + 46;
            }
        }
        return cell!
    }
    
    func customTagCellFormation(index : Int, vlue : String,section : Int) -> UIView {
        
        let tgV = UIView(frame: CGRectMake(0, 0, vlue.widthWithConstrainedWidth(25, font: UIFont.systemFontOfSize(16)) + 30, 36) )
        
        CommonFunction.setLayerForView(tgV, borderColor: UIColor.blackColor(), boderWidth: 1.0, cornerRadius: 16)
        
        let lblTg = UILabel(frame: CGRectMake(0, 3, vlue.widthWithConstrainedWidth(25, font: UIFont.systemFontOfSize(16))+20, 30))

        tgV.addSubview(lblTg)
        lblTg.font = UIFont.systemFontOfSize(16)
        lblTg.textAlignment = .Center
        lblTg.text = vlue;
        lblTg.textColor = UIColor(red: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1.0)
        lblTg.backgroundColor = UIColor.clearColor()
        
        lblTg.center = tgV.center;
        if !arrSelectedTags.contains(vlue){
            tgV.backgroundColor = UIColor.whiteColor()
            lblTg.textColor = UIColor.lightGrayColor()
        }else{
            tgV.backgroundColor = UIColor().appRedColor
            lblTg.textColor = UIColor.whiteColor()
        }
        
        let btnTg = IndexingButton(frame: CGRectMake(0, 0, tgV.frame.size.width, 36))
        btnTg.backgroundColor = UIColor.clearColor()
        btnTg.index = index;
        btnTg.valueItem = vlue;
        btnTg.section = section;
        
        
        btnTg.addTarget(self, action: #selector(TagsViewController.gotoHomePage(_:)), forControlEvents: .TouchUpInside)
        tgV.addSubview(btnTg)
        arrTagViews.append(tgV)
        return tgV
    }
    
    func gotoHomePage(sender : AnyObject)  {
        let btn = sender as! IndexingButton
        if !arrSelectedTags.contains(btn.valueItem!) {
            arrSelectedTags.append(btn.valueItem!)
        }else{
            arrSelectedTags.removeAtIndex(arrSelectedTags.indexOf(btn.valueItem!)!)
        }
        
        tblCustomTags.beginUpdates()
        tblCustomTags.reloadSections(NSIndexSet(index: btn.section!), withRowAnimation: .None)
        tblCustomTags.endUpdates()
    }
    
    func expandSelectedSection(sender : AnyObject){
        let btn = sender as! IndexingButton
        selectdSection = btn.section!
        arrTags[selectdSection].isSelected =  !arrTags[selectdSection].isSelected
        tblCustomTags.reloadData()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     [guestList beginUpdates];
     if (!guest.didArrive) {
     [guest setDidArrive:YES];
     [guestList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
     } else {
     [guest setDidArrive:NO];
     [guestList reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
     }
     [guestList endUpdates];
     [guestList reloadData];
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
