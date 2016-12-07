//
//  SideMenuViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 29/06/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit

class SideMenuViewController: RootViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblUserN: UILabel!
    @IBOutlet weak var layoutImgTop: NSLayoutConstraint!
    
    var arrMenus : [[String: String]] = [["name":"Home","image":"home"],["name":"My Calender","image":"calender_gray"],["name":"Manage Tags","image":"tag_icon"],["name":"Create Event","image":"create-event"],["name":"Settings","image":"setting"]]
    //,["name":"Profile","image":"user"]
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutImgTop.constant = 40 * heightRatio;
        imgUser.layer.cornerRadius = imgUser.bounds.size.width / 2.0;
        imgUser.layer.masksToBounds = true;
        var user:UserData = UserData.sharedInstance.getCurrentUserData();
        lblUserN.text = user.name;
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let img:UIImage = CommonFunction.getProfileImage() {
            imgUser.image = img;
        }
    }
    @IBOutlet weak var tblMenu: UITableView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func profileAction(sender: AnyObject) {
        let rvc : DSSideViewController  = self.DSViewController()!
        let dvc: ProfileViewController  = UIStoryboard.profileController()!
        self.DSViewController()?.setFrontViewController(dvc);
        DSViewController()?.DSToggleAnimated(true)
        //rvc.pushFrontViewController(dvc, animated: true);
    }
    //MARK: Uitableview Delegate methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65 * heightRatio
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell")
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
        let rvc : DSSideViewController  = self.DSViewController()!
        var dvc : UIViewController?
        if(indexPath.row == 0){
                dvc = UIStoryboard.homeController()!
                rvc.pushFrontViewController(dvc!, animated: true);
            
        }
        else if(indexPath.row == 1){
            
            dvc = UIStoryboard.calenderListController()!
            rvc.pushFrontViewController(dvc!, animated: true);
            
        }else if(indexPath.row == 2){

                dvc = UIStoryboard.tagsController()!
                rvc.pushFrontViewController(dvc!, animated: true);
            
        }else if(indexPath.row == 3){
            
            dvc = UIStoryboard.createEventController()!
           
            rvc.pushFrontViewController(dvc!, animated: true);
            
        }else if(indexPath.row == 4){
            
            dvc = UIStoryboard.settingController()!
            rvc.pushFrontViewController(dvc!, animated: true);
            
        }else{
            dvc = UIStoryboard.settingController()!
            rvc.pushFrontViewController(dvc!, animated: true);
        }
    }
    
    
}
