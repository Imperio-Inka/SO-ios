 //
//  NWCalendarMonthContentView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit


protocol NWCalendarMonthContentViewDelegate {
    
  func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents)
    
  func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents)
}

 
class NWCalendarMonthContentView: UIScrollView {
    
    private let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Weekday, .Calendar]
    
    private let kCurrentMonthOffset = 0
  
    var monthContentViewDelegate:NWCalendarMonthContentViewDelegate?
  
    var presentMonth         :      NSDateComponents!
    var presentMonthView     :      NWCalendarMonthView!
    
    var monthViewsDict   = Dictionary<String, NWCalendarMonthView>()

    var dayViewHeight       : CGFloat             = 44
    var pastEnabled                               = false
    
    var selectionRangeLength: Int!                = 0
    
    var selectedDayViews    : [NWCalendarDayView] = []
    var lastMonthOrigin     : CGFloat?
  
    var maxMonth            : NSDateComponents?
    
    var maxMonths           : Int! = 0 {
        didSet {
      if maxMonths > 0 {
        let date = NSCalendar.usLocaleCurrentCalendar().dateByAddingUnit(.Month, value: maxMonths, toDate: presentMonth.date!, options: [])!
        let month = date.nwCalendarView_monthWithCalendar(presentMonth.calendar!)
        maxMonth = month
      }
    }
  }
    
  var futureEnabled: Bool {
    return maxMonths == 0
  }

  var disabledDatesDict: [String: [NSDateComponents]] = [String: [NSDateComponents]]()
    
    
  var disabledDates:[NSDate]? {
    didSet {
      if let dates = disabledDates {
        for date in dates {
          let comp = NSCalendar.usLocaleCurrentCalendar().components([.Year, .Month, .Day, .Weekday, .Calendar], fromDate: date)
          let key = monthViewKeyForMonth(comp)
            
          if var compArray = disabledDatesDict[key] {
            compArray.append(comp)
            disabledDatesDict[key] = compArray
          } else {
            let compArray:[NSDateComponents] = [comp]
            disabledDatesDict[key] = compArray
          }
        }
      }
    }
  }
  
  var selectedDatesDict: [String: [NSDateComponents]] = [String: [NSDateComponents]]()
    
  var selectedDates: [NSDate]? {
    didSet {
      if let dates = selectedDates {
        for date in dates {
          let comp = NSCalendar.usLocaleCurrentCalendar().components([.Year, .Month, .Day, .Weekday, .Calendar], fromDate: date)
          let key = monthViewKeyForMonth(comp)
          if var compArray = selectedDatesDict[key] {
            compArray.append(comp)
            selectedDatesDict[key] = compArray
          } else {
            let compArray:[NSDateComponents] = [comp]
            selectedDatesDict[key] = compArray
          }
        }
      }
    }
  }
  
  var showOnlyAvailableDates = false
  var availableDatesDict: [String: [NSDateComponents]] = [String: [NSDateComponents]]()
  var availableDates: [NSDate]? {
    didSet {
      if let dates = availableDates {
        showOnlyAvailableDates = true
        for date in dates {
          let comp = NSCalendar.usLocaleCurrentCalendar().components([.Year, .Month, .Day, .Weekday, .Calendar], fromDate: date)
          let key = monthViewKeyForMonth(comp)
          if var compArray = availableDatesDict[key] {
            compArray.append(comp)
            availableDatesDict[key] = compArray
          } else {
            let compArray:[NSDateComponents] = [comp]
            availableDatesDict[key] = compArray
          }
        }
      }
    }
  }
  
  var currentMonthView: NWCalendarMonthView! {
    return presentMonthView
  }
  
  
  var monthViewOrigins: [CGFloat] = []
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.pagingEnabled  = true
    clipsToBounds = true
    self.backgroundColor = UIColor.clearColor()
    dayViewHeight = frame.height / 2
    
  }
  
  convenience init(month: NSDateComponents, frame: CGRect) {
    self.init(frame: frame)
    presentMonth = month
  }
  
  func createCalendar() {
    setupMonths(presentMonth)
  }

  func setupMonths(month: NSDateComponents) {
    createMonthViewForMonth(presentMonth)
  }
  
}

// MARK: - Navigation
extension NWCalendarMonthContentView {
    
  func nextMonth() {
    var nextMonth = NSDateComponents()
    nextMonth.calendar = presentMonth.calendar
    nextMonth.day = 1
    nextMonth.month = presentMonth.month + 1
    nextMonth.year = presentMonth.year
    
    
    let firstDate = nextMonth.calendar?.dateFromComponents(nextMonth)
    nextMonth = firstDate!.nwCalendarView_dayWithCalendar(nextMonth.calendar!)
    presentMonth = nextMonth
    setupMonths(nextMonth)
    
  }

