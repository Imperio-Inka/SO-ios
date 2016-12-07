//
//  CalenderListCell.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 05/07/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit

class CalenderListCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var layoutBottomH: NSLayoutConstraint!
    @IBOutlet weak var txtTagName: UITextField!
    @IBOutlet weak var lblCaldsp: UILabel!
    @IBOutlet weak var lblTagHeader: UILabel!
    @IBOutlet weak var btnTickMark: IndexingButton!
    
    @IBOutlet weak var btnEnterTagButton: IndexingButton!
    
    var item : CalendarListModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCellInfo(info : CalendarListModel)  {
        item = info
        lblCaldsp.text = info.summary
        txtTagName.text = info.tags
        //lblTagHeader.text = info.summary
        
        let img = info.isMarked! ? UIImage(named: "check") : UIImage(named: "un_check");
       btnTickMark.setImage(img!, forState: .Normal)
       layoutBottomH.constant = info.isMarked! ? 80.0 : 0.0;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        item.tags = txtTagName.text!
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        txtTagName.resignFirstResponder()
        return true
    }

}
