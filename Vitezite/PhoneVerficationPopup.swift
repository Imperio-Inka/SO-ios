//
//  PhoneVerficationPopup.swift
//  Vitezite
//
//  Created by Padam on 7/29/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import Foundation
import UIKit

class PhoneVerficationPopup: UIView {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var verifyPhoneView: UIView!

    override func awakeFromNib() {
        mainView.layer.cornerRadius = 10.0
        mainView.clipsToBounds = true
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.removeFromSuperview()
    }
    
}
