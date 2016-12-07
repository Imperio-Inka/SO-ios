//
//  SettingViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 28/07/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit
import SwiftDDP
import MessageUI
import DigitsKit

class SettingViewController: RootViewController,MFMailComposeViewControllerDelegate {

     var arrMenus : [[String: String]] = [["name":"Feedback","image":"feedback"],["name":"Rate The App","image":"rate"],["name":"Terms And Conditions","image":"condation"],["name":"Delete Account","image":"delete-account"]]
    @IBOutlet weak var hView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView = getHeaderInstance()
        headerView.lblHeader.text = "Settings"
        headerView.btnRight.hidden = true
        hView.updateConstraints()
        hView.layoutIfNeeded()
        hView.addSubview(headerView)
        headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingViewController.checkSideMenuOpen(_:)), name: "SideMenuChange", object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addSideNavigationGesture()
        // self.showActivityIndicator("Loading")
       
        
        
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
    
    //MARK: Uitableview Delegate methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65 * heightRatio
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingCell")
        let lblName = cell?.viewWithTag(1002) as! UILabel
        let img = cell?.viewWithTag(1001) as! UIImageView
        
        lblName.text  = arrMenus[indexPath.row]["name"]
        img.image = UIImage(named: arrMenus[indexPath.row]["image"]!)
        return cell!
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenus.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let rvc : DSSideViewController  = self.DSViewController()!
        var dvc : UIViewController?
      if(indexPath.row == 0){
            let mail: MFMailComposeViewController = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            if MFMailComposeViewController.canSendMail() {
                mail.setToRecipients(["feedback@vitezite.com"])
                mail.setSubject( String(format: "ViteZite iOS App Feedback"))
                self.presentViewController(mail, animated: true, completion: { _ in })
            }
            
        }else if(indexPath.row == 1){
            
            let url = "itms-apps://itunes.apple.com/app/id\("")"
            
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            
        }else if(indexPath.row == 2){
            dvc = UIStoryboard.webViewController()!
            //self.DSViewController()?.setFrontViewController(dvc!);
            self.navigationController?.pushViewController(dvc!, animated: true)

            
        }else{
            self.showActivityIndicator("Loading...")
            Meteor.logout({ (result, error) in
                self.hideActivityIndicator()
                 let digits = Digits.sharedInstance()
                digits.logOut()
                UserData.sharedInstance.removeCurrentUser()
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
