

import UIKit

class RootViewController: UIViewController, UITabBarControllerDelegate {
    
   var headerView : CustomHeaderView!
    
    var topView : UIView!
    var lastShow = 0
    override func viewDidLoad() {
        
       
        
    }
    
    func addviewOnTop(vc : UIViewController)  {
        if topView != nil {
            topView.removeFromSuperview()
        }
       // if lastShow != 0{
            topView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
            topView.backgroundColor = UIColor(red: 45.0/255, green: 45.0/255, blue: 45.0/255, alpha: 0.2)
            vc.view.addSubview(topView)
       // }
        
        
       
    }

    
    func getHeaderInstance() -> CustomHeaderView {
        let arrViews = NSBundle.mainBundle().loadNibNamed("HeaderView", owner: nil, options: nil)
        for vs in arrViews
        {
            if vs.isKindOfClass(CustomHeaderView){
                headerView = vs as! CustomHeaderView
                break
            }
        }
        headerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 84 * heightRatio)
        headerView.updateConstraints()
    
        return headerView
    }
    
    //MARK: showing alert message
    func showNormalAlert(title : String!, msg : String!)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showAlertMsg(title : String!, msg : String,arrAction: NSArray!)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        for action in arrAction
        {
            alert.addAction(action as! UIAlertAction)
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Activity Controller
    func showActivityIndicator(footerLine : String) {
       
       
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate, let window = app.window {
           JHProgressHUD.sharedHUD.showInView(window, withHeader: "", andFooter: footerLine )
        }
        UIApplication.sharedApplication().beginIgnoringInteractionEvents();
    }
    
    func hideActivityIndicator(){
  
        JHProgressHUD.sharedHUD.hide()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func addSideNavigationGesture(){
        if((self.DSViewController()) != nil){
            self.view.addGestureRecognizer((self.DSViewController()?.panGestureRecognizer())!)
            self.view.addGestureRecognizer((self.DSViewController()?.tapGestureRecognizer())!)
        }
    }
    
    func removeSildeNavigationGesture(){
        if((self.DSViewController()) != nil){
            self.view.removeGestureRecognizer((self.DSViewController()?.panGestureRecognizer())!)
            self.view.removeGestureRecognizer((self.DSViewController()?.tapGestureRecognizer())!)
        }
    }
    
}
