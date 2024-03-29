//
//  NWCalendarMonthView.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation
import UIKit

protocol NWCalendarMonthViewDelegate {
  func didSelectDay(dayView: NWCalendarDayView, notifyDelegate: Bool)
  func selectDay(dayView: NWCalendarDayView)
    func scrollToCurrentView(dayview:NWCalendarDayView,animated:Bool)
}

class NWCalendarMonthView: UIView {
  private let kRowCount: CGFloat     = 2
  private let kNumberOfDaysPerWeek   = 7
  
  var delegate: NWCalendarMonthViewDelegate?
  
  var month        : NSDateComponents!
  var dayViewHeight: CGFloat!
  var columnWidths :[CGFloat]?
  var numberOfWeeks: Int!
  
  var dayViewsDict = Dictionary<String, NWCalendarDayView>()
  
  var dayViews:Set<NWCalendarDayView> {
    return Set(dayViewsDict.values)
  }
  
//  var isCurrentMonth: Bool! = false {
//    didSet {
//      if isCurrentMonth == true {
//        for dayView in dayViews {
//          dayView.isActiveMonth = true
//        }
//        
//      } else {
//        for dayView in dayViews {
//          dayView.isActiveMonth = false
//        }
//        
//      }
//    }
//  }
  
  var disabledDates:[NSDateComponents]? {
    didSet {
      if let dates = disabledDates {
        for disabledDate in dates {
          let key = dayViewKeyForDay(disabledDate)
          let dayView = dayViewsDict[key]
          dayView?.isEnabled = false
        }
      }

    }
  }
  
  var availableDates:[NSDateComponents]? {
    didSet {
      if let availableDates = self.availableDates {
        for dayView in dayViews {
          if availableDates.contains(dayView.day!) {
            dayView.isEnabled = true
          } else {
            dayView.isEnabled = false
          }
        }
      }
    }
  }
  
