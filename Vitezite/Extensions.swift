//
//  Extensions.swift
//  LocumDay
//
//  Created by Bhuvan Sharma on 12/1/15.
//  Copyright © 2015 Bhuvan Sharma. All rights reserved.
//

import Foundation
import UIKit
//import ObjectMapper

//MARK: Getting screen size for check conditions
extension UIScreen {
    
    enum SizeType: CGFloat {
        case Unknown = 0.0
        case iPhone4 = 480.0
        case iPhone5 = 568.0
        case iPhone6 = 667.0
        case iPhone6Plus = 736.0
    }
    
    var sizeType: SizeType {
        let height = UIScreen.mainScreen().bounds.size.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
}



extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}


//MARK: NSDate Extension

extension NSDate {
    var formatted: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return  formatter.stringFromDate(self)
    }
}


//MARK: UIView extention for animation fade in and fade out

extension UIView {
    func fadeIn(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            self.hidden = false
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 0.2, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            self.hidden = true
            }, completion: completion)
    }
}

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}

//MARK: Custom Color
extension UIColor
{
    var customBorderColor: UIColor {
        return UIColor(red: 213.0/255, green: 214.0/255, blue: 207.0/255, alpha: 1.0)
    }
    
    var worngAlertColor: UIColor {
        return UIColor.redColor()
    }
    
    var appRedColor: UIColor {
        
        return UIColor(red: 157.0/255, green: 0.0/255, blue: 41.0/255, alpha: 1.0)
    }
    
    var appLightRedColor : UIColor{
        return UIColor(red: 255.0/255, green: 68.0/255, blue: 68.0/255, alpha: 1.0)
    }
    
    var appGreenColor: UIColor {
        
        return UIColor(red: 99.0/255, green: 177.0/255, blue: 46.0/255, alpha: 1.0)
    }
    
}





//MARK: Load XIB
extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}


////MARK: Convert object to json
//extension Mappable {
//    func toJsonDictionary() -> [String : AnyObject] {
//        return Mapper().toJSON(self)
//    }
//    func toString() -> String {
//        return Mapper().toJSONString(self,prettyPrint: true)!
//    }
//
//}


//MARK: StringHeight
extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedWidth(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: height)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
    
    func sizeWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.max, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.size
    }
    
    var isAlphanumeric: Bool {
        if rangeOfString("^(?=.*[a-zA-Z])(?=.*[0-9])", options: .RegularExpressionSearch) != nil{
            return true
        }else{
            return false
        }
    }
    
    func getDatefromStringWithFormat(format: String) -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        let chDate = dateFormatter.dateFromString(self)
        return chDate!;
    }
    
}


//uiview corner radius
@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.CGColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(CGColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}


//Roboto-Regular

//if (autoFont) {
//    float newFontSize = [UIScreen mainScreen].bounds.size.height * (fontSize / 568.0);
//    if ([UIScreen mainScreen].bounds.size.height < 500) {
//        newFontSize = [UIScreen mainScreen].bounds.size.height * (fontSize / 480.0);
//    }
//    self.font = [UIFont fontWithName:self.font.fontName size:newFontSize];
//}



//MARK: Make StoryBoard Object
extension UIStoryboard
{
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    class func welcomeStoryboard() -> UIStoryboard { return UIStoryboard(name: "WelcomeDisplay", bundle: NSBundle.mainBundle()) }
    
    class func tagListController() -> TagListViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("Taglist") as? TagListViewController
    }
    
    class func tagsController() -> TagsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CustomTags") as? TagsViewController
    }
    
    class func homeController() -> HomeViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("Home") as? HomeViewController
    }
    class func createEventController() -> CreateEventViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CreateEvent") as? CreateEventViewController
    }
    
    class func sideMenuController() -> SideMenuViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SideMenu") as? SideMenuViewController
    }
    class func calenderListController() -> CalenderListViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CalenderListViewController") as? CalenderListViewController
    }
    
    class func profileController() -> ProfileViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ProfileController") as? ProfileViewController
    }
    
    class func contactscontroller() -> ContactsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ContactsController") as? ContactsViewController
    }
    
    
    class func locationController() -> LocationViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LocationController") as? LocationViewController
    }
    
    class func getLocationNavigationController() ->UINavigationController?{
        return mainStoryboard().instantiateViewControllerWithIdentifier("LocationControllerNavigation") as? UINavigationController
    }
    
    class func settingController() ->SettingViewController?{
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingController") as? SettingViewController
    }
    
    class func webViewController() ->WebViewController?{
        return mainStoryboard().instantiateViewControllerWithIdentifier("WebViewController") as? WebViewController
    }
    
    
    
    //
    
    
    //    ///Welcome storyBoard
    //    class func firstWelcomeController() -> FirstWelcomeViewController?{
    //        return welcomeStoryboard().instantiateViewControllerWithIdentifier("FirstWelcome") as? FirstWelcomeViewController
    //    }
    
}


public extension Int {
    /// Returns a random Int point number between 0 and Int.max.
    public static func random(lower: Int = 0, _ upper: Int = 100) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}


private var rfc3339formatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return formatter
}()


extension NSDate {
    
    
    
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        
        return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        
        return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        
        return self.compare(dateToCompare) == NSComparisonResult.OrderedSame
    }
    var stringFormattedAsRFC3339: String {
        return rfc3339formatter.stringFromDate(self)
    }
    
    convenience init?(RFC3339FormattedString:String) {
        if let d = rfc3339formatter.dateFromString(RFC3339FormattedString) {
            self.init(timeInterval:0,sinceDate:d)
        }
        else { return nil }
    }
    public  func ISOStringFromDate(date: NSDate) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.stringFromDate(date).stringByAppendingString("Z")
    }
    
    public  func dateFromISOString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.dateFromString(string)!
    }
}

public extension UITableView {
    
    func indexesOfVisibleSections() -> Array<Int> {
        // Note: We can't just use indexPathsForVisibleRows, since it won't return index paths for empty sections.
        var visibleSectionIndexes = Array<Int>()
        for (var i = 0; i < self.numberOfSections; i += 1) {
            var headerRect: CGRect?
            // In plain style, the section headers are floating on the top, so the section header is visible if any part of the section's rect is still visible.
            // In grouped style, the section headers are not floating, so the section header is only visible if it's actualy rect is visible.
            if (self.style == .Plain) {
                headerRect = self.rectForSection(i)
            } else {
                headerRect = self.rectForHeaderInSection(i)
            }
            if headerRect != nil {
                // The "visible part" of the tableView is based on the content offset and the tableView's size.
                let visiblePartOfTableView: CGRect = CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.bounds.size.width, height: self.bounds.size.height)
                if (visiblePartOfTableView.intersects(headerRect!)) {
                    visibleSectionIndexes.append(i)
                }
            }
        }
        return visibleSectionIndexes
    }
    
    func visibleSectionHeaders() -> Array<UITableViewHeaderFooterView> {
        var visibleSects = Array<UITableViewHeaderFooterView>()
        for sectionIndex in self.indexesOfVisibleSections() {
            if let sectionHeader = self.headerViewForSection(sectionIndex) {
                visibleSects.append(sectionHeader)
            }
        }
        
        return visibleSects
    }
}


