
import UIKit


//delegate methods for calendar
@objc protocol NWCalendarViewDelegate {
    
  optional func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents)
  optional func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents)
}



public class NWCalendarView: UIView {
    
   // private let kMenuHeightPercentage:CGFloat = 0.256
  
    weak var delegate: NWCalendarViewDelegate?
    var menuView          : NWCalendarMenuView!
    var monthContentView  : NWCalendarMonthContentView!
    var visibleMonth      : NSDateComponents! {
        didSet {
            updateMonthLabel(visibleMonth)
        }
    }
  
  public var selectionRangeLength: Int? {
    didSet {
      monthContentView.selectionRangeLength = selectionRangeLength
    }
  }
  
  public var disabledDates:[NSDate]? {
    didSet {
      monthContentView.disabledDates = disabledDates
    }
  }
  
  public var maxMonths: Int? {
    didSet {
      monthContentView.maxMonths = maxMonths
    }
  }
  
  public var selectedDates: [NSDate]? {
    didSet {
      monthContentView.selectedDates = selectedDates
    }
  }
  
  public var availableDates: [NSDate]? {
    didSet {
      monthContentView.availableDates = availableDates
    }
  }
  
  // MARK: Initialization
  override public init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  // IB Init
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  func commonInit() {
   
    setDefault(NSDate())
    }
    
    func setDefault(fromDate:NSDate)  {
        clipsToBounds = true
        for view in self.subviews {
            if view.isKindOfClass(NWCalendarMonthContentView)||view.isKindOfClass(NWCalendarMenuView) {
                view .removeFromSuperview()
            }
        }
        
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Weekday, .Calendar]
        visibleMonth = NSCalendar.usLocaleCurrentCalendar().components(unitFlags, fromDate: fromDate)
        visibleMonth.day = 1
        menuView = NWCalendarMenuView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 104))
        menuView.delegate = self
        
        let monthContentViewHeight = frame.height - 104
        let monthContentViewY = CGRectGetMaxY(menuView.frame)
        monthContentView = NWCalendarMonthContentView(month: visibleMonth, frame: CGRect(x: 0, y: monthContentViewY, width: UIScreen.mainScreen().bounds.size.width, height: monthContentViewHeight))
        
        monthContentView.clipsToBounds = true
        monthContentView.monthContentViewDelegate = self
        
        addSubview(menuView)
        addSubview(monthContentView)
        
        updateMonthLabel(visibleMonth)
   
    }
    
  
  public func createCalendar() {
    monthContentView.createCalendar()
    
  }
   public func scrollTocurrentDate(){
    
        
    
        monthContentView.scrollToCurrentView(monthContentView.selectedDayViews[0],animated: false);
    }
    
  
}

// MARK - NWCalendarMonthSelectorView
extension NWCalendarView {
  func updateMonthLabel(month: NSDateComponents) {
    if menuView != nil {
      menuView.monthSelectorView.updateMonthLabelForMonth(month)
    }
  }
}


// MARK: - NWCalendarMenuViewDelegate
extension NWCalendarView: NWCalendarMenuViewDelegate {
  func prevMonthPressed() {
    monthContentView.prevMonth()
    updateMonthLabel(monthContentView.presentMonth)
  }
  
  func nextMonthPressed() {
    monthContentView.nextMonth()
    updateMonthLabel(monthContentView.presentMonth)
  }
}

// MARK: - NWCalendarMonthContentViewDelegate
extension NWCalendarView: NWCalendarMonthContentViewDelegate {
  func didChangeFromMonthToMonth(fromMonth: NSDateComponents, toMonth: NSDateComponents) {
    visibleMonth = toMonth
    delegate?.didChangeFromMonthToMonth?(fromMonth, toMonth: toMonth)
  }
  
  func didSelectDate(fromDate: NSDateComponents, toDate: NSDateComponents) {
    delegate?.didSelectDate?(fromDate, toDate: toDate)
  }
}