  var selectedDates:[NSDateComponents]? {
    didSet {
      if let dates = selectedDates {
        for selectedDate in dates {
          let key = dayViewKeyForDay(selectedDate)
          if let dayView = dayViewsDict[key] {
            delegate?.selectDay(dayView)
          }
          
        }
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  convenience init(month: NSDateComponents, width: CGFloat, height: CGFloat) {
    self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    backgroundColor = UIColor.clearColor()
    dayViewHeight = frame.height/kRowCount
    self.month = month
    calculateColumnWidths()
    createDays()
    numberOfWeeks = month.calendar!.rangeOfUnit(.WeekOfMonth, inUnit: .Month, forDate: month.date!).length
  }
  
  func disableMonth() {
    for dayView in dayViews {
      dayView.isEnabled = false
    }
  }
  
  func dayViewForDay(day: NSDateComponents) -> NWCalendarDayView? {
    let dayViewKey = dayViewKeyForDay(day)
    return dayViewsDict[dayViewKey]
  }
  
  
}

// MARK: - Layout
extension NWCalendarMonthView {
  func createDays() {
    
    //Present date component
    var day = NSDateComponents()
    day.calendar = month.calendar
    day.day = 1
    day.month = month.month
    day.year = month.year

    
    let firstDate = day.calendar?.dateFromComponents(day)
    day = firstDate!.nwCalendarView_dayWithCalendar(month.calendar!)
    
    let numberOfDaysInMonth = day.calendar?.rangeOfUnit(.Day, inUnit: .Month, forDate: day.date!).length
    
    //get start column
    var startColumn = day.weekday - (day.calendar!.firstWeekday)
    
    if startColumn < 0 {
      startColumn += kNumberOfDaysPerWeek
    }
    
    //get previous days on showing calendar
    var preday = NSDateComponents()
    if startColumn > 0{
        
        preday.calendar = month.calendar
        preday.day = 1
        preday.month = month.month - 1
        preday.year = month.year
        
        let firstDate = preday.calendar?.dateFromComponents(preday)
        preday = firstDate!.nwCalendarView_dayWithCalendar(preday.calendar!)
        let numberOfDaysInMonth = preday.calendar?.rangeOfUnit(.Day, inUnit: .Month, forDate: preday.date!).length
        preday.day = numberOfDaysInMonth! - (startColumn - 1)
        
    }
    
    var nextDayViewOrigin = CGPointZero
    for (var column = 0; column < startColumn; column++) {
        
        let dayView = createDayView(nextDayViewOrigin, width: columnWidths![column])
        dayView.delegate = self
        dayView.setDayForDay(preday)
        dayView.isInPast = true
        let dayViewKey = dayViewKeyForDay(preday)
        dayViewsDict[dayViewKey] = dayView
        addSubview(dayView)
        preday.day += 1
      nextDayViewOrigin.x += columnWidths![column]
    }
    
    //NExt month's days on current month
    var nxtday = NSDateComponents()
    nxtday.calendar = month.calendar
    nxtday.day = 1
    nxtday.month = month.month + 1
    nxtday.year = month.year
    
    
    let nxtDate = nxtday.calendar?.dateFromComponents(nxtday)
    nxtday = nxtDate!.nwCalendarView_dayWithCalendar(nxtday.calendar!)

    var countRow = 0
    repeat {
        countRow += 1
      for(var column = startColumn; column < kNumberOfDaysPerWeek; column += 1) {
        if day.month == month.month && day.day <= numberOfDaysInMonth{
          let dayView = createDayView(nextDayViewOrigin, width: columnWidths![column])
          dayView.delegate = self
          dayView.setDayForDay(day)
          let dayViewKey = dayViewKeyForDay(day)
          dayViewsDict[dayViewKey] = dayView
          addSubview(dayView)
        }
        day.day += 1
        nextDayViewOrigin.x += columnWidths![column]
        
        if day.day > numberOfDaysInMonth {
            if column == kNumberOfDaysPerWeek{
                break
            }else{
                let dayView = createDayView(nextDayViewOrigin, width: columnWidths![column])
                dayView.delegate = self
                dayView.isEnabled = false
                dayView.setDayForDay(nxtday)
                let dayViewKey = dayViewKeyForDay(nxtday)
                dayViewsDict[dayViewKey] = dayView
                addSubview(dayView)
                nxtday.day += 1
            }
    
        }
      }
      
        switch countRow {
        case 1:
            nextDayViewOrigin.x = 0
            nextDayViewOrigin.y += dayViewHeight
            break
        case 2:
            nextDayViewOrigin.x = UIScreen.mainScreen().bounds.size.width
            nextDayViewOrigin.y = 0
            break
        case 3:
            nextDayViewOrigin.y += dayViewHeight
            nextDayViewOrigin.x = UIScreen.mainScreen().bounds.size.width
            break
        case 4:
            nextDayViewOrigin.y = 0
            nextDayViewOrigin.x = UIScreen.mainScreen().bounds.size.width  * 2
            break
        case 5:
             nextDayViewOrigin.y += dayViewHeight
            nextDayViewOrigin.x = UIScreen.mainScreen().bounds.size.width  * 2
            break
        case 6:
            
            break
            
        default: break
            
        }
      startColumn = 0
    } while (day.day <= numberOfDaysInMonth)
    
  }
  
  func createDayView(origin: CGPoint, width: CGFloat)-> NWCalendarDayView {
    var dayFrame = CGRectZero
    dayFrame.origin = origin
    dayFrame.size.width = width
    dayFrame.size.height = dayViewHeight
    
    return NWCalendarDayView(frame: dayFrame)
  }
  
  
  func calculateColumnWidths() {
    columnWidths = NWCalendarCache.sharedCache.objectForKey(kNumberOfDaysPerWeek) as? [CGFloat]
    if columnWidths == nil {
      let columnCount:CGFloat = CGFloat(kNumberOfDaysPerWeek)
      let width      :CGFloat = floor(UIScreen.mainScreen().bounds.size.width / CGFloat(columnCount))
      var remainder  :CGFloat = UIScreen.mainScreen().bounds.size.width - (width * CGFloat(columnCount))
      var padding    :CGFloat = 1
      
      columnWidths = [CGFloat](count: kNumberOfDaysPerWeek, repeatedValue: width)
      
      if remainder > columnCount {
        padding = ceil(remainder/columnCount)
      }
      
      
      for (index, _) in (columnWidths!).enumerate() {
        columnWidths![index] = width + padding
        
        remainder -= padding
        if remainder < 1 {
          break
        }
      }
      NWCalendarCache.sharedCache.setObjectForKey(columnWidths!, key: kNumberOfDaysPerWeek)
    }
    
  }
  
  func dayViewKeyForDay(day: NSDateComponents) -> String {
    return "\(day.month)/\(day.day)/\(day.year)"
  }
}

// MARK: - Touch Handling
extension NWCalendarMonthView {
  override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    for subview in subviews {
      if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
        return true
      }
    }
    return false
  }
}

// MARK: - NWCalendarDayViewDelegate
extension NWCalendarMonthView: NWCalendarDayViewDelegate {
  func dayButtonPressed(dayView: NWCalendarDayView) {
    delegate?.didSelectDay(dayView, notifyDelegate: true)
  }
}