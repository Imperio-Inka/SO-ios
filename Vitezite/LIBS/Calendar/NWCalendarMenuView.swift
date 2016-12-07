//
//  NWCalendarMenuView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/23/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import UIKit

protocol NWCalendarMenuViewDelegate {
  func prevMonthPressed()
  func nextMonthPressed()
}

class NWCalendarMenuView: UIView {
    
  private let kDayColor = UIColor().appLightRedColor
    
    //private let kDayFont  = UIFont(name: , size: 16)
    private let kDayFontL : UIFont = UIFont(name: "Roboto-Regular", size: 16.0)!    
  
  var delegate         : NWCalendarMenuViewDelegate?
  var monthSelectorView: NWCalendarMonthSelectorView!
  var days             : [String]  = []
  var sectionHeight    : CGFloat {
    return frame.height/2
  }
    
    private let kSeperatorColor:UIColor!  = UIColor.clearColor()
    
    private let kSeperatorWidth:CGFloat!  = 1.0
  
  init() {
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.whiteColor()

    monthSelectorView = NWCalendarMonthSelectorView(frame: CGRect(x: 0, y: 0, width: frame.width, height: sectionHeight))
    monthSelectorView.prevButton.addTarget(self, action: #selector(NWCalendarMenuView.prevMonthPressed(_:)), forControlEvents: .TouchUpInside)
    monthSelectorView.nextButton.addTarget(self, action: #selector(NWCalendarMenuView.nextMonthPressed(_:)), forControlEvents: .TouchUpInside)
    addSubview(monthSelectorView)
    addSeperator(frame.height-kSeperatorWidth)
    setupDays()
    setupDayLabels()
  }
  
    private func addSeperator(y: CGFloat) {
        let seperator = CALayer()
        seperator.backgroundColor = kSeperatorColor.CGColor
        seperator.frame = CGRect(x: 0, y: y, width: frame.width, height: kSeperatorWidth)
        layer.addSublayer(seperator)
    }
    
    func setupDays() {
        days = ["S","M","T","W","T","F","S"];
    }
  
  
  func setupDayLabels() {
    let width = frame.width / 7
    let height = sectionHeight
    
    var x:CGFloat = 0
    let y:CGFloat = CGRectGetMaxY(monthSelectorView.frame)
    
    for i in 0..<7 {
      x = CGFloat(i) * width
      createDayLabel(x, y: y, width: width, height: height, day: days[i])
    }
    
  }
  
  func createDayLabel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, day: String) {
    let dayLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
    let sepratorView = UIView(frame: CGRect(x: x, y: dayLabel.frame.size.width-1, width: 1, height: height))
    //sepratorView.backgroundColor = UIColor.lightGrayColor();
    dayLabel.textAlignment = .Center
    dayLabel.text = day.uppercaseString
    dayLabel.font = kDayFontL
    dayLabel.textColor = kDayColor
    addSubview(sepratorView)
    addSubview(dayLabel)
  }
  
}


// MARK: NWCalendarMonthSelectorView Actions
extension NWCalendarMenuView {
  func prevMonthPressed(sender: AnyObject) {
    delegate?.prevMonthPressed()
  }
  
  func nextMonthPressed(sender: AnyObject) {
    delegate?.nextMonthPressed()
  }
}
