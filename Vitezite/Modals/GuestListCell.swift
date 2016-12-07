//
//  GuestListCell.swift
//  Vitezite
//
//  Created by Padam on 7/21/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import Foundation
import UIKit

class GuestListCell : UITableViewCell{
    
    @IBOutlet weak var lblContacts: UILabel!
    @IBOutlet weak var guestImageView: RoundImage!
    
    @IBOutlet weak var guestNameLabel: UILabel!
    
    @IBOutlet weak var guestEmailLabel: UILabel!
    
    @IBOutlet weak var viteziteImage: UIImageView!
    
    @IBOutlet weak var inviteButton: IndexingButton!
}
