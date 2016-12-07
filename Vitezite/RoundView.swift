//
//  RoundView.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 24/06/16.
//  Copyright © 2016 BHUVAN SHARMA. All rights reserved.
//

import UIKit

class RoundView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
    }
}