  func prevMonth() {
    var preMonth = NSDateComponents()
    preMonth.calendar = presentMonth.calendar
    preMonth.day = 1
    preMonth.month = presentMonth.month - 1
    preMonth.year = presentMonth.year
    
    
    let firstDate = preMonth.calendar?.dateFromComponents(preMonth)
    preMonth = firstDate!.nwCalendarView_dayWithCalendar(preMonth.calendar!)
    presentMonth = preMonth
    setupMonths(preMonth)
  }
 
 }
// MARK: - Layout
extension NWCalendarMonthContentView {
  func createMonthViewForMonth(month: NSDateComponents) {
    
    let overlapOffset:CGFloat = 0
    let lastMonthMaxY:CGFloat = 0

    for vs in self.subviews{
        if vs.isKindOfClass(NWCalendarMonthView){
            vs.removeFromSuperview();
        }
    }
    // Create & Position Month View
    let monthView = cachedOrCreateMonthViewForMonth(month)
    
    monthView.frame.origin.y = lastMonthMaxY - overlapOffset
   // monthViewOrigins.append(monthView.frame.origin.y)
    
    contentSize.width = monthView.frame.size.width
    
    let key = monthViewKeyForMonth(month)
    
    if let disabledArray = disabledDatesDict[key] {
      monthView.disabledDates = disabledArray
    }
    
    if let availableArray = availableDatesDict[key] {
      monthView.availableDates = availableArray
    } else if showOnlyAvailableDates {
      monthView.availableDates = []
    }
    
    if let selectedArray = selectedDatesDict[key] {
      monthView.selectedDates = selectedArray
    }
    
  }
}

// MARK: - Caching
extension NWCalendarMonthContentView {
  func monthStartsOnFirstDayOfWeek(month: NSDateComponents) -> Bool{
    let month = month.calendar!.components(unitFlags, fromDate: month.date!)
    return (month.weekday - month.calendar!.firstWeekday) == 0
  }
  
  func monthViewKeyForMonth(month: NSDateComponents) -> String {
    let month = month.calendar?.components([.Year, .Month], fromDate: month.date!)
    return "\(month!.year).\(month!.month)"
  }
  
  func cachedOrCreateMonthViewForMonth(month: NSDateComponents) -> NWCalendarMonthView {
    let month = month.calendar?.components(unitFlags, fromDate: month.date!)
    let monthViewKey = monthViewKeyForMonth(month!)
    var monthView = monthViewsDict[monthViewKey]
    
    if monthView == nil {
      monthView = NWCalendarMonthView(month: month!, width: bounds.width * 3 , height: bounds.height )
      monthViewsDict[monthViewKey] = monthView
     presentMonthView = monthView
      //monthViews.append(monthView!)
      monthView?.delegate = self
      
    }
    self.setContentOffset(CGPoint(x: 0 , y: self.contentOffset.y), animated: true)
    addSubview(monthView!)
    return monthView!
    
  }
}

 // MARK: - NWCalendarMonthViewDelegate
extension NWCalendarMonthContentView: NWCalendarMonthViewDelegate {
    
  func didSelectDay(dayView: NWCalendarDayView, notifyDelegate: Bool) {
    if selectionRangeLength > 0 {
      clearSelectedDays()
      var day = dayView.day?.copy() as! NSDateComponents
      
      for _ in 0..<selectionRangeLength {
        day = day.date!.nwCalendarView_dayWithCalendar(day.calendar!)
        let month = day.date!.nwCalendarView_monthWithCalendar(day.calendar!)
        let monthViewKey = monthViewKeyForMonth(month)
        let monthView = monthViewsDict[monthViewKey]
        let dayView = monthView?.dayViewForDay(day)
        
        if let unwrappedDayView = dayView {
          selectDay(unwrappedDayView)
        }
        
        day.day += 1
      }
      
      day.day -= 1
      day = day.date!.nwCalendarView_dayWithCalendar(day.calendar!)
        let nwCalenderView = self.superview as! NWCalendarView
        nwCalenderView.didSelectDate(day, toDate: day)
       // NWCalendarView.didSelectDate(<#T##NWCalendarView#>)
    }
  }
  
  func selectDay(dayView: NWCalendarDayView) {
    dayView.isSelected = true
    selectedDayViews.removeAll();
    selectedDayViews.append(dayView)
    
  }
   
    internal func scrollToCurrentView(dayView: NWCalendarDayView,animated:Bool) {
    if (dayView.frame.origin.x/UIScreen.mainScreen().bounds.width) <= 1 {
        self.setContentOffset(CGPoint(x: 0.0, y: self.contentOffset.y), animated: animated)
    }else if  (dayView.frame.origin.x/UIScreen.mainScreen().bounds.width) < 2 {
        self.setContentOffset(CGPoint(x: UIScreen.mainScreen().bounds.width,  y: self.contentOffset.y), animated: animated)
    }else{
        self.setContentOffset(CGPoint(x: UIScreen.mainScreen().bounds.width * 2 , y: self.contentOffset.y), animated: animated)
    }
    
    }
    
  
  func clearSelectedDays() {
    if selectedDayViews.count > 0 {
      for dayView in selectedDayViews {
        dayView.isSelected = false
      }
    }
  }
}