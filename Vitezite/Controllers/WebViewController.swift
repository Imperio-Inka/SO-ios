//
//  WebViewController.swift
//  Vitezite
//
//  Created by Padam on 7/29/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import Foundation
import UIKit


class WebViewController: RootViewController{
    
   
     @IBOutlet weak var hView: UIView!
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView = getHeaderInstance()
        headerView.lblHeader.text = "Terms of Use"
        hView.updateConstraints()
        hView.layoutIfNeeded()
        hView.addSubview(headerView)
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.vitezite.com/tos")!))
        headerView.btnSide.addTarget(self, action: #selector(WebViewController.actionGoBack), forControlEvents: .TouchUpInside)
        headerView.imgSide.image = UIImage(named: "back_arrow")
    }
    
    func  actionGoBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
