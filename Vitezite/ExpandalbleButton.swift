//
//  ExpandalbleButton.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 24/06/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit

class ExpandalbleButton: UIButton {

    @IBInspectable var lblfontiPhone:CGFloat = 0 {
        didSet {
            overrideFontSize(lblfontiPhone*heightRatio)
        }
    }
    
    @IBInspectable var lblfontiPad :CGFloat = 0 {
        didSet {
            overrideFontSize(lblfontiPad*heightRatio)
        }
    }
    
    func overrideFontSize(fontSize:CGFloat){
        let currentFontName = self.titleLabel?.font.fontName
        if let calculatedFont = UIFont(name: currentFontName!, size: fontSize) {
            self.titleLabel?.font = calculatedFont
        }
    }
}
