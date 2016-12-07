//
//  TagListViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 24/06/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit
import SwiftDDP 


class TagListViewController: RootViewController,UITableViewDelegate,UITableViewDataSource {

    var isDetail : Bool = false

    @IBOutlet weak var tblTags: UITableView!
    @IBOutlet weak var hView: UIView!
    //var arrTags : [String] = ["Social","Sports, Health, and Active Living","Music, Art, Entertainment","Faith, Culture, and Spirituality","Social Justice and Government"];
    //var arrTags
    var  arrTags:[NSDictionary] = [];
    
    var arrDict: NSDictionary = ["Social":["Free Food","Greek Life","BBQ","Party","Date Event???","Trips/Excursions ","Social Sciences","Natural Sciences","Business, Marketing, and Management","Mechanical Engineering","Civil Engineering","Accounting and Finance","Networking and Careers","Workshops and Speakers ","Academic Fraternities","Honors Societies"],
                                 
        "Sports, Health, and Active Living":["Basketball","Baseball/Softball","Swimming","Water Polo","Badminton","Boxing","Cricket","Dodgeball","Bowling","Fencing","Golf","Field Hockey","Football","Shooting/Archery","Gymnastics","Tennis","Snow Sports","Water Sports","Volleyball","Kickball","Surfing","Hiking/Camping","Climbing","Quidditch","Biking","Crew/Rowing","Sailing","Martial Arts","Equestrian","Fishing","Hockey","Hunting ???","Kite Sports","Track/ Cross- Country","Lacrosse","Rugby","Rafting/River Sports","Driving","Scuba Diving/Snorkeling","Weightlifting/Body Building","General Health"],
        "Music, Art, Entertainment":["Music Composition and Production","Concerts and Festivals, ","A Capella, ","Comedy/ Improv, ","Theater,","Film and Telivision, ","Creative Writing, and Journalism","Art History ","Sculpture, Ceramics, Glass and Wood Work ","Poetry and Spoken Word" ],
        
        "Faith, Culture, and Spirituality":["Christianity","Jedaism ","Islam "," Meditation "," Retreats ","Services ","Scripture, Study and Discussion  ","LGBTQ and PRIDE ","Multicultural"],
        
        "Social Justice and Government":["Democrats"," Republicans"," Independent, Green or Other "," Student Government "," Health and Medical Awareness "," Ending Poverty "," Ending Starvation and Hunger"," Environmental Sciences","Education Reform","Judicial Reform ","International politics" ]
        
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = getHeaderInstance()
        headerView.lblHeader.text = "My Tags"
        hView.updateConstraints()
        hView.layoutIfNeeded()
        hView.addSubview(headerView)
        
        headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
       // self.view.addGestureRecognizer(self.DSViewController()!.panGestureRecognizer())
//        self.view.addGestureRecognizer(self.DSViewController()!.tapGestureRecognizer())
        if isDetail{
            headerView.btnSide.addTarget(self, action: #selector(TagListViewController.actionForBack), forControlEvents: .TouchUpInside)
            
        }else{
            headerView.btnSide.addTarget(self.DSViewController(), action: #selector(DSViewController()?.DSToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }

        
        tblTags.estimatedRowHeight = 60 * heightRatio
        tblTags.rowHeight = UITableViewAutomaticDimension
        Meteor.call("tags.school", params:[UserData.sharedInstance.schollName]) { (result, error) in
          if (error == nil && result != nil){
            let dict:NSDictionary = result as! NSDictionary
            self.arrTags = dict.objectForKey("tags") as! [NSDictionary]
            self.tblTags .reloadData();
            }
            
        }
        
    
    }
    
    

    
    @IBAction func actionForBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTags.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tagCell")
        let lblTagname = cell?.viewWithTag(1001) as! UILabel
        let dict:NSDictionary = arrTags[indexPath.row]
        lblTagname.text = dict.valueForKey("category") as? String
        return cell!
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60 * heightRatio
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = UIStoryboard.tagsController();
        let dict:NSDictionary = arrTags[indexPath.row]
        vc?.tagHeader = dict.valueForKey("category") as? String;
        vc?.arrSubTags = dict.valueForKey("tags")  as! [String];
        self.navigationController?.pushViewController(vc!, animated: true);
    }
}
